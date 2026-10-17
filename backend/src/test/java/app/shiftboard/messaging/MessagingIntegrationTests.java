package app.shiftboard.messaging;

import static org.assertj.core.api.Assertions.assertThat;
import static org.awaitility.Awaitility.await;

import java.time.Duration;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import app.shiftboard.IntegrationTest;
import app.shiftboard.TestData;
import app.shiftboard.identity.Role;
import app.shiftboard.identity.TokenPair;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.web.servlet.client.RestTestClient;

class MessagingIntegrationTests extends IntegrationTest {

    static final Instant IN_THREE_DAYS = Instant.now().plus(Duration.ofDays(3)).truncatedTo(ChronoUnit.SECONDS);

    TestData.Agency agency;

    TokenPair dispatcher;

    TokenPair colleague;

    UUID clientId;

    UUID locationId;

    @BeforeEach
    void createAgency() {
        agency = data.agency("Donau Personal");
        dispatcher = login(data.account(agency, Role.DISPATCHER), DASHBOARD);
        colleague = login(data.account(agency, Role.DISPATCHER, "Markus", "Huber", null), DASHBOARD);
        clientId = data.client(agency, "Nordlicht Logistik");
        locationId = data.location(agency, clientId, "Zentrallager Linz", "Hafenstraße 12, 4020 Linz");
    }

    @Test
    void aWorkerWritesTheAgencyAndAnyDispatcherAnswers() {
        var lena = activeWorker("Lena", "Hofer");
        var shiftId = publish(IN_THREE_DAYS, 5);

        get("/api/v1/worker/conversation/messages", lena)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalElements").isEqualTo(0);

        var sent = send(lena, Map.of("body", "  Gibt es einen Parkplatz?  ", "shiftId", shiftId))
                .expectStatus().isCreated()
                .expectBody(Map.class).returnResult().getResponseBody();
        assertThat(sent.get("type")).isEqualTo("TEXT");
        assertThat(sent.get("body")).isEqualTo("Gibt es einen Parkplatz?");
        assertThat(sent.get("fromWorker")).isEqualTo(true);
        assertThat(((Map<?, ?>) sent.get("shift")).get("title")).isEqualTo("Lagerunterstützung");
        assertThat(sent).doesNotContainKey("readAt");
        assertThat(events.all()).anySatisfy(event -> assertThat(event).isInstanceOfSatisfying(
                MessageSent.class, message -> assertThat(message.fromWorker()).isTrue()));

        // The inbox shows the conversation with one unread message, for every dispatcher.
        get("/api/v1/conversations/unread-count", colleague)
                .expectStatus().isOk()
                .expectBody().jsonPath("$.unreadCount").isEqualTo(1);
        var inbox = get("/api/v1/conversations", colleague)
                .expectStatus().isOk()
                .expectBody(Map.class).returnResult().getResponseBody();
        var conversation = (Map<?, ?>) ((List<?>) inbox.get("content")).getFirst();
        assertThat(((Map<?, ?>) conversation.get("worker")).get("firstName")).isEqualTo("Lena");
        assertThat(conversation.get("unreadCount")).isEqualTo(1);
        assertThat(((Map<?, ?>) conversation.get("lastMessage")).get("body")).isEqualTo("Gibt es einen Parkplatz?");
        var conversationId = conversation.get("id");

        // Opening it marks the worker's message as read.
        get("/api/v1/conversations/" + conversationId + "/messages", colleague)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[0].readAt").isNotEmpty();
        get("/api/v1/conversations/unread-count", dispatcher)
                .expectStatus().isOk()
                .expectBody().jsonPath("$.unreadCount").isEqualTo(0);

        post("/api/v1/conversations/" + conversationId + "/messages", colleague,
                Map.of("body", "Ja, hinter Halle 2."))
                .expectStatus().isCreated()
                .expectBody()
                .jsonPath("$.fromWorker").isEqualTo(false)
                .jsonPath("$.senderName").isEqualTo("Markus Huber");

        get("/api/v1/worker/conversation", lena)
                .expectStatus().isOk()
                .expectBody().jsonPath("$.unreadCount").isEqualTo(1);
        get("/api/v1/worker/conversation/messages", lena)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[*].body").isEqualTo(List.of("Ja, hinter Halle 2.", "Gibt es einen Parkplatz?"))
                .jsonPath("$.content[0].senderName").isEqualTo("Markus Huber")
                .jsonPath("$.content[1].shift.id").isEqualTo(shiftId.toString());
        get("/api/v1/worker/conversation", lena)
                .expectStatus().isOk()
                .expectBody().jsonPath("$.unreadCount").isEqualTo(0);
    }

