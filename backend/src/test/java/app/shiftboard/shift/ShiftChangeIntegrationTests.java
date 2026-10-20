package app.shiftboard.shift;

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
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.client.RestTestClient;

/** Changing a shift and what the workers on it are told (ADR 0026). */
class ShiftChangeIntegrationTests extends IntegrationTest {

    // A Wednesday in the far future, 07:00 in Vienna, so that the texts below stay the same.
    static final Instant START = Instant.parse("2099-01-07T06:00:00Z");

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
    void everyFieldChangesAndTheClaimsKeepTheirSpots() {
        var shiftId = publish(START);
        var lena = activeWorker();
        var jakob = activeWorker();
        var confirmed = claim(shiftId, lena);
        claim(shiftId, jakob);
        post("/api/v1/shifts/" + shiftId + "/assignments/" + confirmed + "/approve", dispatcher)
                .expectStatus().isOk();
        var hotel = data.client(agency, "Hotel Lindenhof");
        var ballroom = data.location(agency, hotel, "Bankettsaal", "Lindenallee 3, 4040 Linz");
        var service = data.qualification(agency, "Service");
        var request = shiftRequest(START.plus(Duration.ofHours(1)));
        request.put("clientId", hotel);
        request.put("locationId", ballroom);
        request.put("title", "  Service Bankett ");
        request.put("description", "Schwarze Hose");
        request.put("endIsEstimate", true);
        request.put("hourlyRateCents", 1700);
        request.put("slots", 2);
        request.put("qualificationIds", List.of(service));

        put("/api/v1/shifts/" + shiftId, dispatcher, request)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.title").isEqualTo("Service Bankett")
                .jsonPath("$.description").isEqualTo("Schwarze Hose")
                .jsonPath("$.client.name").isEqualTo("Hotel Lindenhof")
                .jsonPath("$.location.name").isEqualTo("Bankettsaal")
                .jsonPath("$.startsAt").isEqualTo("2099-01-07T07:00:00Z")
                .jsonPath("$.endsAt").isEqualTo("2099-01-07T15:00:00Z")
                .jsonPath("$.endIsEstimate").isEqualTo(true)
                .jsonPath("$.hourlyRateCents").isEqualTo(1700)
                .jsonPath("$.slots").isEqualTo(2)
                .jsonPath("$.takenSlots").isEqualTo(2)
                .jsonPath("$.status").isEqualTo("PUBLISHED")
                .jsonPath("$.qualifications[*].name").isEqualTo(List.of("Service"));

        // Both are booked for the new time.
        assertThat(jdbc.sql("select distinct starts_at from assignment where shift_id = ?")
                .param(shiftId).query(Instant.class).list())
                .containsExactly(Instant.parse("2099-01-07T07:00:00Z"));
        for (var worker : List.of(lena, jakob)) {
            await().atMost(Duration.ofSeconds(5)).untilAsserted(() ->
                    get("/api/v1/worker/conversation/messages", worker)
                            .expectStatus().isOk()
                            .expectBody()
                            .jsonPath("$.content.length()").isEqualTo(worker == lena ? 2 : 1));
            get("/api/v1/worker/conversation/messages", worker)
                    .expectStatus().isOk()
                    .expectBody()
                    .jsonPath("$.content[0].type").isEqualTo("SYSTEM")
                    // Clients show the body: installed apps do not know the event yet.
                    .jsonPath("$.content[0].event").doesNotExist()
                    .jsonPath("$.content[0].shift.id").isEqualTo(shiftId.toString())
                    .jsonPath("$.content[0].body").isEqualTo(
                            "Die Agentur hat „Service Bankett“ geändert."
                                    + " Zeit: Mi., 7. Jan., 08:00 – ca. 16:00."
                                    + " Kunde: Hotel Lindenhof."
                                    + " Einsatzort: Bankettsaal, Lindenallee 3, 4040 Linz."
                                    + " Neuer Titel."
                                    + " Beschreibung: Schwarze Hose"
                                    + " Stundenlohn: 17,00 €."
                                    + " Qualifikationen: Service.");
        }
        assertThat(jdbc.sql("select count(*) from message where agency_id = ? and event = 'SHIFT_CHANGED'")
                .param(agency.id()).query(Integer.class).single()).isEqualTo(2);
    }

    @Test
    void onlyWhatChangedIsNamed() {
        var shiftId = publish(START);
        var lena = activeWorker();
        claim(shiftId, lena);

        var request = shiftRequest(START);
        request.put("hourlyRateCents", 1800);
        put("/api/v1/shifts/" + shiftId, dispatcher, request).expectStatus().isOk();

        await().atMost(Duration.ofSeconds(5)).untilAsserted(() ->
                get("/api/v1/worker/conversation/messages", lena)
                        .expectStatus().isOk()
                        .expectBody()
                        .jsonPath("$.content[*].body").isEqualTo(List.of(
                                "Die Agentur hat „Lagerunterstützung“ geändert. Stundenlohn: 18,00 €.")));
    }

