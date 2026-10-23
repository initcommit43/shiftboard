package app.shiftboard.assignment;

import static org.assertj.core.api.Assertions.assertThat;

import java.sql.Timestamp;
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
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.client.RestTestClient;

/**
 * The waitlist of full shifts (ADR 0029), from the worker's side.
 */
class WaitlistIntegrationTests extends IntegrationTest {

    /** Far enough ahead that the default deadline of 24 hours has not passed. */
    static final Instant IN_THREE_DAYS = Instant.now().plus(Duration.ofDays(3)).truncatedTo(ChronoUnit.SECONDS);

    /** Within the default deadline of 24 hours. */
    static final Instant IN_TWELVE_HOURS = Instant.now().plus(Duration.ofHours(12)).truncatedTo(ChronoUnit.SECONDS);

    TestData.Agency agency;

    TokenPair admin;

    TokenPair dispatcher;

    UUID clientId;

    UUID locationId;

    @BeforeEach
    void createAgencyWithTheWaitlistOn() {
        agency = data.agency("Donau Personal");
        admin = login(data.account(agency, Role.ADMIN), DASHBOARD);
        dispatcher = login(data.account(agency, Role.DISPATCHER), DASHBOARD);
        clientId = data.client(agency, "Nordlicht Logistik");
        locationId = data.location(agency, clientId, "Zentrallager Linz", "Hafenstraße 12, 4020 Linz");
        settings(false, true);
    }

