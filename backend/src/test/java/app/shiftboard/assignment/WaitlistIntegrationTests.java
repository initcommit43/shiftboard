package app.shiftboard.assignment;

import static org.assertj.core.api.Assertions.assertThat;
import static org.awaitility.Awaitility.await;

import java.sql.Timestamp;
import java.time.Duration;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Collections;
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
import app.shiftboard.notification.internal.RecordingPushSender;
import app.shiftboard.shift.ShiftCancelled;
import app.shiftboard.shift.internal.ShiftCompletionJob;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
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

    @Autowired
    RecordingPushSender push;

    @Autowired
    ShiftCompletionJob completionJob;

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

    // --- moving up (#111) ------------------------------------------------------------------

    @Test
    void whenAWorkerDropsOutTheFirstInLineMovesUpIntoARequest() {
        var shiftId = publish("Staplerfahrer:in", IN_THREE_DAYS, 8, 1);
        var holder = activeWorker();
        claim(shiftId, holder).expectStatus().isCreated();
        var first = activeWorker();
        var firstDevice = device(first);
        var second = activeWorker();
        join(shiftId, first).expectStatus().isCreated();
        join(shiftId, second).expectStatus().isCreated();
        var entryId = entryId(shiftId, first);
        var beforeDropOut = Instant.now();

        cancel(shiftId, holder)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.takenSlots").isEqualTo(1)
                .jsonPath("$.assignment.status").isEqualTo("CANCELLED");

        assertThat(takenSlots(shiftId)).isEqualTo(1);
        assertThat(events.all()).contains(new WaitlistMovedUp(agency.id(), entryId, shiftId, workerId(first), false));
        var moved = get("/api/v1/worker/shifts/" + shiftId, first)
                .expectStatus().isOk()
                .expectBody(Map.class).returnResult().getResponseBody();
        var assignment = (Map<?, ?>) moved.get("assignment");
        assertThat(moved.containsKey("waitlist")).isFalse();
        assertThat(assignment.get("id")).isEqualTo(entryId.toString());
        assertThat(assignment.get("status")).isEqualTo("PENDING");
        assertThat(Instant.parse((String) assignment.get("claimedAt"))).isAfterOrEqualTo(beforeDropOut.minusSeconds(1));
        get("/api/v1/worker/my-shifts", first)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[0].assignment.status").isEqualTo("PENDING");
        get("/api/v1/worker/shifts/" + shiftId, second)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.waitlist.position").isEqualTo(1);
        // The dispatcher sees the request like any other claim.
        get("/api/v1/shifts/" + shiftId + "/assignments?status=PENDING", dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[0].id").isEqualTo(entryId.toString());

        await().atMost(Duration.ofSeconds(5)).until(() -> !push.sentTo(firstDevice).isEmpty());
        var sent = push.sentTo(firstDevice).getFirst();
        assertThat(sent.title()).isEqualTo("Du bist nachgerückt");
        assertThat(sent.body()).startsWith("Staplerfahrer:in · ").endsWith(" · wartet auf Bestätigung");
        assertThat(sent.data()).containsEntry("type", "WAITLIST_MOVED_UP").containsEntry("shiftId", shiftId.toString());
        await().atMost(Duration.ofSeconds(5)).untilAsserted(() ->
                get("/api/v1/worker/conversation/messages", first)
                        .expectStatus().isOk()
                        .expectBody()
                        .jsonPath("$.content.length()").isEqualTo(1)
                        .jsonPath("$.content[0].type").isEqualTo("SYSTEM")
                        .jsonPath("$.content[0].event").isEqualTo("WAITLIST_MOVED_UP")
                        .jsonPath("$.content[0].shift.id").isEqualTo(shiftId.toString()));
        var body = jdbc.sql("""
                select m.body from message m join conversation c on c.id = m.conversation_id
                where c.worker_id = ? and m.event = 'WAITLIST_MOVED_UP'
                """).param(workerId(first)).query(String.class).single();
        assertThat(body).startsWith("Du bist von der Warteliste für „Staplerfahrer:in“ am ")
                .endsWith(" nachgerückt. Deine Anfrage wartet auf die Bestätigung der Agentur.");
    }

    @Test
    void withAutoConfirmTheFirstInLineIsConfirmedAndToldOnce() {
        settings(true, true);
        var shiftId = publish("Staplerfahrer:in", IN_THREE_DAYS, 8, 1);
        var holding = claimedAssignmentId(claim(shiftId, activeWorker()));
        var first = activeWorker();
        var firstDevice = device(first);
        join(shiftId, first).expectStatus().isCreated();
        var entryId = entryId(shiftId, first);

        remove(shiftId, holding).expectStatus().isOk();

        assertThat(status(shiftId, first)).isEqualTo("CONFIRMED");
        assertThat(events.all()).contains(new WaitlistMovedUp(agency.id(), entryId, shiftId, workerId(first), true));
        assertThat(events.all()).doesNotContain(new AssignmentConfirmed(agency.id(), entryId, shiftId, workerId(first)));
        await().atMost(Duration.ofSeconds(5)).until(() -> !push.sentTo(firstDevice).isEmpty());
        await().during(Duration.ofMillis(500)).atMost(Duration.ofSeconds(2))
                .until(() -> push.sentTo(firstDevice).size() == 1);
        var sent = push.sentTo(firstDevice).getFirst();
        assertThat(sent.title()).isEqualTo("Du bist nachgerückt");
        assertThat(sent.body()).endsWith(" · bestätigt");
        await().atMost(Duration.ofSeconds(5)).untilAsserted(() -> assertThat(jdbc.sql("""
                select m.event from message m join conversation c on c.id = m.conversation_id where c.worker_id = ?
                """).param(workerId(first)).query(String.class).list()).containsExactly("WAITLIST_MOVED_UP_CONFIRMED"));
    }

    @Test
    void aRejectedRequestFreesTheSpotForTheFirstInLine() {
        var shiftId = publish("Staplerfahrer:in", IN_THREE_DAYS, 8, 1);
        var pending = claimedAssignmentId(claim(shiftId, activeWorker()));
        var first = activeWorker();
        join(shiftId, first).expectStatus().isCreated();

        post("/api/v1/shifts/" + shiftId + "/assignments/" + pending + "/reject", dispatcher).expectStatus().isOk();

        assertThat(status(shiftId, first)).isEqualTo("PENDING");
        assertThat(takenSlots(shiftId)).isEqualTo(1);
    }

    @Test
    void addedSpotsGoToTheFirstInLineOneEach() {
        var shiftId = publish("Staplerfahrer:in", IN_THREE_DAYS, 8, 1);
        claim(shiftId, activeWorker()).expectStatus().isCreated();
        var first = activeWorker();
        var second = activeWorker();
        var third = activeWorker();
        for (var worker : List.of(first, second, third)) {
            join(shiftId, worker).expectStatus().isCreated();
        }

        put("/api/v1/shifts/" + shiftId, shiftRequest("Staplerfahrer:in", IN_THREE_DAYS, 8, 3))
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.slots").isEqualTo(3)
                .jsonPath("$.takenSlots").isEqualTo(3);

        assertThat(status(shiftId, first)).isEqualTo("PENDING");
        assertThat(status(shiftId, second)).isEqualTo("PENDING");
        assertThat(status(shiftId, third)).isEqualTo("WAITLISTED");
        get("/api/v1/worker/shifts/" + shiftId, third)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.waitlist.position").isEqualTo(1);
    }

    @Test
    void theFirstInLineWhoIsBookedAtTheSameTimeByNowIsSkippedAndTold() {
        var shiftId = publish("Staplerfahrer:in", IN_THREE_DAYS, 8, 1);
        var holder = activeWorker();
        claim(shiftId, holder).expectStatus().isCreated();
        var first = activeWorker();
        var firstDevice = device(first);
        var second = activeWorker();
        join(shiftId, first).expectStatus().isCreated();
        join(shiftId, second).expectStatus().isCreated();
        var skipped = entryId(shiftId, first);
        // A place in line books no time, so the first in line took an overlapping shift meanwhile.
        claim(publish("Überschneidung", IN_THREE_DAYS.plus(Duration.ofHours(2)), 8, 1), first)
                .expectStatus().isCreated();

        cancel(shiftId, holder).expectStatus().isOk();

        assertThat(status(shiftId, first)).isNull();
        assertThat(status(shiftId, second)).isEqualTo("PENDING");
        assertThat(events.all()).contains(new WaitlistEntryRemoved(
                agency.id(), skipped, shiftId, workerId(first), WaitlistEntryRemoved.Cause.OVERLAP));
        await().atMost(Duration.ofSeconds(5)).until(() -> push.sentTo(firstDevice).stream()
                .anyMatch(sent -> "WAITLIST_REMOVED".equals(sent.data().get("type"))));
        assertThat(push.sentTo(firstDevice)).filteredOn(sent -> "WAITLIST_REMOVED".equals(sent.data().get("type")))
                .singleElement()
                .satisfies(sent -> assertThat(sent.title()).isEqualTo("Nicht mehr auf der Warteliste"));
        await().atMost(Duration.ofSeconds(5)).untilAsserted(() -> assertThat(jdbc.sql("""
                select m.body from message m join conversation c on c.id = m.conversation_id
                where c.worker_id = ? and m.event = 'WAITLIST_SKIPPED'
                """).param(workerId(first)).query(String.class).single())
                .startsWith("Für „Staplerfahrer:in“ am ")
                .endsWith(" Du bist nicht mehr auf der Warteliste."));
    }

    @Test
    void afterTheDeadlineEveryoneWaitingIsToldAndTheFirstClaimWins() {
        var shiftId = publish("Staplerfahrer:in", IN_TWELVE_HOURS, 8, 1);
        var holding = claimedAssignmentId(claim(shiftId, activeWorker()));
        var first = activeWorker();
        var firstDevice = device(first);
        var second = activeWorker();
        var secondDevice = device(second);
        join(shiftId, first).expectStatus().isCreated();
        join(shiftId, second).expectStatus().isCreated();

        remove(shiftId, holding).expectStatus().isOk();

        assertThat(takenSlots(shiftId)).isZero();
        assertThat(status(shiftId, first)).isEqualTo("WAITLISTED");
        assertThat(events.all()).contains(
                new WaitlistSpotFree(agency.id(), shiftId, List.of(workerId(first), workerId(second))));
        for (var device : List.of(firstDevice, secondDevice)) {
            await().atMost(Duration.ofSeconds(5)).until(() -> !push.sentTo(device).isEmpty());
            var sent = push.sentTo(device).getFirst();
            assertThat(sent.title()).isEqualTo("Platz frei");
            assertThat(sent.body()).startsWith("Staplerfahrer:in · ");
            assertThat(sent.data()).containsEntry("type", "WAITLIST_SPOT_FREE")
                    .containsEntry("shiftId", shiftId.toString());
        }

        claim(shiftId, second).expectStatus().isCreated();
        expectProblem(claim(shiftId, first), 409, "shift_full");
        get("/api/v1/worker/shifts/" + shiftId, first)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.waitlist.position").isEqualTo(1);
    }

    @Test
    void workersAlreadyWaitingMoveUpAfterTheWaitlistWasSwitchedOff() {
        var shiftId = publish("Staplerfahrer:in", IN_THREE_DAYS, 8, 1);
        var holder = activeWorker();
        claim(shiftId, holder).expectStatus().isCreated();
        var first = activeWorker();
        join(shiftId, first).expectStatus().isCreated();
        settings(false, false);

        cancel(shiftId, holder).expectStatus().isOk();

        assertThat(status(shiftId, first)).isEqualTo("PENDING");
    }

    @Test
    void aCancelledShiftClearsItsWaitlistAndTellsTheWorkersOnIt() {
        var shiftId = publish("Staplerfahrer:in", IN_THREE_DAYS, 8, 1);
        claim(shiftId, activeWorker()).expectStatus().isCreated();
        var worker = activeWorker();
        var device = device(worker);
        join(shiftId, worker).expectStatus().isCreated();
        var entryId = entryId(shiftId, worker);

        post("/api/v1/shifts/" + shiftId + "/cancel", dispatcher).expectStatus().isOk();

        assertThat(status(shiftId, worker)).isNull();
        assertThat(events.all()).contains(new ShiftCancelled(agency.id(), shiftId), new WaitlistEntryRemoved(
                agency.id(), entryId, shiftId, workerId(worker), WaitlistEntryRemoved.Cause.SHIFT_CANCELLED));
        await().atMost(Duration.ofSeconds(5)).until(() -> !push.sentTo(device).isEmpty());
        assertThat(push.sentTo(device).getFirst().title()).isEqualTo("Schicht abgesagt");
        assertThat(push.sentTo(device).getFirst().data()).containsEntry("type", "SHIFT_CANCELLED");
        await().atMost(Duration.ofSeconds(5)).untilAsserted(() ->
                get("/api/v1/worker/conversation/messages", worker)
                        .expectStatus().isOk()
                        .expectBody()
                        .jsonPath("$.content.length()").isEqualTo(1)
                        .jsonPath("$.content[0].event").isEqualTo("SHIFT_CANCELLED"));
        get("/api/v1/worker/my-shifts?includeWaitlist=true", worker)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalElements").isEqualTo(0);
    }

    @Test
    void aShiftThatEndedClearsItsWaitlistSilently() {
        var shiftId = publish("Staplerfahrer:in", IN_THREE_DAYS, 8, 1);
        claim(shiftId, activeWorker()).expectStatus().isCreated();
        var worker = activeWorker();
        join(shiftId, worker).expectStatus().isCreated();
        var back = "interval '5 days'";
        jdbc.sql("update shift set starts_at = starts_at - " + back + ", ends_at = ends_at - " + back
                + " where id = ?").param(shiftId).update();
        jdbc.sql("update assignment set starts_at = starts_at - " + back + ", ends_at = ends_at - " + back
                + " where shift_id = ?").param(shiftId).update();

        completionJob.completeEndedShifts(Instant.now());

        assertThat(status(shiftId, worker)).isNull();
        assertThat(events.all()).filteredOn(WaitlistEntryRemoved.class::isInstance)
                .noneMatch(removed -> ((WaitlistEntryRemoved) removed).shiftId().equals(shiftId));
    }

    @Test
    void thePlaceInLineFollowsTheShiftToItsNewTime() {
        var shiftId = publish("Staplerfahrer:in", IN_THREE_DAYS, 8, 1);
        claim(shiftId, activeWorker()).expectStatus().isCreated();
        var worker = activeWorker();
        join(shiftId, worker).expectStatus().isCreated();
        var later = IN_THREE_DAYS.plus(Duration.ofHours(2));

        put("/api/v1/shifts/" + shiftId, shiftRequest("Staplerfahrer:in", later, 8, 1)).expectStatus().isOk();

        assertThat(jdbc.sql("select starts_at from assignment where shift_id = ? and worker_id = ?")
                .params(shiftId, workerId(worker)).query(Instant.class).single()).isEqualTo(later);
    }

    @Test
    void concurrentDropOutsAndClaimsNeverGiveASpotTwice() throws Exception {
        var shiftId = publish("Staplerfahrer:in", IN_THREE_DAYS, 8, 2);
        var holders = List.of(activeWorker(), activeWorker());
        for (var holder : holders) {
            claim(shiftId, holder).expectStatus().isCreated();
        }
        var waiting = List.of(activeWorker(), activeWorker(), activeWorker());
        for (var worker : waiting) {
            join(shiftId, worker).expectStatus().isCreated();
        }
        var outsiders = List.of(activeWorker(), activeWorker());

        var calls = new ArrayList<Callable<Integer>>();
        for (var holder : holders) {
            calls.add(() -> cancel(shiftId, holder).returnResult().getStatus().value());
        }
        for (var outsider : outsiders) {
            calls.add(() -> claim(shiftId, outsider).returnResult().getStatus().value());
        }
        var results = atOnce(calls);

        var droppedOut = results.subList(0, 2).stream().filter(status -> status == 200).count();
        // Every freed spot went to the line at once, so a claim from outside never found one.
        assertThat(results.subList(2, 4)).containsOnly(409);
        assertThat(takenSlots(shiftId)).isEqualTo(2);
        assertThat(jdbc.sql("select count(*) from assignment where shift_id = ? and status in ('PENDING', 'CONFIRMED')")
                .param(shiftId).query(Integer.class).single()).isEqualTo(2);
        assertThat(waiting.stream().map(worker -> status(shiftId, worker)).toList())
                .as("the first in line moved up, in order")
                .startsWith(Collections.nCopies((int) droppedOut, "PENDING").toArray(String[]::new))
                .filteredOn("WAITLISTED"::equals).hasSize(3 - (int) droppedOut);
    }

    @Test
    void aJoinAtTheMomentASpotFreesNeverWaitsForAFreeSpot() throws Exception {
        for (var round = 0; round < 20; round++) {
            var shiftId = publish("Staplerfahrer:in", IN_THREE_DAYS, 8, 1);
            var holder = activeWorker();
            claim(shiftId, holder).expectStatus().isCreated();
            var joiner = activeWorker();

            var results = atOnce(List.<Callable<Integer>>of(
                    () -> cancel(shiftId, holder).returnResult().getStatus().value(),
                    () -> join(shiftId, joiner).returnResult().getStatus().value()));

            assertThat(results.getFirst()).as("round %d: the drop-out", round).isEqualTo(200);
            if (results.getLast() == 201) {
                // The join came first: the spot freed afterwards went to the joiner.
                assertThat(status(shiftId, joiner)).as("round %d: the joiner", round).isEqualTo("PENDING");
                assertThat(takenSlots(shiftId)).as("round %d: taken slots", round).isEqualTo(1);
            } else {
                // The spot was freed first: the join was refused, as the shift was no longer full.
                assertThat(results.getLast()).as("round %d: the join", round).isEqualTo(409);
                assertThat(status(shiftId, joiner)).as("round %d: the joiner", round).isNull();
                assertThat(takenSlots(shiftId)).as("round %d: taken slots", round).isZero();
            }
        }
    }

    // --- the agency's view (#112) ----------------------------------------------------------

    @Test
    void theDispatcherSeesTheWaitlistInLineOrderAndHowManyWait() {
        var shiftId = publish("Staplerfahrer:in", IN_THREE_DAYS, 8, 1);
        claim(shiftId, activeWorker()).expectStatus().isCreated();
        var first = activeWorker("Lena", "Hofer", "+43 660 5550101");
        var second = activeWorker("Jakob", "Steiner", "+43 660 5550102");
        var third = activeWorker("Mira", "Gruber", "+43 660 5550103");
        for (var worker : List.of(first, second, third)) {
            join(shiftId, worker).expectStatus().isCreated();
        }
        var other = publish("Ohne Warteliste", IN_THREE_DAYS.plus(Duration.ofDays(1)), 8, 1);

        get("/api/v1/shifts/" + shiftId + "/waitlist", dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.page").isEqualTo(0)
                .jsonPath("$.size").isEqualTo(20)
                .jsonPath("$.totalElements").isEqualTo(3)
                .jsonPath("$.totalPages").isEqualTo(1)
                .jsonPath("$.content[*].position").isEqualTo(List.of(1, 2, 3))
                .jsonPath("$.content[*].worker.firstName").isEqualTo(List.of("Lena", "Jakob", "Mira"))
                .jsonPath("$.content[0].id").isEqualTo(entryId(shiftId, first).toString())
                .jsonPath("$.content[0].worker.id").isEqualTo(workerId(first).toString())
                .jsonPath("$.content[0].worker.lastName").isEqualTo("Hofer")
                .jsonPath("$.content[0].worker.phone").isEqualTo("+43 660 5550101")
                .jsonPath("$.content[0].joinedAt").exists();
        get("/api/v1/shifts/" + shiftId + "/waitlist?page=1&size=2", dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalPages").isEqualTo(2)
                .jsonPath("$.content[*].position").isEqualTo(List.of(3))
                .jsonPath("$.content[0].worker.firstName").isEqualTo("Mira");
        get("/api/v1/shifts/" + other + "/waitlist", dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalElements").isEqualTo(0)
                .jsonPath("$.content").isEmpty();

        // Every shift says how many wait, in the list and in the detail.
        get("/api/v1/shifts", dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[0].id").isEqualTo(shiftId.toString())
                .jsonPath("$.content[0].takenSlots").isEqualTo(1)
                .jsonPath("$.content[0].waitingCount").isEqualTo(3)
                .jsonPath("$.content[1].waitingCount").isEqualTo(0);
        get("/api/v1/shifts/" + shiftId, dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.waitingCount").isEqualTo(3);
    }

    @Test
    void theDispatcherTakesAWorkerOffTheWaitlistAndTheOthersKeepTheirOrder() {
        var shiftId = publish("Staplerfahrer:in", IN_THREE_DAYS, 8, 1);
        claim(shiftId, activeWorker()).expectStatus().isCreated();
        var first = activeWorker();
        var second = activeWorker();
        var device = device(first);
        join(shiftId, first).expectStatus().isCreated();
        join(shiftId, second).expectStatus().isCreated();
        var entryId = entryId(shiftId, first);

        removeFromWaitlist(shiftId, entryId).expectStatus().isNoContent();

        assertThat(status(shiftId, first)).isNull();
        assertThat(events.all()).contains(new WaitlistEntryRemoved(
                agency.id(), entryId, shiftId, workerId(first), WaitlistEntryRemoved.Cause.REMOVED));
        get("/api/v1/shifts/" + shiftId + "/waitlist", dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[*].position").isEqualTo(List.of(1))
                .jsonPath("$.content[0].worker.id").isEqualTo(workerId(second).toString());
        await().atMost(Duration.ofSeconds(5)).until(() -> !push.sentTo(device).isEmpty());
        assertThat(push.sentTo(device).getFirst().title()).isEqualTo("Nicht mehr auf der Warteliste");
        assertThat(push.sentTo(device).getFirst().data())
                .containsEntry("type", "WAITLIST_REMOVED").containsEntry("shiftId", shiftId.toString());
        await().atMost(Duration.ofSeconds(5)).untilAsserted(() ->
                get("/api/v1/worker/conversation/messages", first)
                        .expectStatus().isOk()
                        .expectBody()
                        .jsonPath("$.content.length()").isEqualTo(1)
                        .jsonPath("$.content[0].event").isEqualTo("WAITLIST_REMOVED_BY_AGENCY")
                        .jsonPath("$.content[0].body").value(body -> assertThat((String) body)
                                .startsWith("Die Agentur hat dich von der Warteliste für „Staplerfahrer:in“ am ")
                                .endsWith(" genommen.")));

        expectProblem(removeFromWaitlist(shiftId, entryId), 404, "waitlist_entry_not_found");
        // A claim is no entry of the waitlist.
        var claimId = jdbc.sql("select id from assignment where shift_id = ? and status = 'PENDING'")
                .param(shiftId).query(UUID.class).single();
        expectProblem(removeFromWaitlist(shiftId, claimId), 404, "waitlist_entry_not_found");
        expectProblem(removeFromWaitlist(UUID.randomUUID(), entryId(shiftId, second)), 404, "shift_not_found");
    }

    @Test
    void onlyTheAgencyOfTheShiftSeesItsWaitlist() {
        var shiftId = publish("Staplerfahrer:in", IN_THREE_DAYS, 8, 1);
        claim(shiftId, activeWorker()).expectStatus().isCreated();
        var worker = activeWorker();
        join(shiftId, worker).expectStatus().isCreated();
        var other = login(data.account(data.agency("Alpen Events"), Role.DISPATCHER), DASHBOARD);

        expectProblem(get("/api/v1/shifts/" + shiftId + "/waitlist", other), 404, "shift_not_found");
        expectProblem(removeFromWaitlist(shiftId, entryId(shiftId, worker), other), 404, "shift_not_found");
        expectProblem(get("/api/v1/shifts/" + shiftId + "/waitlist", worker), 403, "forbidden");
        expectProblem(removeFromWaitlist(shiftId, entryId(shiftId, worker), worker), 403, "forbidden");
        get("/api/v1/shifts/" + shiftId + "/waitlist", admin).expectStatus().isOk();
        assertThat(status(shiftId, worker)).isEqualTo("WAITLISTED");
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

    TokenPair activeWorker(String firstName, String lastName, String phone) {
        var request = signupRequest(TestData.email());
        request.put("firstName", firstName);
        request.put("lastName", lastName);
        request.put("phone", phone);
        var tokens = postSignup(agency.signupCode(), request)
                .expectStatus().isCreated()
                .expectBody(TokenPair.class).returnResult().getResponseBody();
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

    RestTestClient.ResponseSpec put(String uri, Map<String, Object> body) {
        return client.put().uri(uri)
                .headers(headers -> headers.setBearerAuth(dispatcher.accessToken()))
                .contentType(MediaType.APPLICATION_JSON)
                .body(body)
                .exchange();
    }

    /** Registers a new device for the worker and returns its token. */
    String device(TokenPair worker) {
        var token = "device-" + UUID.randomUUID();
        post("/api/v1/worker/push-tokens", worker, Map.of("token", token, "platform", "ANDROID"))
                .expectStatus().isNoContent();
        return token;
    }

    UUID entryId(UUID shiftId, TokenPair worker) {
        return jdbc.sql("select id from assignment where shift_id = ? and worker_id = ?")
                .params(shiftId, workerId(worker)).query(UUID.class).single();
    }

    RestTestClient.ResponseSpec removeFromWaitlist(UUID shiftId, UUID entryId) {
        return removeFromWaitlist(shiftId, entryId, dispatcher);
    }

    RestTestClient.ResponseSpec removeFromWaitlist(UUID shiftId, UUID entryId, TokenPair tokens) {
        return client.delete().uri("/api/v1/shifts/" + shiftId + "/waitlist/" + entryId)
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
