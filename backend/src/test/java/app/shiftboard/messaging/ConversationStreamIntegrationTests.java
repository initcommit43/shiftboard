package app.shiftboard.messaging;

import static org.assertj.core.api.Assertions.assertThat;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;
import java.util.stream.Stream;

import app.shiftboard.IntegrationTest;
import app.shiftboard.TestData;
import app.shiftboard.identity.Role;
import app.shiftboard.identity.TokenPair;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.client.RestTestClient;

class ConversationStreamIntegrationTests extends IntegrationTest {

    static final Instant IN_THREE_DAYS = Instant.now().plus(Duration.ofDays(3)).truncatedTo(ChronoUnit.SECONDS);

    static final Duration QUIET = Duration.ofMillis(700);

    @LocalServerPort
    int port;

    TestData.Agency agency;

    TokenPair dispatcher;

    UUID clientId;

    UUID locationId;

    final List<EventStream> opened = new ArrayList<>();

    @BeforeEach
    void createAgency() {
        agency = data.agency("Donau Personal");
        dispatcher = login(data.account(agency, Role.DISPATCHER), DASHBOARD);
        clientId = data.client(agency, "Nordlicht Logistik");
        locationId = data.location(agency, clientId, "Zentrallager Linz", "Hafenstraße 12, 4020 Linz");
    }

    @AfterEach
    void closeStreams() {
        opened.forEach(EventStream::close);
    }

    @Test
    void aMessageReachesTheWorkerAndEveryDispatcherOfTheAgencyOnly() throws Exception {
        var colleague = login(data.account(agency, Role.ADMIN), DASHBOARD);
        var lena = activeWorker("Lena", "Hofer");
        var jonas = activeWorker("Jonas", "Berger");
        var other = data.agency("Inn Staffing");
        var otherDispatcher = login(data.account(other, Role.DISPATCHER), DASHBOARD);

        var inbox = open("/api/v1/conversations/events", dispatcher);
        var adminInbox = open("/api/v1/conversations/events", colleague);
        var otherInbox = open("/api/v1/conversations/events", otherDispatcher);
        var lenaStream = open("/api/v1/worker/conversation/events", lena);
        var jonasStream = open("/api/v1/worker/conversation/events", jonas);

        send(lena, "Gibt es einen Parkplatz?");

        var notice = inbox.nextNotice();
        assertThat(notice).contains("\"change\":\"MESSAGE\"");
        var conversationId = conversationId(notice);
        assertThat(adminInbox.nextNotice()).contains(conversationId, "MESSAGE");
        assertThat(lenaStream.nextNotice()).contains(conversationId, "MESSAGE");
        otherInbox.expectNoNotice();
        jonasStream.expectNoNotice();

        // A dispatcher opening the conversation reads it, which every open inbox hears about.
        get("/api/v1/conversations/" + conversationId + "/messages", dispatcher).expectStatus().isOk();
        assertThat(adminInbox.nextNotice()).contains(conversationId, "READ");
        assertThat(inbox.nextNotice()).contains(conversationId, "READ");
        assertThat(lenaStream.nextNotice()).contains(conversationId, "READ");

        // Opening it again changes nothing, so nobody is told.
        get("/api/v1/conversations/" + conversationId + "/messages", dispatcher).expectStatus().isOk();
        inbox.expectNoNotice();

        post("/api/v1/conversations/" + conversationId + "/messages", colleague, Map.of("body", "Ja, hinter Halle 2."))
                .expectStatus().isCreated();
        assertThat(lenaStream.nextNotice()).contains(conversationId, "MESSAGE");
        assertThat(inbox.nextNotice()).contains(conversationId, "MESSAGE");
        jonasStream.expectNoNotice();
        otherInbox.expectNoNotice();
    }

    @Test
    void systemMessagesAndBroadcastsAreAnnouncedToo() throws Exception {
        var lena = activeWorker("Lena", "Hofer");
        var shiftId = publish(IN_THREE_DAYS, 3);
        var lenaStream = open("/api/v1/worker/conversation/events", lena);

        var assignmentId = claim(shiftId, lena);
        post("/api/v1/shifts/" + shiftId + "/assignments/" + assignmentId + "/approve", dispatcher)
                .expectStatus().isOk();
        assertThat(lenaStream.nextNotice()).contains("MESSAGE");

        post("/api/v1/shifts/" + shiftId + "/broadcast", dispatcher, Map.of("body", "Sicherheitsschuhe mitbringen."))
                .expectStatus().isCreated();
        assertThat(lenaStream.nextNotice()).contains("MESSAGE");
    }

    @Test
    void theStreamsStayWithinTheirRole() {
        var lena = activeWorker("Lena", "Hofer");
        var pending = signUp(agency.signupCode(), TestData.email());

        expectProblem(stream("/api/v1/conversations/events", lena), 403, "forbidden");
        expectProblem(stream("/api/v1/worker/conversation/events", dispatcher), 403, "forbidden");
        expectProblem(stream("/api/v1/worker/conversation/events", pending), 403, "worker_not_active");
        client.get().uri("/api/v1/conversations/events")
                .accept(MediaType.TEXT_EVENT_STREAM)
                .exchange()
                .expectStatus().isUnauthorized();
    }