    @Test
    void aWorkerJoinsTheWaitlistOfAFullShiftAndSeesTheirPlace() {
        var shiftId = publish("Staplerfahrer:in", IN_THREE_DAYS, 8, 1);
        claim(shiftId, activeWorker()).expectStatus().isCreated();
        var first = activeWorker();
        var second = activeWorker();

        var joined = join(shiftId, first)
                .expectStatus().isCreated()
                .expectBody(Map.class).returnResult().getResponseBody();

        assertThat(joined.get("id")).isEqualTo(shiftId.toString());
        assertThat(joined.get("takenSlots")).as("a place in line holds no spot").isEqualTo(1);
        assertThat(joined.get("waitlistEnabled")).isEqualTo(true);
        assertThat(joined.containsKey("assignment")).isFalse();
        var place = (Map<?, ?>) joined.get("waitlist");
        assertThat(place.get("position")).isEqualTo(1);
        assertThat(Instant.parse((String) place.get("joinedAt"))).isBefore(Instant.now().plusSeconds(1));
        join(shiftId, second)
                .expectStatus().isCreated()
                .expectBody()
                .jsonPath("$.waitlist.position").isEqualTo(2);

        var stored = jdbc.sql("select * from assignment where shift_id = ? and worker_id = ?")
                .params(shiftId, workerId(first)).query().singleRow();
        assertThat(stored.get("status")).isEqualTo("WAITLISTED");

        // The detail and the list of open shifts show the place, never as an assignment.
        get("/api/v1/worker/shifts/" + shiftId, first)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.waitlist.position").isEqualTo(1)
                .jsonPath("$.assignment").doesNotExist();
        get("/api/v1/worker/shifts", second)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[0].waitlist.position").isEqualTo(2)
                .jsonPath("$.content[0].assignment").doesNotExist();

        // "My shifts" lists the waitlist only when asked for, so that older apps see none of it.
        get("/api/v1/worker/my-shifts", first)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalElements").isEqualTo(0);
        get("/api/v1/worker/my-shifts?includeWaitlist=true", first)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalElements").isEqualTo(1)
                .jsonPath("$.content[0].id").isEqualTo(shiftId.toString())
                .jsonPath("$.content[0].waitlist.position").isEqualTo(1)
                .jsonPath("$.content[0].assignment").doesNotExist();

        // The claims of the shift leave the waitlist out, and its status is not one of the API's.
        get("/api/v1/shifts/" + shiftId + "/assignments", dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalElements").isEqualTo(1)
                .jsonPath("$.content[0].status").isEqualTo("PENDING");
        expectProblem(get("/api/v1/shifts/" + shiftId + "/assignments?status=WAITLISTED", dispatcher),
                400, "validation_failed")
                .jsonPath("$.errors[0].field").isEqualTo("status")
                .jsonPath("$.errors[0].code").isEqualTo("invalid_format");
    }

    @Test
    void joiningIsBlockedWhereItMakesNoSense() {
        var worker = activeWorker();
        var full = publish("Voll", IN_THREE_DAYS, 8, 1);
        claim(full, activeWorker()).expectStatus().isCreated();
        var open = publish("Frei", IN_THREE_DAYS.plus(Duration.ofDays(1)), 8, 2);

        expectProblem(join(open, worker), 409, "shift_not_full");
        expectProblem(join(UUID.randomUUID(), worker), 404, "shift_not_found");
        expectProblem(join(create(shiftRequest("Entwurf", IN_THREE_DAYS, 8, 1)), worker), 404, "shift_not_found");

        // Claimed before, whatever became of the claim.
        var mine = publish("Meine", IN_THREE_DAYS.plus(Duration.ofDays(2)), 8, 1);
        claim(mine, worker).expectStatus().isCreated();
        expectProblem(join(mine, worker), 409, "shift_already_claimed");

        join(full, worker).expectStatus().isCreated();
        expectProblem(join(full, worker), 409, "already_on_waitlist");

        // Overlaps a shift the worker holds a spot or a request for.
        var overlapping = publish("Überschneidung", IN_THREE_DAYS.plus(Duration.ofDays(2)).plus(Duration.ofHours(4)), 8, 1);
        claim(overlapping, activeWorker()).expectStatus().isCreated();
        expectProblem(join(overlapping, worker), 409, "shift_overlap");

        var cancelled = publish("Abgesagt", IN_THREE_DAYS, 8, 1);
        jdbc.sql("update shift set status = 'CANCELLED' where id = ?").param(cancelled).update();
        expectProblem(join(cancelled, worker), 409, "shift_not_open");

        var running = shiftRequest("Läuft", Instant.now().minus(Duration.ofHours(1)), 4, 1);
        running.put("publish", true);
        var runningId = create(running);
        jdbc.sql("update shift set taken_slots = 1 where id = ?").param(runningId).update();
        expectProblem(join(runningId, worker), 409, "shift_started");

        // Switched off: no new entries.
        settings(false, false);
        var other = publish("Ohne Warteliste", IN_THREE_DAYS.plus(Duration.ofDays(5)), 8, 1);
        claim(other, activeWorker()).expectStatus().isCreated();
        expectProblem(join(other, activeWorker()), 409, "waitlist_disabled");
        get("/api/v1/worker/shifts/" + other, worker)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.waitlistEnabled").isEqualTo(false);
        // Those already waiting stay in line.
        get("/api/v1/worker/shifts/" + full, worker)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.waitlist.position").isEqualTo(1);
    }

    @Test
    void leavingTakesTheWorkerOffWithoutATraceAndTheyCanJoinAgainAtTheBack() {
        var shiftId = publish("Staplerfahrer:in", IN_THREE_DAYS, 8, 1);
        claim(shiftId, activeWorker()).expectStatus().isCreated();
        var first = activeWorker();
        var second = activeWorker();
        join(shiftId, first).expectStatus().isCreated();
        join(shiftId, second).expectStatus().isCreated();

        leave(shiftId, first)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.id").isEqualTo(shiftId.toString())
                .jsonPath("$.waitlist").doesNotExist()
                .jsonPath("$.assignment").doesNotExist();

        assertThat(jdbc.sql("select count(*) from assignment where shift_id = ? and worker_id = ?")
                .params(shiftId, workerId(first)).query(Integer.class).single()).isZero();
        get("/api/v1/worker/shifts/" + shiftId, second)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.waitlist.position").isEqualTo(1);
        expectProblem(leave(shiftId, first), 404, "not_on_waitlist");

        join(shiftId, first)
                .expectStatus().isCreated()
                .expectBody()
                .jsonPath("$.waitlist.position").isEqualTo(2);

        // Also when the agency switched the waitlist off.
        settings(false, false);
        leave(shiftId, first).expectStatus().isOk();
    }

    @Test
    void leavingIsPossibleUntilTheStart() {
        var shiftId = publish("Staplerfahrer:in", IN_THREE_DAYS, 8, 1);
        var holder = activeWorker();
        claim(shiftId, holder).expectStatus().isCreated();
        var worker = activeWorker();
        join(shiftId, worker).expectStatus().isCreated();
        var started = Instant.now().minus(Duration.ofMinutes(5));
        jdbc.sql("update shift set starts_at = ? where id = ?")
                .params(Timestamp.from(started), shiftId).update();
        jdbc.sql("update assignment set starts_at = ? where shift_id = ?")
                .params(Timestamp.from(started), shiftId).update();

        expectProblem(leave(shiftId, worker), 409, "shift_started");
        expectProblem(leave(UUID.randomUUID(), worker), 404, "shift_not_found");
        expectProblem(leave(shiftId, holder), 404, "not_on_waitlist");
    }

    @Test
    void aPlaceInLineIsNoClaimAndBlocksNoOtherClaim() {
        var shiftId = publish("Staplerfahrer:in", IN_THREE_DAYS, 8, 1);
        claim(shiftId, activeWorker()).expectStatus().isCreated();
        var worker = activeWorker();
        join(shiftId, worker).expectStatus().isCreated();

        expectProblem(cancel(shiftId, worker), 404, "assignment_not_found");
        var entryId = jdbc.sql("select id from assignment where shift_id = ? and worker_id = ?")
                .params(shiftId, workerId(worker)).query(UUID.class).single();
        expectProblem(post("/api/v1/shifts/" + shiftId + "/assignments/" + entryId + "/approve", dispatcher),
                404, "assignment_not_found");

        // The time of the shift is not booked: an overlapping shift can be claimed.
        var overlapping = publish("Überschneidung", IN_THREE_DAYS.plus(Duration.ofHours(4)), 8, 1);
        claim(overlapping, worker).expectStatus().isCreated();
    }

    @Test
    void aWorkerOnTheWaitlistClaimsAFreeSpotAndTheirPlaceBecomesTheClaim() {
        // Within the deadline, a freed spot is not given to the first in line but offered to all.
        var shiftId = publish("Staplerfahrer:in", IN_TWELVE_HOURS, 8, 1);
        var holder = activeWorker();
        var holding = claimedAssignmentId(claim(shiftId, holder));
        var worker = activeWorker();
        join(shiftId, worker).expectStatus().isCreated();
        var entryId = jdbc.sql("select id from assignment where shift_id = ? and worker_id = ?")
                .params(shiftId, workerId(worker)).query(UUID.class).single();
        remove(shiftId, holding).expectStatus().isOk();

        var claimed = claim(shiftId, worker)
                .expectStatus().isCreated()
                .expectBody(Map.class).returnResult().getResponseBody();

        var assignment = (Map<?, ?>) claimed.get("assignment");
        assertThat(claimed.containsKey("waitlist")).isFalse();
        assertThat(claimed.get("takenSlots")).isEqualTo(1);
        assertThat(assignment.get("id")).as("the same row").isEqualTo(entryId.toString());
        assertThat(assignment.get("status")).isEqualTo("PENDING");
        assertThat(Instant.parse((String) assignment.get("claimedAt")))
                .as("claimed now, not when the worker joined")
                .isAfter(Instant.now().minusSeconds(10));
        assertThat(events.all()).contains(new ShiftClaimed(agency.id(), entryId, shiftId, workerId(worker)));
        expectProblem(claim(shiftId, worker), 409, "shift_already_claimed");
    }

    // --- helpers ----------------------------------------------------------------------------

    void settings(boolean autoConfirm, boolean waitlist) {
        settings(autoConfirm, 24, waitlist);
    }

    void settings(boolean autoConfirm, int deadlineHours, boolean waitlist) {
        client.put().uri("/api/v1/agency/settings")
                .headers(headers -> headers.setBearerAuth(admin.accessToken()))
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of("autoConfirm", autoConfirm, "cancellationDeadlineHours", deadlineHours,
                        "waitlist", waitlist))
                .exchange()
                .expectStatus().isOk();
    }

