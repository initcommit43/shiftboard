package app.shiftboard.assignment;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Duration;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.Callable;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.Executors;

import app.shiftboard.IntegrationTest;
import app.shiftboard.TestData;
import app.shiftboard.identity.Role;
import app.shiftboard.identity.TokenPair;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.web.servlet.client.RestTestClient;

class WorkerShiftIntegrationTests extends IntegrationTest {

    static final Instant TOMORROW = Instant.now().plus(Duration.ofDays(1)).truncatedTo(ChronoUnit.SECONDS);

    TestData.Agency agency;

    TokenPair dispatcher;

    UUID clientId;

    UUID locationId;

    TokenPair worker;

    @BeforeEach
    void createAgencyWithDispatcherClientAndActiveWorker() {
        agency = data.agency("Donau Personal");
        dispatcher = login(data.account(agency, Role.DISPATCHER), DASHBOARD);
        clientId = data.client(agency, "Nordlicht Logistik");
        locationId = data.location(agency, clientId, "Zentrallager Linz", "Hafenstraße 12, 4020 Linz");
        worker = activeWorker();
    }

    @Test
    void listsThePublishedShiftsThatHaveNotStartedEarliestStartFirst() {
        var lager = data.qualification(agency, "Lager");
        var later = shiftRequest("Später", TOMORROW.plus(Duration.ofDays(2)), 4, 5);
        later.put("publish", true);
        create(later);
        var sooner = shiftRequest("Früher", TOMORROW, 8, 5);
        sooner.put("publish", true);
        sooner.put("description", "Sicherheitsschuhe mitbringen.");
        sooner.put("endIsEstimate", true);
        sooner.put("qualificationIds", List.of(lager));
        var soonerId = create(sooner);
        var full = publish("Voll", TOMORROW.plus(Duration.ofDays(1)), 4, 1);
        claim(full, activeWorker()).expectStatus().isCreated();
        create(shiftRequest("Entwurf", TOMORROW, 8, 5));
        var running = shiftRequest("Läuft gerade", Instant.now().minus(Duration.ofHours(1)), 4, 5);
        running.put("publish", true);
        create(running);
        var cancelled = publish("Abgesagt", TOMORROW, 8, 5);
        jdbc.sql("update shift set status = 'CANCELLED' where id = ?").param(cancelled).update();

        get("/api/v1/worker/shifts", worker)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.page").isEqualTo(0)
                .jsonPath("$.size").isEqualTo(20)
                .jsonPath("$.totalElements").isEqualTo(3)
                .jsonPath("$.totalPages").isEqualTo(1)
                .jsonPath("$.content[*].title").isEqualTo(List.of("Früher", "Voll", "Später"))
                .jsonPath("$.content[0].id").isEqualTo(soonerId.toString())
                .jsonPath("$.content[0].description").isEqualTo("Sicherheitsschuhe mitbringen.")
                .jsonPath("$.content[0].status").isEqualTo("PUBLISHED")
                .jsonPath("$.content[0].client.id").isEqualTo(clientId.toString())
                .jsonPath("$.content[0].client.name").isEqualTo("Nordlicht Logistik")
                .jsonPath("$.content[0].location.name").isEqualTo("Zentrallager Linz")
                .jsonPath("$.content[0].location.address").isEqualTo("Hafenstraße 12, 4020 Linz")
                .jsonPath("$.content[0].startsAt").isEqualTo(TOMORROW.toString())
                .jsonPath("$.content[0].endsAt").isEqualTo(TOMORROW.plus(Duration.ofHours(8)).toString())
                .jsonPath("$.content[0].endIsEstimate").isEqualTo(true)
                .jsonPath("$.content[0].hourlyRateCents").isEqualTo(1650)
                .jsonPath("$.content[0].slots").isEqualTo(5)
                .jsonPath("$.content[0].takenSlots").isEqualTo(0)
                .jsonPath("$.content[0].qualifications[*].name").isEqualTo(List.of("Lager"))
                .jsonPath("$.content[0].contact.name").isEqualTo("Anna Berger")
                .jsonPath("$.content[0].contact.phone").isEqualTo("+43 660 5550191")
                .jsonPath("$.content[0].contact.email").doesNotExist()
                .jsonPath("$.content[0].assignment").doesNotExist()
                .jsonPath("$.content[0].createdAt").doesNotExist()
                // Full, and still listed. The claim of the other worker is not this worker's.
                .jsonPath("$.content[1].slots").isEqualTo(1)
                .jsonPath("$.content[1].takenSlots").isEqualTo(1)
                .jsonPath("$.content[1].assignment").doesNotExist()
                .jsonPath("$.content[2].description").doesNotExist();

        get("/api/v1/worker/shifts?page=1&size=2", worker)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalPages").isEqualTo(2)
                .jsonPath("$.content[*].title").isEqualTo(List.of("Später"));
    }