    @Test
    void moreSpotsOrNoChangeTellNobody() {
        var shiftId = publish(START);
        var lena = activeWorker();
        claim(shiftId, lena);

        put("/api/v1/shifts/" + shiftId, dispatcher, shiftRequest(START)).expectStatus().isOk();
        var request = shiftRequest(START);
        request.put("slots", 9);
        put("/api/v1/shifts/" + shiftId, dispatcher, request)
                .expectStatus().isOk()
                .expectBody().jsonPath("$.slots").isEqualTo(9);

        assertThat(messageCount()).isZero();
    }

    @Test
    void aDraftChangesWithoutAnyNotice() {
        var request = shiftRequest(START);
        var draftId = create(request);
        request.put("title", "Inventur");

        put("/api/v1/shifts/" + draftId, dispatcher, request)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.title").isEqualTo("Inventur")
                .jsonPath("$.status").isEqualTo("DRAFT");
        assertThat(messageCount()).isZero();
    }

    @Test
    void spotsCannotDropBelowTheClaimsThatHoldOne() {
        var shiftId = publish(START);
        claim(shiftId, activeWorker());
        claim(shiftId, activeWorker());

        var request = shiftRequest(START);
        request.put("slots", 1);
        expectProblem(put("/api/v1/shifts/" + shiftId, dispatcher, request), 400, "validation_failed")
                .jsonPath("$.errors[0].field").isEqualTo("slots")
                .jsonPath("$.errors[0].code").isEqualTo("below_taken");
    }

    @Test
    void aNewTimeThatDoubleBooksAWorkerIsRejected() {
        var early = publish(START);
        var late = publish(START.plus(Duration.ofHours(10)));
        var lena = activeWorker();
        claim(early, lena);
        claim(late, lena);

        expectProblem(put("/api/v1/shifts/" + early, dispatcher, shiftRequest(START.plus(Duration.ofHours(6)))), 409,
                "shift_overlap");

        get("/api/v1/shifts/" + early, dispatcher)
                .expectStatus().isOk()
                .expectBody().jsonPath("$.startsAt").isEqualTo(START.toString());
        assertThat(messageCount()).isZero();
        // A claim given up is not in the way.
        post("/api/v1/worker/shifts/" + late + "/cancel", lena).expectStatus().isOk();
        put("/api/v1/shifts/" + early, dispatcher, shiftRequest(START.plus(Duration.ofHours(6)))).expectStatus().isOk();
    }

    @Test
    void aShiftThatStartedOrWasCancelledStaysAsItIs() {
        var cancelled = publish(START);
        post("/api/v1/shifts/" + cancelled + "/cancel", dispatcher).expectStatus().isOk();
        expectProblem(put("/api/v1/shifts/" + cancelled, dispatcher, shiftRequest(START)), 409, "shift_not_editable");

        var started = Instant.now().minus(Duration.ofHours(1)).truncatedTo(ChronoUnit.SECONDS);
        var running = publish(started);
        var request = shiftRequest(started);
        request.put("hourlyRateCents", 1800);
        expectProblem(put("/api/v1/shifts/" + running, dispatcher, request), 409, "shift_not_editable");
    }

    @Test
    void aChangeIsCheckedLikeANewShift() {
        var shiftId = publish(START);
        var otherClient = data.client(data.agency("Alpen Events"), "Gipfelarena");

        var request = shiftRequest(START);
        request.put("endsAt", START.toString());
        expectProblem(put("/api/v1/shifts/" + shiftId, dispatcher, request), 400, "validation_failed")
                .jsonPath("$.errors[0].field").isEqualTo("endsAt")
                .jsonPath("$.errors[0].code").isEqualTo("before_start");

        request = shiftRequest(START);
        request.put("clientId", otherClient);
        expectProblem(put("/api/v1/shifts/" + shiftId, dispatcher, request), 400, "validation_failed")
                .jsonPath("$.errors[0].field").isEqualTo("clientId")
                .jsonPath("$.errors[0].code").isEqualTo("not_found");

        request = shiftRequest(START);
        request.remove("title");
        expectProblem(put("/api/v1/shifts/" + shiftId, dispatcher, request), 400, "validation_failed")
                .jsonPath("$.errors[0].field").isEqualTo("title")
                .jsonPath("$.errors[0].code").isEqualTo("required");
    }

    @Test
    void onlyTheAgencysDispatchersCanChangeItsShifts() {
        var shiftId = publish(START);
        var otherAgency = data.agency("Alpen Events");
        var otherDispatcher = login(data.account(otherAgency, Role.DISPATCHER), DASHBOARD);

        expectProblem(put("/api/v1/shifts/" + shiftId, otherDispatcher, shiftRequest(START)), 404, "shift_not_found");
        expectProblem(put("/api/v1/shifts/" + shiftId, activeWorker(), shiftRequest(START)), 403, "forbidden");
    }

    private int messageCount() {
        return jdbc.sql("select count(*) from message where agency_id = ?")
                .param(agency.id()).query(Integer.class).single();
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

    private RestTestClient.ResponseSpec put(String uri, TokenPair tokens, Map<String, Object> body) {
        return client.put().uri(uri)
                .headers(headers -> headers.setBearerAuth(tokens.accessToken()))
                .contentType(MediaType.APPLICATION_JSON)
                .body(body)
                .exchange();
    }
}
