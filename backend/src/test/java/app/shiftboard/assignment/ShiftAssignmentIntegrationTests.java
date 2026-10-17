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
import app.shiftboard.shift.ShiftCompleted;
import app.shiftboard.shift.internal.ShiftCompletionJob;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.web.servlet.client.RestTestClient;

/**
 * The agency's side of the claims: reviewing them, deciding on them, removing workers, calling
 * off shifts and completing them.
 */
class ShiftAssignmentIntegrationTests extends IntegrationTest {

    static final Instant IN_THREE_DAYS = Instant.now().plus(Duration.ofDays(3)).truncatedTo(ChronoUnit.SECONDS);

    @Autowired
    ShiftCompletionJob completionJob;

    TestData.Agency agency;

    TokenPair dispatcher;

    UUID clientId;

    UUID locationId;

    @BeforeEach
    void createAgencyWithDispatcherAndClient() {
        agency = data.agency("Donau Personal");
        dispatcher = login(data.account(agency, Role.DISPATCHER), DASHBOARD);
        clientId = data.client(agency, "Nordlicht Logistik");
        locationId = data.location(agency, clientId, "Zentrallager Linz", "Hafenstraße 12, 4020 Linz");
    }

    @Test
    void listsTheClaimsOfAShiftOldestFirstWithTheWorkersName() {
        var shiftId = publish(IN_THREE_DAYS, 5);
        var lena = activeWorker("Lena", "Hofer");
        var jakob = activeWorker("Jakob", "Steiner");
        var mira = activeWorker("Mira", "Aigner");
        var first = claim(shiftId, lena);
        claim(shiftId, jakob);
        var third = claim(shiftId, mira);
        approve(shiftId, third).expectStatus().isOk();

        get(assignments(shiftId), dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalElements").isEqualTo(3)
                .jsonPath("$.content[*].worker.firstName").isEqualTo(List.of("Lena", "Jakob", "Mira"))
                .jsonPath("$.content[*].status").isEqualTo(List.of("PENDING", "PENDING", "CONFIRMED"))
                .jsonPath("$.content[0].id").isEqualTo(first.toString())
                .jsonPath("$.content[0].worker.id").isEqualTo(workerId(lena).toString())
                .jsonPath("$.content[0].worker.lastName").isEqualTo("Hofer")
                .jsonPath("$.content[0].worker.phone").isEqualTo("+43 660 5550101")
                .jsonPath("$.content[0].claimedAt").isNotEmpty()
                .jsonPath("$.content[0].decidedAt").doesNotExist()
                .jsonPath("$.content[0].cancelledBy").doesNotExist()
                .jsonPath("$.content[0].reason").doesNotExist()
                .jsonPath("$.content[2].decidedAt").isNotEmpty();

        get(assignments(shiftId) + "?status=PENDING", dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[*].worker.firstName").isEqualTo(List.of("Lena", "Jakob"));

        get(assignments(shiftId) + "?status=PENDING&page=1&size=1", dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalPages").isEqualTo(2)
                .jsonPath("$.content[*].worker.firstName").isEqualTo(List.of("Jakob"));
    }

    @Test
    void aShiftWithoutClaimsHasAnEmptyList() {
        var draft = create(shiftRequest(IN_THREE_DAYS, 5));

        get(assignments(draft), dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalElements").isEqualTo(0)
                .jsonPath("$.content").isEmpty();
        expectProblem(get(assignments(UUID.randomUUID()), dispatcher), 404, "shift_not_found");
    }

    @Test
    void approvingConfirmsTheClaimAndTheWorkerSeesIt() {
        var shiftId = publish(IN_THREE_DAYS, 5);
        var worker = activeWorker("Lena", "Hofer");
        var assignmentId = claim(shiftId, worker);

        approve(shiftId, assignmentId)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.id").isEqualTo(assignmentId.toString())
                .jsonPath("$.status").isEqualTo("CONFIRMED")
                .jsonPath("$.worker.firstName").isEqualTo("Lena")
                .jsonPath("$.decidedAt").isNotEmpty();

        assertThat(events.all())
                .contains(new AssignmentConfirmed(agency.id(), assignmentId, shiftId, workerId(worker)));
        assertThat(takenSlots(shiftId)).isEqualTo(1);
        get("/api/v1/worker/my-shifts", worker)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[0].assignment.status").isEqualTo("CONFIRMED");
        expectProblem(approve(shiftId, assignmentId), 409, "assignment_not_pending");
        expectProblem(reject(shiftId, assignmentId), 409, "assignment_not_pending");
    }

    @Test
    void rejectingTurnsTheClaimDownAndFreesTheSpot() {
        var shiftId = publish(IN_THREE_DAYS, 1);
        var worker = activeWorker("Lena", "Hofer");
        var assignmentId = claim(shiftId, worker);

        reject(shiftId, assignmentId)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.status").isEqualTo("REJECTED");

        assertThat(events.all())
                .contains(new AssignmentRejected(agency.id(), assignmentId, shiftId, workerId(worker)));
        assertThat(takenSlots(shiftId)).isZero();
        get("/api/v1/worker/my-shifts", worker)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[0].assignment.status").isEqualTo("REJECTED")
                .jsonPath("$.content[0].assignment.cancellableUntil").doesNotExist();
        // The freed spot can be claimed by someone else.
        claim(shiftId, activeWorker("Jakob", "Steiner"));
        expectProblem(approve(shiftId, assignmentId), 409, "assignment_not_pending");
    }

    @Test
    void ofAnApprovalAndARejectionAtTheSameTimeOnlyOneIsApplied() throws Exception {
        for (var round = 0; round < 3; round++) {
            var shiftId = publish(IN_THREE_DAYS.plus(Duration.ofDays(round)), 1);
            var assignmentId = claim(shiftId, activeWorker("Lena", "Hofer"));

            List<Callable<Map<?, ?>>> decisions = List.of(
                    () -> approve(shiftId, assignmentId).expectBody(Map.class).returnResult().getResponseBody(),
                    () -> reject(shiftId, assignmentId).expectBody(Map.class).returnResult().getResponseBody());
            var results = atOnce(decisions);

            assertThat(results).filteredOn(result -> result.containsKey("status") && !result.containsKey("code"))
                    .hasSize(1);
            assertThat(results).filteredOn(result -> "assignment_not_pending".equals(result.get("code"))).hasSize(1);
            var status = jdbc.sql("select status from assignment where id = ?")
                    .param(assignmentId).query(String.class).single();
            assertThat(takenSlots(shiftId)).isEqualTo("CONFIRMED".equals(status) ? 1 : 0);
        }
    }

    @Test
    void removingAWorkerNeedsAReasonAndFreesTheSpot() {
        var shiftId = publish(IN_THREE_DAYS, 2);
        var worker = activeWorker("Lena", "Hofer");
        var assignmentId = claim(shiftId, worker);
        approve(shiftId, assignmentId).expectStatus().isOk();

        expectFieldError(remove(shiftId, assignmentId, Map.of()), "reason", "required");
        expectFieldError(remove(shiftId, assignmentId, Map.of("reason", "   ")), "reason", "required");
        expectFieldError(remove(shiftId, assignmentId, Map.of("reason", "x".repeat(501))), "reason", "invalid_length");
        assertThat(takenSlots(shiftId)).isEqualTo(1);

        remove(shiftId, assignmentId, Map.of("reason", "  Kann laut Rücksprache nicht kommen "))
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.status").isEqualTo("CANCELLED")
                .jsonPath("$.cancelledBy").isEqualTo("AGENCY")
                .jsonPath("$.reason").isEqualTo("Kann laut Rücksprache nicht kommen");

        assertThat(takenSlots(shiftId)).isZero();
        assertThat(events.all()).contains(new AssignmentCancelled(
                agency.id(), assignmentId, shiftId, workerId(worker), AssignmentCancelled.Cause.REMOVED));
        // The worker sees the cancellation, not the reason.
        get("/api/v1/worker/my-shifts", worker)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[0].assignment.status").isEqualTo("CANCELLED")
                .jsonPath("$.content[0].assignment.cancelledBy").isEqualTo("AGENCY")
                .jsonPath("$.content[0].assignment.reason").doesNotExist();
        expectProblem(remove(shiftId, assignmentId, Map.of("reason", "Nochmal")), 409, "assignment_not_active");
    }

    @Test
    void cancellingAShiftCancelsItsPendingAndConfirmedClaims() {
        var shiftId = publish(IN_THREE_DAYS, 5);
        var lena = activeWorker("Lena", "Hofer");
        var jakob = activeWorker("Jakob", "Steiner");
        var mira = activeWorker("Mira", "Aigner");
        var pending = claim(shiftId, lena);
        var confirmed = claim(shiftId, jakob);
        approve(shiftId, confirmed).expectStatus().isOk();
        var rejected = claim(shiftId, mira);
        reject(shiftId, rejected).expectStatus().isOk();

        post("/api/v1/shifts/" + shiftId + "/cancel", dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.status").isEqualTo("CANCELLED")
                .jsonPath("$.takenSlots").isEqualTo(0);

        get(assignments(shiftId), dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[*].status").isEqualTo(List.of("CANCELLED", "CANCELLED", "REJECTED"))
                .jsonPath("$.content[0].cancelledBy").isEqualTo("AGENCY")
                .jsonPath("$.content[0].reason").doesNotExist();
        assertThat(events.all()).contains(
                new AssignmentCancelled(
                        agency.id(), pending, shiftId, workerId(lena), AssignmentCancelled.Cause.SHIFT_CANCELLED),
                new AssignmentCancelled(
                        agency.id(), confirmed, shiftId, workerId(jakob), AssignmentCancelled.Cause.SHIFT_CANCELLED));
        get("/api/v1/worker/shifts/" + shiftId, lena)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.status").isEqualTo("CANCELLED")
                .jsonPath("$.assignment.status").isEqualTo("CANCELLED")
                .jsonPath("$.assignment.cancelledBy").isEqualTo("AGENCY");
        // The workers' time is free again.
        claim(publish(IN_THREE_DAYS, 5), lena);
    }

    @Test
    void anEndedShiftIsCompletedWithItsClaims() {
        var shiftId = publish(IN_THREE_DAYS, 5);
        var lena = activeWorker("Lena", "Hofer");
        var jakob = activeWorker("Jakob", "Steiner");
        var confirmed = claim(shiftId, lena);
        approve(shiftId, confirmed).expectStatus().isOk();
        var undecided = claim(shiftId, jakob);
        var running = publish(Instant.now().minus(Duration.ofHours(1)), 5);
        var draft = create(shiftRequest(IN_THREE_DAYS, 5));
        moveToThePast(shiftId);
        moveToThePast(draft);

        var completed = completionJob.completeEndedShifts(Instant.now());

        assertThat(completed).isGreaterThanOrEqualTo(1);
        assertThat(status(shiftId)).isEqualTo("COMPLETED");
        assertThat(status(running)).isEqualTo("PUBLISHED");
        assertThat(status(draft)).isEqualTo("DRAFT");
        assertThat(events.all()).contains(new ShiftCompleted(agency.id(), shiftId));
        assertThat(events.all())
                .contains(new AssignmentRejected(agency.id(), undecided, shiftId, workerId(jakob)));
        get(assignments(shiftId), dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[*].status").isEqualTo(List.of("COMPLETED", "REJECTED"));
        get("/api/v1/shifts?period=PAST", dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[0].id").isEqualTo(shiftId.toString())
                .jsonPath("$.content[0].status").isEqualTo("COMPLETED");

        // A second run finds nothing left to do for this shift.
        completionJob.completeEndedShifts(Instant.now());
        assertThat(events.all()).filteredOn(new ShiftCompleted(agency.id(), shiftId)::equals).hasSize(1);
    }

    @Test
    void aCompletedWorkerCanBeMarkedAsNoShow() {
        var shiftId = publish(IN_THREE_DAYS, 5);
        var assignmentId = claim(shiftId, activeWorker("Lena", "Hofer"));
        approve(shiftId, assignmentId).expectStatus().isOk();
        expectProblem(noShow(shiftId, assignmentId), 409, "assignment_not_completed");
        moveToThePast(shiftId);
        completionJob.completeEndedShifts(Instant.now());

        noShow(shiftId, assignmentId)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.status").isEqualTo("NO_SHOW");

        expectProblem(noShow(shiftId, assignmentId), 409, "assignment_not_completed");
    }

    @Test
    void withAutoConfirmAClaimIsConfirmedRightAway() {
        var admin = login(data.account(agency, Role.ADMIN), DASHBOARD);
        client.put().uri("/api/v1/agency/settings")
                .headers(headers -> headers.setBearerAuth(admin.accessToken()))
                .contentType(org.springframework.http.MediaType.APPLICATION_JSON)
                .body(Map.of("autoConfirm", true, "cancellationDeadlineHours", 24))
                .exchange()
                .expectStatus().isOk();
        var shiftId = publish(IN_THREE_DAYS, 5);
        var worker = activeWorker("Lena", "Hofer");

        var claimed = post("/api/v1/worker/shifts/" + shiftId + "/claim", worker)
                .expectStatus().isCreated()
                .expectBody(Map.class).returnResult().getResponseBody();

        var assignment = (Map<?, ?>) claimed.get("assignment");
        assertThat(assignment.get("status")).isEqualTo("CONFIRMED");
        var assignmentId = UUID.fromString((String) assignment.get("id"));
        assertThat(events.all()).contains(
                new ShiftClaimed(agency.id(), assignmentId, shiftId, workerId(worker)),
                new AssignmentConfirmed(agency.id(), assignmentId, shiftId, workerId(worker)));
    }

    @Test
    void unknownClaimsAndClaimsOfAnotherShiftAreNotFound() {
        var shiftId = publish(IN_THREE_DAYS, 5);
        var otherShift = publish(IN_THREE_DAYS.plus(Duration.ofDays(1)), 5);
        var assignmentId = claim(shiftId, activeWorker("Lena", "Hofer"));

        expectProblem(approve(otherShift, assignmentId), 404, "assignment_not_found");
        expectProblem(approve(shiftId, UUID.randomUUID()), 404, "assignment_not_found");
        expectProblem(approve(UUID.randomUUID(), assignmentId), 404, "shift_not_found");
    }

    @Test
    void anotherAgencyAndWorkersHaveNoAccess() {
        var shiftId = publish(IN_THREE_DAYS, 5);
        var worker = activeWorker("Lena", "Hofer");
        var assignmentId = claim(shiftId, worker);
        var otherAgency = data.agency("Alpen Events");
        var otherDispatcher = login(data.account(otherAgency, Role.DISPATCHER), DASHBOARD);

        expectProblem(get(assignments(shiftId), otherDispatcher), 404, "shift_not_found");
        for (var change : List.of("approve", "reject", "no-show")) {
            expectProblem(post(action(shiftId, assignmentId, change), otherDispatcher), 404, "shift_not_found");
            expectProblem(post(action(shiftId, assignmentId, change), worker), 403, "forbidden");
        }
        var removal = Map.<String, Object>of("reason", "Doppelt gebucht");
        expectProblem(post(action(shiftId, assignmentId, "remove"), otherDispatcher, removal), 404, "shift_not_found");
        expectProblem(post(action(shiftId, assignmentId, "remove"), worker, removal), 403, "forbidden");
        expectProblem(get(assignments(shiftId), worker), 403, "forbidden");

        assertThat(jdbc.sql("select status from assignment where id = ?").param(assignmentId)
                .query(String.class).single()).isEqualTo("PENDING");
        assertThat(takenSlots(shiftId)).isEqualTo(1);
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

    /** Claims a spot for the worker and returns the id of the assignment. */
    private UUID claim(UUID shiftId, TokenPair worker) {
        var claimed = post("/api/v1/worker/shifts/" + shiftId + "/claim", worker)
                .expectStatus().isCreated()
                .expectBody(Map.class).returnResult().getResponseBody();
        return UUID.fromString((String) ((Map<?, ?>) claimed.get("assignment")).get("id"));
    }

    /** Moves the shift and its claims five days back, so that it has ended. */
    private void moveToThePast(UUID shiftId) {
        var back = "interval '5 days'";
        jdbc.sql("update shift set starts_at = starts_at - " + back + ", ends_at = ends_at - " + back
                + " where id = ?").param(shiftId).update();
        jdbc.sql("update assignment set starts_at = starts_at - " + back + ", ends_at = ends_at - " + back
                + " where shift_id = ?").param(shiftId).update();
    }

    private static String assignments(UUID shiftId) {
        return "/api/v1/shifts/" + shiftId + "/assignments";
    }

    private static String action(UUID shiftId, UUID assignmentId, String action) {
        return assignments(shiftId) + "/" + assignmentId + "/" + action;
    }

    private RestTestClient.ResponseSpec approve(UUID shiftId, UUID assignmentId) {
        return post(action(shiftId, assignmentId, "approve"), dispatcher);
    }

    private RestTestClient.ResponseSpec reject(UUID shiftId, UUID assignmentId) {
        return post(action(shiftId, assignmentId, "reject"), dispatcher);
    }

    private RestTestClient.ResponseSpec noShow(UUID shiftId, UUID assignmentId) {
        return post(action(shiftId, assignmentId, "no-show"), dispatcher);
    }

    private RestTestClient.ResponseSpec remove(UUID shiftId, UUID assignmentId, Map<String, Object> body) {
        return post(action(shiftId, assignmentId, "remove"), dispatcher, body);
    }

    private int takenSlots(UUID shiftId) {
        return jdbc.sql("select taken_slots from shift where id = ?").param(shiftId).query(Integer.class).single();
    }

    private String status(UUID shiftId) {
        return jdbc.sql("select status from shift where id = ?").param(shiftId).query(String.class).single();
    }

    private static void expectFieldError(RestTestClient.ResponseSpec response, String field, String code) {
        expectProblem(response, 400, "validation_failed")
                .jsonPath("$.errors.length()").isEqualTo(1)
                .jsonPath("$.errors[0].field").isEqualTo(field)
                .jsonPath("$.errors[0].code").isEqualTo(code);
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
}
