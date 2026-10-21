package app.shiftboard.notification.internal;

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
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.client.RestTestClient;

class PushNotificationIntegrationTests extends IntegrationTest {

    static final Instant IN_THREE_DAYS = Instant.now().plus(Duration.ofDays(3)).truncatedTo(ChronoUnit.SECONDS);

    @Autowired
    RecordingPushSender push;

    TestData.Agency agency;

    TokenPair dispatcher;

    UUID clientId;

    UUID locationId;

    @BeforeEach
    void createAgency() {
        agency = data.agency("Donau Personal");
        dispatcher = login(data.account(agency, Role.DISPATCHER), DASHBOARD);
        clientId = data.client(agency, "Nordlicht Logistik");
        locationId = data.location(agency, clientId, "Zentrallager Linz", "Hafenstraße 12, 4020 Linz");
    }

    @Test
    void aNewShiftReachesActiveWorkersWhoHaveNotPaused() {
        var lena = device(activeWorker());
        var jakob = activeWorker();
        var jakobDevice = device(jakob);
        var pending = device(signUp(agency.signupCode(), TestData.email()));
        put("/api/v1/worker/notification-settings", jakob, Map.of("newShiftsPaused", true))
                .expectStatus().isOk()
                .expectBody().jsonPath("$.newShiftsPaused").isEqualTo(true);

        var shiftId = publish(IN_THREE_DAYS);

        await().atMost(Duration.ofSeconds(5)).until(() -> !push.sentTo(lena).isEmpty());
        var sent = push.sentTo(lena).getFirst();
        assertThat(sent.title()).isEqualTo("Neue Schicht: Lagerunterstützung");
        assertThat(sent.body()).endsWith(" · Nordlicht Logistik");
        assertThat(sent.data()).containsEntry("type", "SHIFT_PUBLISHED").containsEntry("shiftId", shiftId.toString());
        assertThat(push.sentTo(jakobDevice)).isEmpty();
        assertThat(push.sentTo(pending)).isEmpty();

        // A draft goes out when it is published, not before.
        var draft = create(shiftRequest(IN_THREE_DAYS.plus(Duration.ofDays(1))));
        post("/api/v1/shifts/" + draft + "/publish", dispatcher).expectStatus().isOk();
        await().atMost(Duration.ofSeconds(5)).until(() -> push.sentTo(lena).size() == 2);
    }

    @Test
    void decisionsAndCancellationsByTheAgencyReachTheWorkerEvenWhilePaused() {
        var worker = activeWorker();
        var device = device(worker);
        put("/api/v1/worker/notification-settings", worker, Map.of("newShiftsPaused", true)).expectStatus().isOk();
        var first = publish(IN_THREE_DAYS);
        var second = publish(IN_THREE_DAYS.plus(Duration.ofDays(1)));
        var third = publish(IN_THREE_DAYS.plus(Duration.ofDays(2)));
        var confirmed = claim(first, worker);
        var rejected = claim(second, worker);
        claim(third, worker);

        post(action(first, confirmed, "approve"), dispatcher).expectStatus().isOk();
        post(action(second, rejected, "reject"), dispatcher).expectStatus().isOk();
        post("/api/v1/shifts/" + third + "/cancel", dispatcher).expectStatus().isOk();
        post(action(first, confirmed, "remove"), dispatcher, Map.of("reason", "Doppelt gebucht"))
                .expectStatus().isOk();

        await().atMost(Duration.ofSeconds(5)).until(() -> push.sentTo(device).size() == 4);
        assertThat(push.sentTo(device)).extracting(RecordingPushSender.Sent::title).containsExactlyInAnyOrder(
                "Schicht bestätigt", "Anfrage abgelehnt", "Schicht abgesagt", "Du bist nicht mehr eingeteilt");
        assertThat(push.sentTo(device)).allSatisfy(sent ->
                assertThat(sent.body()).startsWith("Lagerunterstützung · "));
    }

    @Test
    void aChangeOfTheShiftReachesTheWorkersOnIt() {
        var worker = activeWorker();
        var device = device(worker);
        var bystander = device(activeWorker());
        var shiftId = publish(IN_THREE_DAYS);
        claim(shiftId, worker);
        await().atMost(Duration.ofSeconds(5)).until(() -> push.sentTo(bystander).size() == 1);

        var request = shiftRequest(IN_THREE_DAYS);
        request.put("hourlyRateCents", 1800);
        put("/api/v1/shifts/" + shiftId, dispatcher, request).expectStatus().isOk();

        await().atMost(Duration.ofSeconds(5)).until(() -> push.sentTo(device).size() == 2);
        var sent = push.sentTo(device).getLast();
        assertThat(sent.title()).isEqualTo("Schicht geändert");
        assertThat(sent.body()).startsWith("Lagerunterstützung · ");
        assertThat(sent.data()).containsEntry("type", "SHIFT_CHANGED").containsEntry("shiftId", shiftId.toString());
        // Only the new shift reached the worker without a spot.
        assertThat(push.sentTo(bystander)).hasSize(1);
    }