    // --- helpers -------------------------------------------------------------------------

    private RestTestClient.ResponseSpec stream(String uri, TokenPair tokens) {
        return client.get().uri(uri)
                .accept(MediaType.TEXT_EVENT_STREAM)
                .headers(headers -> headers.setBearerAuth(tokens.accessToken()))
                .exchange();
    }

    private EventStream open(String path, TokenPair tokens) throws Exception {
        var stream = EventStream.open(URI.create("http://localhost:" + port + path), tokens.accessToken());
        opened.add(stream);
        return stream;
    }

    private static String conversationId(String notice) {
        var start = notice.indexOf("\"conversationId\":\"") + "\"conversationId\":\"".length();
        return notice.substring(start, notice.indexOf('"', start));
    }

    private TokenPair activeWorker(String firstName, String lastName) {
        var request = signupRequest(TestData.email());
        request.put("firstName", firstName);
        request.put("lastName", lastName);
        var tokens = postSignup(agency.signupCode(), request)
                .expectStatus().isCreated()
                .expectBody(TokenPair.class).returnResult().getResponseBody();
        post("/api/v1/workers/" + workerId(tokens) + "/approve", dispatcher).expectStatus().isOk();
        return tokens;
    }

    private void send(TokenPair worker, String body) {
        post("/api/v1/worker/conversation/messages", worker, Map.of("body", body)).expectStatus().isCreated();
    }

    private UUID publish(Instant startsAt, int slots) {
        var request = new HashMap<String, Object>();
        request.put("clientId", clientId);
        request.put("locationId", locationId);
        request.put("title", "Lagerunterstützung");
        request.put("startsAt", startsAt.toString());
        request.put("endsAt", startsAt.plus(Duration.ofHours(8)).toString());
        request.put("hourlyRateCents", 1650);
        request.put("slots", slots);
        request.put("publish", true);
        var created = post("/api/v1/shifts", dispatcher, request)
                .expectStatus().isCreated()
                .expectBody(Map.class).returnResult().getResponseBody();
        return UUID.fromString((String) created.get("id"));
    }

    private UUID claim(UUID shiftId, TokenPair worker) {
        var claimed = post("/api/v1/worker/shifts/" + shiftId + "/claim", worker)
                .expectStatus().isCreated()
                .expectBody(Map.class).returnResult().getResponseBody();
        return UUID.fromString((String) ((Map<?, ?>) claimed.get("assignment")).get("id"));
    }

    /** An open event stream, read line by line on a thread of its own. */
    static final class EventStream implements AutoCloseable {

        private final HttpClient http = HttpClient.newHttpClient();

        private final BlockingQueue<String> lines = new LinkedBlockingQueue<>();

        private CompletableFuture<HttpResponse<Stream<String>>> response;

        static EventStream open(URI uri, String accessToken) throws Exception {
            var stream = new EventStream();
            var request = HttpRequest.newBuilder(uri)
                    .header("Accept", MediaType.TEXT_EVENT_STREAM_VALUE)
                    .header("Authorization", "Bearer " + accessToken)
                    .build();
            stream.response = stream.http.sendAsync(request, HttpResponse.BodyHandlers.ofLines());
            var opened = stream.response.get(5, TimeUnit.SECONDS);
            assertThat(opened.statusCode()).isEqualTo(200);
            assertThat(opened.headers().firstValue("Content-Type")).hasValueSatisfying(
                    type -> assertThat(type).startsWith(MediaType.TEXT_EVENT_STREAM_VALUE));
            Thread.ofVirtual().start(() -> {
                try (var body = opened.body()) {
                    body.forEach(stream.lines::add);
                } catch (RuntimeException closed) {
                    // The test closed the stream.
                }
            });
            // The server announces the stream as soon as it is registered.
            assertThat(stream.lines.poll(5, TimeUnit.SECONDS)).isEqualTo(":connected");
            return stream;
        }

        /** The data of the next {@code conversation} event. */
        String nextNotice() throws InterruptedException {
            var deadline = Instant.now().plusSeconds(5);
            var named = false;
            while (Instant.now().isBefore(deadline)) {
                var line = lines.poll(100, TimeUnit.MILLISECONDS);
                if (line == null) {
                    continue;
                }
                if (line.equals("event:conversation")) {
                    named = true;
                } else if (named && line.startsWith("data:")) {
                    return line.substring("data:".length());
                }
            }
            throw new AssertionError("No conversation event within 5 seconds");
        }

        void expectNoNotice() throws InterruptedException {
            var deadline = Instant.now().plus(QUIET);
            while (Instant.now().isBefore(deadline)) {
                var line = lines.poll(50, TimeUnit.MILLISECONDS);
                assertThat(line).as("an unexpected event line").satisfiesAnyOf(
                        l -> assertThat(l).isNull(),
                        l -> assertThat(l).startsWith(":"),
                        l -> assertThat(l).isEmpty());
            }
        }

        @Override
        public void close() {
            response.cancel(true);
            http.shutdownNow();
        }
    }
}