    @Test
    void theInboxListsTheMostRecentConversationFirst() {
        var lena = activeWorker("Lena", "Hofer");
        var jakob = activeWorker("Jakob", "Steiner");
        send(lena, Map.of("body", "Erste")).expectStatus().isCreated();
        send(jakob, Map.of("body", "Zweite")).expectStatus().isCreated();
        send(jakob, Map.of("body", "Dritte")).expectStatus().isCreated();

        get("/api/v1/conversations", dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalElements").isEqualTo(2)
                .jsonPath("$.content[*].worker.firstName").isEqualTo(List.of("Jakob", "Lena"))
                .jsonPath("$.content[*].unreadCount").isEqualTo(List.of(2, 1))
                .jsonPath("$.content[0].lastMessage.body").isEqualTo("Dritte");
    }

    @Test
    void statusChangesAppearAsSystemMessagesTaggedWithTheShift() {
        var lena = activeWorker("Lena", "Hofer");
        var shiftId = publish(IN_THREE_DAYS, 5);
        var assignmentId = claim(shiftId, lena);

        post("/api/v1/shifts/" + shiftId + "/assignments/" + assignmentId + "/approve", dispatcher)
                .expectStatus().isOk();
        post("/api/v1/shifts/" + shiftId + "/cancel", dispatcher).expectStatus().isOk();

        await().atMost(Duration.ofSeconds(5)).untilAsserted(() ->
                get("/api/v1/worker/conversation/messages", lena)
                        .expectStatus().isOk()
                        .expectBody()
                        .jsonPath("$.content[*].event").isEqualTo(List.of("SHIFT_CANCELLED", "CLAIM_CONFIRMED")));
        get("/api/v1/worker/conversation/messages", lena)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[0].type").isEqualTo("SYSTEM")
                .jsonPath("$.content[0].fromWorker").isEqualTo(false)
                .jsonPath("$.content[0].senderName").doesNotExist()
                .jsonPath("$.content[0].shift.id").isEqualTo(shiftId.toString())
                .jsonPath("$.content[0].body").value(body -> assertThat((String) body)
                        .startsWith("Die Schicht „Lagerunterstützung“ am ")
                        .endsWith(" wurde abgesagt."))
                .jsonPath("$.content[1].body").value(body -> assertThat((String) body).endsWith(" ist bestätigt."));
        // System messages are not the worker's, so they do not show as unread at the agency.
        get("/api/v1/conversations/unread-count", dispatcher)
                .expectStatus().isOk()
                .expectBody().jsonPath("$.unreadCount").isEqualTo(0);
    }

    @Test
    void droppingOutAndBeingRemovedOrRejectedAreReportedToo() {
        var lena = activeWorker("Lena", "Hofer");
        var first = publish(IN_THREE_DAYS, 5);
        var second = publish(IN_THREE_DAYS.plus(Duration.ofDays(1)), 5);
        var third = publish(IN_THREE_DAYS.plus(Duration.ofDays(2)), 5);
        claim(first, lena);
        var removed = claim(second, lena);
        var rejected = claim(third, lena);

        post("/api/v1/worker/shifts/" + first + "/cancel", lena).expectStatus().isOk();
        post("/api/v1/shifts/" + second + "/assignments/" + removed + "/remove", dispatcher,
                Map.of("reason", "Doppelt gebucht")).expectStatus().isOk();
        post("/api/v1/shifts/" + third + "/assignments/" + rejected + "/reject", dispatcher)
                .expectStatus().isOk();

        await().atMost(Duration.ofSeconds(5)).untilAsserted(() ->
                get("/api/v1/worker/conversation/messages", lena)
                        .expectStatus().isOk()
                        .expectBody()
                        .jsonPath("$.content[*].event")
                        .isEqualTo(List.of("CLAIM_REJECTED", "REMOVED_BY_AGENCY", "CLAIM_CANCELLED_BY_WORKER")));
        // The reason for a removal stays with the agency.
        get("/api/v1/worker/conversation/messages", lena)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[1].body").value(body -> assertThat((String) body).doesNotContain("Doppelt"));
    }

    @Test
    void aBroadcastReachesConfirmedWorkersOnly() {
        var shiftId = publish(IN_THREE_DAYS, 5);
        var lena = activeWorker("Lena", "Hofer");
        var jakob = activeWorker("Jakob", "Steiner");
        var mira = activeWorker("Mira", "Aigner");
        approve(shiftId, claim(shiftId, lena));
        approve(shiftId, claim(shiftId, jakob));
        claim(shiftId, mira);

        post("/api/v1/shifts/" + shiftId + "/broadcast", dispatcher,
                Map.of("body", "Treffpunkt ist heute Tor 5."))
                .expectStatus().isCreated()
                .expectBody().jsonPath("$.recipients").isEqualTo(2);

        for (var confirmed : List.of(lena, jakob)) {
            get("/api/v1/worker/conversation/messages", confirmed)
                    .expectStatus().isOk()
                    .expectBody()
                    .jsonPath("$.content[?(@.type == 'BROADCAST')].body").isEqualTo(List.of("Treffpunkt ist heute Tor 5."))
                    .jsonPath("$.content[?(@.type == 'BROADCAST')].shift.id").isEqualTo(List.of(shiftId.toString()))
                    .jsonPath("$.content[?(@.type == 'BROADCAST')].senderName").isEqualTo(List.of("Anna Berger"));
        }
        get("/api/v1/worker/conversation/messages", mira)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[?(@.type == 'BROADCAST')]").isEmpty();
    }

    @Test
    void aBroadcastNeedsSomeoneConfirmed() {
        var shiftId = publish(IN_THREE_DAYS, 5);

        expectProblem(post("/api/v1/shifts/" + shiftId + "/broadcast", dispatcher, Map.of("body", "Hallo")),
                409, "no_recipients");
        expectProblem(post("/api/v1/shifts/" + UUID.randomUUID() + "/broadcast", dispatcher, Map.of("body", "Hallo")),
                404, "shift_not_found");
        expectProblem(post("/api/v1/shifts/" + shiftId + "/broadcast", dispatcher, Map.of("body", " ")),
                400, "validation_failed");
    }

    @Test
    void rejectsEmptyMessagesAndUnknownShifts() {
        var lena = activeWorker("Lena", "Hofer");
        var draft = create(shiftRequest(IN_THREE_DAYS, 5));

        expectProblem(send(lena, Map.of("body", "  ")), 400, "validation_failed")
                .jsonPath("$.errors[0].field").isEqualTo("body")
                .jsonPath("$.errors[0].code").isEqualTo("required");
        expectProblem(send(lena, Map.of("body", "x".repeat(2001))), 400, "validation_failed")
                .jsonPath("$.errors[0].code").isEqualTo("invalid_length");
        expectProblem(send(lena, Map.of("body", "Hallo", "shiftId", draft)), 400, "validation_failed")
                .jsonPath("$.errors[0].field").isEqualTo("shiftId")
                .jsonPath("$.errors[0].code").isEqualTo("not_found");
        expectProblem(get("/api/v1/conversations/" + UUID.randomUUID() + "/messages", dispatcher),
                404, "conversation_not_found");
    }

    @Test
    void conversationsStayWithinTheirAgencyAndRole() {
        var lena = activeWorker("Lena", "Hofer");
        send(lena, Map.of("body", "Hallo")).expectStatus().isCreated();
        var conversationId = ((Map<?, ?>) ((List<?>) get("/api/v1/conversations", dispatcher)
                .expectBody(Map.class).returnResult().getResponseBody().get("content")).getFirst()).get("id");
        var other = data.agency("Alpen Events");
        var otherDispatcher = login(data.account(other, Role.DISPATCHER), DASHBOARD);

        get("/api/v1/conversations", otherDispatcher)
                .expectStatus().isOk()
                .expectBody().jsonPath("$.totalElements").isEqualTo(0);
        expectProblem(get("/api/v1/conversations/" + conversationId + "/messages", otherDispatcher),
                404, "conversation_not_found");
        expectProblem(get("/api/v1/conversations", lena), 403, "forbidden");
        expectProblem(get("/api/v1/worker/conversation/messages", dispatcher), 403, "forbidden");
        var pending = signUp(agency.signupCode(), TestData.email());
        expectProblem(get("/api/v1/worker/conversation/messages", pending), 403, "worker_not_active");
        expectProblem(send(pending, Map.of("body", "Hallo")), 403, "worker_not_active");
    }

    private RestTestClient.ResponseSpec send(TokenPair worker, Map<String, Object> body) {
        return post("/api/v1/worker/conversation/messages", worker, body);
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

    private Map<String, Object> shiftRequest(Instant startsAt, int slots) {
        var request = new HashMap<String, Object>();
        request.put("clientId", clientId);
        request.put("locationId", locationId);
        request.put("title", "Lagerunterstützung");
        request.put("startsAt", startsAt.toString());
        request.put("endsAt", startsAt.plus(Duration.ofHours(8)).toString());
        request.put("hourlyRateCents", 1650);
        request.put("slots", slots);
        return request;
    }

    private UUID create(Map<String, Object> request) {
        var created = post("/api/v1/shifts", dispatcher, request)
                .expectStatus().isCreated()
                .expectBody(Map.class).returnResult().getResponseBody();
        return UUID.fromString((String) created.get("id"));
    }

    private UUID publish(Instant startsAt, int slots) {
        var request = shiftRequest(startsAt, slots);
        request.put("publish", true);
        return create(request);
    }

    private UUID claim(UUID shiftId, TokenPair worker) {
        var claimed = post("/api/v1/worker/shifts/" + shiftId + "/claim", worker)
                .expectStatus().isCreated()
                .expectBody(Map.class).returnResult().getResponseBody();
        return UUID.fromString((String) ((Map<?, ?>) claimed.get("assignment")).get("id"));
    }

    private void approve(UUID shiftId, UUID assignmentId) {
        post("/api/v1/shifts/" + shiftId + "/assignments/" + assignmentId + "/approve", dispatcher)
                .expectStatus().isOk();
    }
}