    @Test
    void droppingOutYourselfSendsNothing() {
        var worker = activeWorker();
        var device = device(worker);
        var shiftId = publish(IN_THREE_DAYS);
        claim(shiftId, worker);

        post("/api/v1/worker/shifts/" + shiftId + "/cancel", worker).expectStatus().isOk();
        // A later push proves the earlier events were handled.
        var other = publish(IN_THREE_DAYS.plus(Duration.ofDays(1)));
        post(action(other, claim(other, worker), "approve"), dispatcher).expectStatus().isOk();

        await().atMost(Duration.ofSeconds(5)).until(() ->
                push.sentTo(device).stream().anyMatch(sent -> sent.title().equals("Schicht bestätigt")));
        assertThat(push.sentTo(device)).extracting(RecordingPushSender.Sent::title)
                .doesNotContain("Schicht abgesagt", "Du bist nicht mehr eingeteilt");
    }

    @Test
    void messagesFromTheAgencyReachTheWorker() {
        var worker = activeWorker();
        var device = device(worker);
        var shiftId = publish(IN_THREE_DAYS);
        post(action(shiftId, claim(shiftId, worker), "approve"), dispatcher).expectStatus().isOk();
        post("/api/v1/worker/conversation/messages", worker, Map.of("body", "Gibt es Parkplätze?"))
                .expectStatus().isCreated();
        var conversationId = ((Map<?, ?>) ((List<?>) get("/api/v1/conversations", dispatcher)
                .expectBody(Map.class).returnResult().getResponseBody().get("content")).getFirst()).get("id");

        post("/api/v1/conversations/" + conversationId + "/messages", dispatcher, Map.of("body", "Ja, bei Halle 2."))
                .expectStatus().isCreated();
        post("/api/v1/shifts/" + shiftId + "/broadcast", dispatcher, Map.of("body", "Treffpunkt Tor 5."))
                .expectStatus().isCreated();

        await().atMost(Duration.ofSeconds(5)).until(() -> push.sentTo(device).stream()
                .filter(sent -> sent.title().equals("Nachricht von Donau Personal")).count() == 2);
        assertThat(push.sentTo(device)).filteredOn(sent -> sent.title().startsWith("Nachricht"))
                .extracting(RecordingPushSender.Sent::body)
                .containsExactlyInAnyOrder("Ja, bei Halle 2.", "Treffpunkt Tor 5.");
        assertThat(push.sentTo(device)).filteredOn(sent -> "BROADCAST".equals(sent.data().get("type")))
                .singleElement()
                .satisfies(sent -> assertThat(sent.data()).containsEntry("shiftId", shiftId.toString()));
        assertThat(push.sent()).noneSatisfy(sent -> assertThat(sent.body()).isEqualTo("Gibt es Parkplätze?"));
    }

    @Test
    void aTokenBelongsToOneWorkerAndIsForgottenWhenUnknown() {
        var lena = activeWorker();
        var jakob = activeWorker();
        var token = "device-" + UUID.randomUUID();
        register(lena, token).expectStatus().isNoContent();
        register(jakob, token).expectStatus().isNoContent();
        register(jakob, token).expectStatus().isNoContent();

        assertThat(jdbc.sql("select worker_id from push_token where token = ?").param(token)
                .query(UUID.class).list()).containsExactly(workerId(jakob));

        // Only the owner removes it.
        client.delete().uri("/api/v1/worker/push-tokens/{token}", token)
                .headers(headers -> headers.setBearerAuth(lena.accessToken())).exchange()
                .expectStatus().isNoContent();
        assertThat(tokenCount(token)).isOne();

        push.forget(token);
        publish(IN_THREE_DAYS);
        await().atMost(Duration.ofSeconds(5)).until(() -> tokenCount(token) == 0);

        var other = "device-" + UUID.randomUUID();
        register(jakob, other).expectStatus().isNoContent();
        client.delete().uri("/api/v1/worker/push-tokens/{token}", other)
                .headers(headers -> headers.setBearerAuth(jakob.accessToken())).exchange()
                .expectStatus().isNoContent();
        assertThat(tokenCount(other)).isZero();

        expectProblem(post("/api/v1/worker/push-tokens", jakob, Map.of("token", "x")), 400, "validation_failed")
                .jsonPath("$.errors[0].field").isEqualTo("platform");
        expectProblem(post("/api/v1/worker/push-tokens", dispatcher, Map.of("token", "x", "platform", "IOS")),
                403, "forbidden");
    }