    /** Signs a worker up in the agency of the test and approves the signup. */
    TokenPair activeWorker() {
        var tokens = signUp(agency.signupCode(), TestData.email());
        post("/api/v1/workers/" + workerId(tokens) + "/approve", dispatcher).expectStatus().isOk();
        return tokens;
    }

    Map<String, Object> shiftRequest(String title, Instant startsAt, int hours, int slots) {
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

    UUID create(Map<String, Object> request) {
        var created = post("/api/v1/shifts", dispatcher, request)
                .expectStatus().isCreated()
                .expectBody(Map.class).returnResult().getResponseBody();
        return UUID.fromString((String) created.get("id"));
    }

    UUID publish(String title, Instant startsAt, int hours, int slots) {
        var request = shiftRequest(title, startsAt, hours, slots);
        request.put("publish", true);
        return create(request);
    }

    RestTestClient.ResponseSpec claim(UUID shiftId, TokenPair tokens) {
        return post("/api/v1/worker/shifts/" + shiftId + "/claim", tokens);
    }

    RestTestClient.ResponseSpec cancel(UUID shiftId, TokenPair tokens) {
        return post("/api/v1/worker/shifts/" + shiftId + "/cancel", tokens);
    }

    RestTestClient.ResponseSpec join(UUID shiftId, TokenPair tokens) {
        return post("/api/v1/worker/shifts/" + shiftId + "/waitlist", tokens);
    }

    RestTestClient.ResponseSpec leave(UUID shiftId, TokenPair tokens) {
        return client.delete().uri("/api/v1/worker/shifts/" + shiftId + "/waitlist")
                .headers(headers -> headers.setBearerAuth(tokens.accessToken()))
                .exchange();
    }

    RestTestClient.ResponseSpec remove(UUID shiftId, UUID assignmentId) {
        return post("/api/v1/shifts/" + shiftId + "/assignments/" + assignmentId + "/remove", dispatcher,
                Map.of("reason", "Kurzfristig umgeplant"));
    }

    static UUID claimedAssignmentId(RestTestClient.ResponseSpec claim) {
        var claimed = claim.expectStatus().isCreated().expectBody(Map.class).returnResult().getResponseBody();
        return UUID.fromString((String) ((Map<?, ?>) claimed.get("assignment")).get("id"));
    }

    String status(UUID shiftId, TokenPair worker) {
        return jdbc.sql("select status from assignment where shift_id = ? and worker_id = ?")
                .params(shiftId, workerId(worker)).query(String.class).optional().orElse(null);
    }

    int takenSlots(UUID shiftId) {
        return jdbc.sql("select taken_slots from shift where id = ?").param(shiftId).query(Integer.class).single();
    }

    /** Runs the calls at the same moment, each on its own thread, and returns what they answered. */
    static <T> List<T> atOnce(List<Callable<T>> calls) throws Exception {
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