    @Test
    void showsAShiftAlsoAfterItStartedButNeverADraft() {
        var running = shiftRequest("Läuft gerade", Instant.now().minus(Duration.ofHours(1)), 4, 5);
        running.put("publish", true);
        var runningId = create(running);
        var draft = create(shiftRequest("Entwurf", TOMORROW, 8, 5));

        get("/api/v1/worker/shifts/" + runningId, worker)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.id").isEqualTo(runningId.toString())
                .jsonPath("$.title").isEqualTo("Läuft gerade")
                .jsonPath("$.contact.name").isEqualTo("Anna Berger")
                .jsonPath("$.assignment").doesNotExist();
        expectProblem(get("/api/v1/worker/shifts/" + draft, worker), 404, "shift_not_found");
        expectProblem(get("/api/v1/worker/shifts/" + UUID.randomUUID(), worker), 404, "shift_not_found");
    }

    @Test
    void aContactWithoutAPhoneNumberIsShownByNameOnly() {
        var quietDispatcher = login(data.account(agency, Role.DISPATCHER, "Markus", "Huber", null), DASHBOARD);
        var request = shiftRequest("Inventur", TOMORROW, 8, 5);
        request.put("publish", true);
        var id = create(request, quietDispatcher);

        get("/api/v1/worker/shifts/" + id, worker)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.contact.name").isEqualTo("Markus Huber")
                .jsonPath("$.contact.phone").doesNotExist();
    }