    @Test
    void notificationSettingsAreTheWorkersOwn() {
        var worker = activeWorker();

        get("/api/v1/worker/notification-settings", worker)
                .expectStatus().isOk()
                .expectBody().jsonPath("$.newShiftsPaused").isEqualTo(false);
        put("/api/v1/worker/notification-settings", worker, Map.of("newShiftsPaused", true)).expectStatus().isOk();
        put("/api/v1/worker/notification-settings", worker, Map.of("newShiftsPaused", false))
                .expectStatus().isOk()
                .expectBody().jsonPath("$.newShiftsPaused").isEqualTo(false);

        expectProblem(put("/api/v1/worker/notification-settings", worker, Map.of()), 400, "validation_failed");
        var pending = signUp(agency.signupCode(), TestData.email());
        expectProblem(get("/api/v1/worker/notification-settings", pending), 403, "worker_not_active");
        expectProblem(get("/api/v1/worker/notification-settings", dispatcher), 403, "forbidden");
    }

    @Test
    void anAdminSwitchesTheContactButtonAndWorkersSeeIt() {
        var admin = login(data.account(agency, Role.ADMIN), DASHBOARD);
        var worker = activeWorker();

        get("/api/v1/agency/features", dispatcher)
                .expectStatus().isOk()
                .expectBody().jsonPath("$.contactButton").isEqualTo(false);
        get("/api/v1/me", worker)
                .expectStatus().isOk()
                .expectBody().jsonPath("$.agency.features.contactButton").isEqualTo(false);
        expectProblem(put("/api/v1/agency/features", dispatcher, Map.of("contactButton", true)), 403, "forbidden");

        put("/api/v1/agency/features", admin, Map.of("contactButton", true))
                .expectStatus().isOk()
                .expectBody().jsonPath("$.contactButton").isEqualTo(true);

        get("/api/v1/me", worker)
                .expectStatus().isOk()
                .expectBody().jsonPath("$.agency.features.contactButton").isEqualTo(true);
        expectProblem(put("/api/v1/agency/features", admin, Map.of()), 400, "validation_failed");
        expectProblem(get("/api/v1/agency/features", worker), 403, "forbidden");
    }

    private RestTestClient.ResponseSpec put(String uri, TokenPair tokens, Map<String, Object> body) {
        return client.put().uri(uri)
                .headers(headers -> headers.setBearerAuth(tokens.accessToken()))
                .contentType(MediaType.APPLICATION_JSON)
                .body(body)
                .exchange();
    }

    private RestTestClient.ResponseSpec register(TokenPair worker, String token) {
        return post("/api/v1/worker/push-tokens", worker, Map.of("token", token, "platform", "ANDROID"));
    }

    /** Registers a new device for the worker and returns its token. */
    private String device(TokenPair worker) {
        var token = "device-" + UUID.randomUUID();
        register(worker, token).expectStatus().isNoContent();
        return token;
    }

    private int tokenCount(String token) {
        return jdbc.sql("select count(*) from push_token where token = ?").param(token).query(Integer.class).single();
    }

    private TokenPair activeWorker() {
        var tokens = signUp(agency.signupCode(), TestData.email());
        post("/api/v1/workers/" + workerId(tokens) + "/approve", dispatcher).expectStatus().isOk();
        return tokens;
    }

    private Map<String, Object> shiftRequest(Instant startsAt) {
        var request = new HashMap<String, Object>();
        request.put("clientId", clientId);
        request.put("locationId", locationId);
        request.put("title", "Lagerunterstützung");
        request.put("startsAt", startsAt.toString());
        request.put("endsAt", startsAt.plus(Duration.ofHours(8)).toString());
        request.put("hourlyRateCents", 1650);
        request.put("slots", 5);
        return request;
    }

    private UUID create(Map<String, Object> request) {
        var created = post("/api/v1/shifts", dispatcher, request)
                .expectStatus().isCreated()
                .expectBody(Map.class).returnResult().getResponseBody();
        return UUID.fromString((String) created.get("id"));
    }

    private UUID publish(Instant startsAt) {
        var request = shiftRequest(startsAt);
        request.put("publish", true);
        return create(request);
    }

    private UUID claim(UUID shiftId, TokenPair worker) {
        var claimed = post("/api/v1/worker/shifts/" + shiftId + "/claim", worker)
                .expectStatus().isCreated()
                .expectBody(Map.class).returnResult().getResponseBody();
        return UUID.fromString((String) ((Map<?, ?>) claimed.get("assignment")).get("id"));
    }

    private static String action(UUID shiftId, UUID assignmentId, String action) {
        return "/api/v1/shifts/" + shiftId + "/assignments/" + assignmentId + "/" + action;
    }
}