    @Test
    void aClaimTakesASpotAndWaitsForTheAgency() {
        var shiftId = publish("Lagerunterstützung", TOMORROW, 8, 5);

        var claimed = claim(shiftId, worker)
                .expectStatus().isCreated()
                .expectBody(Map.class).returnResult().getResponseBody();

        var assignment = (Map<?, ?>) claimed.get("assignment");
        assertThat(claimed.get("id")).isEqualTo(shiftId.toString());
        assertThat(claimed.get("takenSlots")).isEqualTo(1);
        assertThat(assignment.get("status")).isEqualTo("PENDING");
        assertThat(Instant.parse((String) assignment.get("claimedAt"))).isBefore(Instant.now().plusSeconds(1));
        var assignmentId = UUID.fromString((String) assignment.get("id"));
        assertThat(events.all()).contains(new ShiftClaimed(agency.id(), assignmentId, shiftId, workerId(worker)));

        var stored = jdbc.sql("select * from assignment where id = ?").param(assignmentId).query().singleRow();
        assertThat(stored.get("agency_id")).isEqualTo(agency.id());
        assertThat(stored.get("shift_id")).isEqualTo(shiftId);
        assertThat(stored.get("worker_id")).isEqualTo(workerId(worker));
        assertThat(stored.get("status")).isEqualTo("PENDING");
        assertThat(stored.get("decided_at")).isNull();

        // The worker sees the claim on the shift, in the list and in the detail; a colleague does not.
        get("/api/v1/worker/shifts", worker)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[0].takenSlots").isEqualTo(1)
                .jsonPath("$.content[0].assignment.id").isEqualTo(assignmentId.toString())
                .jsonPath("$.content[0].assignment.status").isEqualTo("PENDING");
        get("/api/v1/worker/shifts/" + shiftId, worker)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.assignment.status").isEqualTo("PENDING");
        get("/api/v1/worker/shifts/" + shiftId, activeWorker())
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.takenSlots").isEqualTo(1)
                .jsonPath("$.assignment").doesNotExist();
        // The dispatcher sees the spot as taken.
        get("/api/v1/shifts", dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[0].takenSlots").isEqualTo(1);
    }

    @Test
    void aShiftIsClaimedOnlyOnce() {
        var shiftId = publish("Lagerunterstützung", TOMORROW, 8, 5);
        claim(shiftId, worker).expectStatus().isCreated();

        expectProblem(claim(shiftId, worker), 409, "shift_already_claimed");

        assertThat(takenSlots(shiftId)).isEqualTo(1);
        assertThat(assignmentCount(shiftId)).isEqualTo(1);
    }

    @Test
    void aFullShiftCannotBeClaimed() {
        var shiftId = publish("Staplerfahrer:in", TOMORROW, 8, 1);
        claim(shiftId, activeWorker()).expectStatus().isCreated();

        expectProblem(claim(shiftId, worker), 409, "shift_full");

        assertThat(takenSlots(shiftId)).isEqualTo(1);
        assertThat(assignmentCount(shiftId)).isEqualTo(1);
    }

    @Test
    void aShiftThatStartedWasCancelledOrIsADraftCannotBeClaimed() {
        var running = shiftRequest("Läuft gerade", Instant.now().minus(Duration.ofMinutes(1)), 4, 5);
        running.put("publish", true);
        var runningId = create(running);
        var cancelled = publish("Abgesagt", TOMORROW, 8, 5);
        jdbc.sql("update shift set status = 'CANCELLED' where id = ?").param(cancelled).update();
        var draft = create(shiftRequest("Entwurf", TOMORROW, 8, 5));

        expectProblem(claim(runningId, worker), 409, "shift_started");
        expectProblem(claim(cancelled, worker), 409, "shift_not_open");
        expectProblem(claim(draft, worker), 404, "shift_not_found");
        expectProblem(claim(UUID.randomUUID(), worker), 404, "shift_not_found");

        assertThat(takenSlots(runningId)).isZero();
        assertThat(takenSlots(cancelled)).isZero();
        assertThat(takenSlots(draft)).isZero();
    }

    @Test
    void aShiftThatOverlapsAClaimedOneCannotBeClaimed() {
        var morning = publish("Frühschicht", TOMORROW, 8, 5);
        var overlapping = publish("Mittagsschicht", TOMORROW.plus(Duration.ofHours(7)), 4, 5);
        var rightAfter = publish("Spätschicht", TOMORROW.plus(Duration.ofHours(8)), 4, 5);
        claim(morning, worker).expectStatus().isCreated();

        expectProblem(claim(overlapping, worker), 409, "shift_overlap");
        // The slot the failed claim took for a moment is free again.
        assertThat(takenSlots(overlapping)).isZero();
        assertThat(assignmentCount(overlapping)).isZero();

        // A shift that starts when the other one ends does not overlap it.
        claim(rightAfter, worker).expectStatus().isCreated();

        // A claim that no longer holds a spot does not block the time either.
        jdbc.sql("update assignment set status = 'REJECTED' where shift_id = ?").param(morning).update();
        expectProblem(claim(overlapping, worker), 409, "shift_overlap");
        jdbc.sql("update assignment set status = 'REJECTED' where shift_id = ?").param(rightAfter).update();
        claim(overlapping, worker).expectStatus().isCreated();
    }

    @Test
    void ofSeveralWorkersClaimingTheLastSpotAtOnceExactlyOneGetsIt() throws Exception {
        var shiftId = publish("Staplerfahrer:in", TOMORROW, 8, 1);
        var claims = new ArrayList<Callable<Map<?, ?>>>();
        for (var i = 0; i < 6; i++) {
            var colleague = activeWorker();
            claims.add(() -> claim(shiftId, colleague).expectBody(Map.class).returnResult().getResponseBody());
        }

        var results = atOnce(claims);

        assertThat(results).filteredOn(result -> result.containsKey("assignment")).hasSize(1);
        assertThat(results).filteredOn(result -> "shift_full".equals(result.get("code"))).hasSize(5);
        assertThat(takenSlots(shiftId)).isEqualTo(1);
        assertThat(assignmentCount(shiftId)).isEqualTo(1);
    }

    @Test
    void aWorkerClaimingTwoOverlappingShiftsAtOnceGetsOnlyOne() throws Exception {
        var first = publish("Frühschicht", TOMORROW, 8, 5);
        var second = publish("Mittagsschicht", TOMORROW.plus(Duration.ofHours(4)), 8, 5);

        List<Callable<Map<?, ?>>> claims = List.of(
                () -> claim(first, worker).expectBody(Map.class).returnResult().getResponseBody(),
                () -> claim(second, worker).expectBody(Map.class).returnResult().getResponseBody());

        var results = atOnce(claims);

        assertThat(results).filteredOn(result -> result.containsKey("assignment")).hasSize(1);
        assertThat(results).filteredOn(result -> "shift_overlap".equals(result.get("code"))).hasSize(1);
        assertThat(takenSlots(first) + takenSlots(second)).isEqualTo(1);
        assertThat(assignmentCount(first) + assignmentCount(second)).isEqualTo(1);
    }

    @Test
    void listsTheShiftsTheWorkerClaimedEarliestStartFirst() {
        var later = publish("Später", TOMORROW.plus(Duration.ofDays(2)), 4, 5);
        var sooner = publish("Früher", TOMORROW, 8, 5);
        var notClaimed = publish("Nicht meine", TOMORROW.plus(Duration.ofDays(1)), 4, 5);
        claim(later, worker).expectStatus().isCreated();
        claim(sooner, worker).expectStatus().isCreated();
        claim(notClaimed, activeWorker()).expectStatus().isCreated();
        // What became of a claim does not matter, and neither does what became of the shift.
        jdbc.sql("update assignment set status = 'REJECTED', decided_at = now() where shift_id = ?")
                .param(later).update();
        jdbc.sql("update shift set status = 'CANCELLED' where id = ?").param(later).update();

        get("/api/v1/worker/my-shifts", worker)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.page").isEqualTo(0)
                .jsonPath("$.size").isEqualTo(20)
                .jsonPath("$.totalElements").isEqualTo(2)
                .jsonPath("$.totalPages").isEqualTo(1)
                .jsonPath("$.content[*].title").isEqualTo(List.of("Früher", "Später"))
                .jsonPath("$.content[*].assignment.status").isEqualTo(List.of("PENDING", "REJECTED"))
                .jsonPath("$.content[*].status").isEqualTo(List.of("PUBLISHED", "CANCELLED"))
                .jsonPath("$.content[0].id").isEqualTo(sooner.toString())
                .jsonPath("$.content[0].takenSlots").isEqualTo(1)
                .jsonPath("$.content[0].contact.name").isEqualTo("Anna Berger");

        get("/api/v1/worker/my-shifts?page=1&size=1", worker)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalPages").isEqualTo(2)
                .jsonPath("$.content[*].title").isEqualTo(List.of("Später"));

        get("/api/v1/worker/my-shifts", activeWorker())
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalElements").isEqualTo(0)
                .jsonPath("$.content").isEmpty();
    }

    @Test
    void aWorkerOfAnotherAgencyNeitherSeesNorClaimsTheShift() {
        var shiftId = publish("Lagerunterstützung", TOMORROW, 8, 5);
        var otherAgency = data.agency("Alpen Events");
        var otherDispatcher = login(data.account(otherAgency, Role.DISPATCHER), DASHBOARD);
        var otherWorker = activeWorker(otherAgency, otherDispatcher);

        get("/api/v1/worker/shifts", otherWorker)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalElements").isEqualTo(0)
                .jsonPath("$.content").isEmpty();
        expectProblem(get("/api/v1/worker/shifts/" + shiftId, otherWorker), 404, "shift_not_found");
        expectProblem(claim(shiftId, otherWorker), 404, "shift_not_found");
        assertThat(takenSlots(shiftId)).isZero();
    }

    @Test
    void onlyActiveWorkersHaveAccess() {
        var shiftId = publish("Lagerunterstützung", TOMORROW, 8, 5);
        var pending = signUp(agency.signupCode(), TestData.email());
        var rejected = signUp(agency.signupCode(), TestData.email());
        post("/api/v1/workers/" + workerId(rejected) + "/reject", dispatcher).expectStatus().isOk();

        for (var tokens : List.of(pending, rejected)) {
            expectProblem(get("/api/v1/worker/shifts", tokens), 403, "worker_not_active");
            expectProblem(get("/api/v1/worker/shifts/" + shiftId, tokens), 403, "worker_not_active");
            expectProblem(claim(shiftId, tokens), 403, "worker_not_active");
            expectProblem(get("/api/v1/worker/my-shifts", tokens), 403, "worker_not_active");
        }
        expectProblem(get("/api/v1/worker/shifts", dispatcher), 403, "forbidden");
        expectProblem(get("/api/v1/worker/shifts/" + shiftId, dispatcher), 403, "forbidden");
        expectProblem(claim(shiftId, dispatcher), 403, "forbidden");
        expectProblem(get("/api/v1/worker/my-shifts", dispatcher), 403, "forbidden");
        expectProblem(client.get().uri("/api/v1/worker/shifts").exchange(), 401, "unauthenticated");
        assertThat(takenSlots(shiftId)).isZero();
    }

    /** Signs a worker up in the agency of the test and approves the signup. */
    private TokenPair activeWorker() {
        return activeWorker(agency, dispatcher);
    }

    private TokenPair activeWorker(TestData.Agency ofAgency, TokenPair approvedBy) {
        var tokens = signUp(ofAgency.signupCode(), TestData.email());
        post("/api/v1/workers/" + workerId(tokens) + "/approve", approvedBy).expectStatus().isOk();
        return tokens;
    }

    private Map<String, Object> shiftRequest(String title, Instant startsAt, int hours, int slots) {
        var request = new HashMap<String, Object>();
        request.put("clientId", clientId);
        request.put("locationId", locationId);
        request.put("title", title);
        request.put("startsAt", startsAt.toString());
        request.put("endsAt", startsAt.plus(Duration.ofHours(hours)).toString());
        request.put("hourlyRateCents", 1650);
        request.put("slots", slots);
        return request;
    }

    /** Creates the shift as the dispatcher of the test and returns its id. */
    private UUID create(Map<String, Object> request) {
        return create(request, dispatcher);
    }

    private UUID create(Map<String, Object> request, TokenPair createdBy) {
        var created = post("/api/v1/shifts", createdBy, request)
                .expectStatus().isCreated()
                .expectBody(Map.class).returnResult().getResponseBody();
        return UUID.fromString((String) created.get("id"));
    }

    /** Creates a published shift and returns its id. */
    private UUID publish(String title, Instant startsAt, int hours, int slots) {
        var request = shiftRequest(title, startsAt, hours, slots);
        request.put("publish", true);
        return create(request);
    }

    private RestTestClient.ResponseSpec claim(UUID shiftId, TokenPair tokens) {
        return post("/api/v1/worker/shifts/" + shiftId + "/claim", tokens);
    }

    /** Runs the calls at the same moment, each on its own thread, and returns what they answered. */
    private static <T> List<T> atOnce(List<Callable<T>> calls) throws Exception {
        var start = new CountDownLatch(1);
        try (var executor = Executors.newFixedThreadPool(calls.size())) {
            var pending = calls.stream()
                    .map(call -> executor.submit(() -> {
                        start.await();
                        return call.call();
                    }))
                    .toList();
            start.countDown();
            var results = new ArrayList<T>();
            for (var result : pending) {
                results.add(result.get());
            }
            return results;
        }
    }

    private int takenSlots(UUID shiftId) {
        return jdbc.sql("select taken_slots from shift where id = ?").param(shiftId).query(Integer.class).single();
    }

    private int assignmentCount(UUID shiftId) {
        return jdbc.sql("select count(*) from assignment where shift_id = ?")
                .param(shiftId).query(Integer.class).single();
    }
}
