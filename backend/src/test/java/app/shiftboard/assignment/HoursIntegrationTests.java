package app.shiftboard.assignment;

import static org.assertj.core.api.Assertions.assertThat;

import java.sql.Timestamp;
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

/**
 * Check-in and check-out in the app, the hours the agency approves and the list behind the
 * payroll export (ADR 0028).
 */
class HoursIntegrationTests extends IntegrationTest {

    static final Instant IN_THREE_DAYS = Instant.now().plus(Duration.ofDays(3)).truncatedTo(ChronoUnit.SECONDS);

    TestData.Agency agency;

    TokenPair admin;

    TokenPair dispatcher;

    UUID clientId;

    UUID locationId;

    @BeforeEach
    void createAgencyWithStaffAndClient() {
        agency = data.agency("Donau Personal");
        admin = login(data.account(agency, Role.ADMIN), DASHBOARD);
        dispatcher = login(data.account(agency, Role.DISPATCHER), DASHBOARD);
        clientId = data.client(agency, "Nordlicht Logistik");
        locationId = data.location(agency, clientId, "Zentrallager Linz", "Hafenstraße 12, 4020 Linz");
    }

    @Test
    void checkInIsOffUntilAnAdminSwitchesItOn() {
        var worker = activeWorker("Lena", "Hofer");
        var shiftId = publish(IN_THREE_DAYS);
        approve(shiftId, claim(shiftId, worker));
        startSoon(shiftId);

        get("/api/v1/agency/features", dispatcher)
                .expectStatus().isOk()
                .expectBody().jsonPath("$.checkIn").isEqualTo(false);
        get(workerShift(shiftId), worker)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.assignment.checkInFrom").doesNotExist()
                .jsonPath("$.assignment.hoursApproved").isEqualTo(false);
        expectProblem(checkIn(shiftId, worker), 409, "check_in_disabled");
        expectProblem(checkOut(shiftId, worker), 409, "check_in_disabled");
        expectProblem(put("/api/v1/agency/features", dispatcher, Map.of("contactButton", false, "checkIn", true)),
                403, "forbidden");

        put("/api/v1/agency/features", admin, Map.of("contactButton", false, "checkIn", true))
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.checkIn").isEqualTo(true)
                .jsonPath("$.contactButton").isEqualTo(false);
        // A dashboard that does not know check-in yet leaves it as it is.
        put("/api/v1/agency/features", admin, Map.of("contactButton", true))
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.checkIn").isEqualTo(true)
                .jsonPath("$.contactButton").isEqualTo(true);

        get("/api/v1/me", worker)
                .expectStatus().isOk()
                .expectBody().jsonPath("$.agency.features.checkIn").isEqualTo(true);
        get(workerShift(shiftId), worker)
                .expectStatus().isOk()
                .expectBody().jsonPath("$.assignment.checkInFrom").isNotEmpty();
        checkIn(shiftId, worker).expectStatus().isOk();
    }

    @Test
    void aConfirmedWorkerChecksInAndOutOnce() {
        switchCheckInOn();
        var worker = activeWorker("Lena", "Hofer");
        var shiftId = publish(IN_THREE_DAYS);
        var assignmentId = claim(shiftId, worker);
        approve(shiftId, assignmentId);
        var startsAt = startSoon(shiftId);

        get(workerShift(shiftId), worker)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.assignment.checkInFrom").isEqualTo(startsAt.minus(Duration.ofMinutes(30)).toString())
                .jsonPath("$.assignment.checkedInAt").doesNotExist();

        checkIn(shiftId, worker)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.id").isEqualTo(shiftId.toString())
                .jsonPath("$.assignment.checkedInAt").isNotEmpty()
                .jsonPath("$.assignment.checkedOutAt").doesNotExist();
        expectProblem(checkIn(shiftId, worker), 409, "already_checked_in");

        checkOut(shiftId, worker)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.assignment.checkedInAt").isNotEmpty()
                .jsonPath("$.assignment.checkedOutAt").isNotEmpty()
                .jsonPath("$.assignment.hoursApproved").isEqualTo(false);
        expectProblem(checkOut(shiftId, worker), 409, "already_checked_out");

        get(assignments(shiftId), dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[0].checkedInAt").isNotEmpty()
                .jsonPath("$.content[0].checkedOutAt").isNotEmpty()
                .jsonPath("$.content[0].hours").doesNotExist();
        // Only the times are stored.
        var stored = jdbc.sql("select checked_in_at is not null and checked_out_at is not null from assignment where id = ?")
                .param(assignmentId).query(Boolean.class).single();
        assertThat(stored).isTrue();
    }

    @Test
    void checkInNeedsAConfirmedSpotAndTheWindowAroundTheShift() {
        switchCheckInOn();
        var worker = activeWorker("Lena", "Hofer");
        var later = publish(IN_THREE_DAYS);
        approve(later, claim(later, worker));
        expectProblem(checkIn(later, worker), 409, "check_in_not_open");
        expectProblem(checkOut(later, worker), 409, "not_checked_in");

        var pending = publish(IN_THREE_DAYS.plus(Duration.ofDays(1)));
        claim(pending, worker);
        startSoon(pending);
        expectProblem(checkIn(pending, worker), 409, "assignment_not_confirmed");

        var notClaimed = publish(IN_THREE_DAYS.plus(Duration.ofDays(2)));
        expectProblem(checkIn(notClaimed, worker), 404, "assignment_not_found");
        expectProblem(checkIn(UUID.randomUUID(), worker), 404, "shift_not_found");

        var ended = publish(IN_THREE_DAYS.plus(Duration.ofDays(3)));
        approve(ended, claim(ended, worker));
        moveToThePast(ended);
        expectProblem(checkIn(ended, worker), 409, "check_in_not_open");
    }

    @Test
    void theAgencyApprovesTheHoursAndCanSaveThemAgain() {
        switchCheckInOn();
        var worker = activeWorker("Lena", "Hofer");
        var shiftId = publish(IN_THREE_DAYS);
        var assignmentId = claim(shiftId, worker);
        approve(shiftId, assignmentId);
        var startsAt = startSoon(shiftId);
        checkIn(shiftId, worker).expectStatus().isOk();
        expectProblem(approveHours(shiftId, assignmentId, hours(startsAt, startsAt.plus(Duration.ofHours(8)), 30)),
                409, "shift_not_started");

        moveToThePast(shiftId);
        var start = startsAt.minus(Duration.ofDays(5));
        approveHours(shiftId, assignmentId, hours(start, start.plus(Duration.ofHours(8)), 30))
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.id").isEqualTo(assignmentId.toString())
                .jsonPath("$.hours.startedAt").isEqualTo(start.toString())
                .jsonPath("$.hours.endedAt").isEqualTo(start.plus(Duration.ofHours(8)).toString())
                .jsonPath("$.hours.breakMinutes").isEqualTo(30)
                .jsonPath("$.hours.workedMinutes").isEqualTo(450)
                // 7.5 hours at 16,50 €
                .jsonPath("$.hours.grossCents").isEqualTo(12_375)
                .jsonPath("$.hours.approvedAt").isNotEmpty();

        get(workerShift(shiftId), worker)
                .expectStatus().isOk()
                .expectBody().jsonPath("$.assignment.hoursApproved").isEqualTo(true);
        expectProblem(checkOut(shiftId, worker), 409, "hours_approved");

        approveHours(shiftId, assignmentId, hours(start, start.plus(Duration.ofHours(6)), 0))
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.hours.workedMinutes").isEqualTo(360)
                .jsonPath("$.hours.grossCents").isEqualTo(9_900);
        var approvedBy = jdbc.sql("select hours_approved_by from assignment where id = ?")
                .param(assignmentId).query(UUID.class).single();
        assertThat(approvedBy).isNotNull();
    }

    @Test
    void hoursAreCheckedOnTheirFields() {
        var worker = activeWorker("Lena", "Hofer");
        var shiftId = publish(IN_THREE_DAYS);
        var assignmentId = claim(shiftId, worker);
        approve(shiftId, assignmentId);
        moveToThePast(shiftId);
        var start = IN_THREE_DAYS.minus(Duration.ofDays(5));

        expectFieldError(approveHours(shiftId, assignmentId, hours(start, start, 0)), "endedAt", "before_start");
        expectFieldError(approveHours(shiftId, assignmentId, hours(start, start.plus(Duration.ofHours(25)), 0)),
                "endedAt", "too_long");
        expectFieldError(approveHours(shiftId, assignmentId, hours(start, start.plus(Duration.ofHours(1)), 60)),
                "breakMinutes", "too_long");
        expectFieldError(approveHours(shiftId, assignmentId, hours(start, start.plus(Duration.ofHours(1)), 1441)),
                "breakMinutes", "out_of_range");
        var missing = new HashMap<String, Object>(hours(start, start.plus(Duration.ofHours(1)), 0));
        missing.remove("breakMinutes");
        expectFieldError(approveHours(shiftId, assignmentId, missing), "breakMinutes", "required");
        get(assignments(shiftId), dispatcher)
                .expectStatus().isOk()
                .expectBody().jsonPath("$.content[0].hours").doesNotExist();
    }

    @Test
    void onlyWorkersWhoHeldAConfirmedSpotGetHoursAndTheyAreNoNoShows() {
        var lena = activeWorker("Lena", "Hofer");
        var jakob = activeWorker("Jakob", "Steiner");
        var shiftId = publish(IN_THREE_DAYS);
        var confirmed = claim(shiftId, lena);
        approve(shiftId, confirmed);
        var pending = claim(shiftId, jakob);
        moveToThePast(shiftId);
        var start = IN_THREE_DAYS.minus(Duration.ofDays(5));

        expectProblem(approveHours(shiftId, pending, hours(start, start.plus(Duration.ofHours(8)), 30)),
                409, "assignment_not_worked");
        expectProblem(approveHours(shiftId, UUID.randomUUID(), hours(start, start.plus(Duration.ofHours(8)), 30)),
                404, "assignment_not_found");

        approveHours(shiftId, confirmed, hours(start, start.plus(Duration.ofHours(8)), 30)).expectStatus().isOk();
        jdbc.sql("update assignment set status = 'COMPLETED' where id = ?").param(confirmed).update();
        expectProblem(post(assignments(shiftId) + "/" + confirmed + "/no-show", dispatcher), 409, "worker_attended");
    }

    @Test
    void listsTheHoursOfAPeriodEarliestShiftFirst() {
        var lena = activeWorker("Lena", "Hofer");
        var jakob = activeWorker("Jakob", "Steiner");
        var early = publish(IN_THREE_DAYS);
        var earlyLena = claim(early, lena);
        approve(early, earlyLena);
        var late = publish(IN_THREE_DAYS.plus(Duration.ofDays(1)));
        var lateJakob = claim(late, jakob);
        approve(late, lateJakob);
        var undecided = claim(late, lena);
        var future = publish(IN_THREE_DAYS.plus(Duration.ofDays(2)));
        approve(future, claim(future, jakob));
        moveToThePast(early);
        moveToThePast(late);
        var earlyStart = IN_THREE_DAYS.minus(Duration.ofDays(5));
        approveHours(early, earlyLena, hours(earlyStart, earlyStart.plus(Duration.ofHours(8)), 30))
                .expectStatus().isOk();
        assertThat(undecided).isNotNull();

        var from = earlyStart.minus(Duration.ofHours(1));
        var to = IN_THREE_DAYS.plus(Duration.ofDays(4));
        get(hoursUri(from, to, null), dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalElements").isEqualTo(2)
                .jsonPath("$.content[*].assignmentId").isEqualTo(List.of(earlyLena.toString(), lateJakob.toString()))
                .jsonPath("$.content[*].status").isEqualTo(List.of("APPROVED", "OPEN"))
                .jsonPath("$.content[0].worker.firstName").isEqualTo("Lena")
                .jsonPath("$.content[0].worker.lastName").isEqualTo("Hofer")
                .jsonPath("$.content[0].shift.id").isEqualTo(early.toString())
                .jsonPath("$.content[0].shift.title").isEqualTo("Lagerunterstützung")
                .jsonPath("$.content[0].shift.hourlyRateCents").isEqualTo(1650)
                .jsonPath("$.content[0].shift.client.name").isEqualTo("Nordlicht Logistik")
                .jsonPath("$.content[0].shift.location.name").isEqualTo("Zentrallager Linz")
                .jsonPath("$.content[0].hours.workedMinutes").isEqualTo(450)
                .jsonPath("$.content[0].hours.grossCents").isEqualTo(12_375)
                .jsonPath("$.content[1].hours").doesNotExist();

        get(hoursUri(from, to, "OPEN"), dispatcher)
                .expectStatus().isOk()
                .expectBody().jsonPath("$.content[*].assignmentId").isEqualTo(List.of(lateJakob.toString()));
        get(hoursUri(from, to, "APPROVED"), admin)
                .expectStatus().isOk()
                .expectBody().jsonPath("$.content[*].assignmentId").isEqualTo(List.of(earlyLena.toString()));
        // The period is half open: a shift starting at "to" is not in it.
        get(hoursUri(from, earlyStart.plus(Duration.ofDays(1)), null), dispatcher)
                .expectStatus().isOk()
                .expectBody().jsonPath("$.content[*].assignmentId").isEqualTo(List.of(earlyLena.toString()));
        expectFieldError(get(hoursUri(to, from, null), dispatcher), "to", "before_start");
    }

    @Test
    void anotherAgencyAndWorkersHaveNoAccess() {
        switchCheckInOn();
        var worker = activeWorker("Lena", "Hofer");
        var shiftId = publish(IN_THREE_DAYS);
        var assignmentId = claim(shiftId, worker);
        approve(shiftId, assignmentId);
        moveToThePast(shiftId);
        var start = IN_THREE_DAYS.minus(Duration.ofDays(5));
        var period = hoursUri(start.minus(Duration.ofDays(1)), start.plus(Duration.ofDays(1)), null);

        var other = data.agency("Alpen Events");
        var otherDispatcher = login(data.account(other, Role.DISPATCHER), DASHBOARD);
        expectProblem(put(assignments(shiftId) + "/" + assignmentId + "/hours", otherDispatcher,
                hours(start, start.plus(Duration.ofHours(8)), 30)), 404, "shift_not_found");
        get(period, otherDispatcher)
                .expectStatus().isOk()
                .expectBody().jsonPath("$.totalElements").isEqualTo(0);

        expectProblem(get(period, worker), 403, "forbidden");
        expectProblem(approveHours(shiftId, assignmentId, hours(start, start.plus(Duration.ofHours(8)), 30), worker),
                403, "forbidden");
        expectProblem(checkIn(shiftId, dispatcher), 403, "forbidden");
    }

    private void switchCheckInOn() {
        put("/api/v1/agency/features", admin, Map.of("contactButton", false, "checkIn", true))
                .expectStatus().isOk();
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

    private UUID publish(Instant startsAt) {
        var request = new HashMap<String, Object>();
        request.put("clientId", clientId);
        request.put("locationId", locationId);
        request.put("title", "Lagerunterstützung");
        request.put("startsAt", startsAt.toString());
        request.put("endsAt", startsAt.plus(Duration.ofHours(8)).toString());
        request.put("hourlyRateCents", 1650);
        request.put("slots", 3);
        request.put("publish", true);
        var created = post("/api/v1/shifts", dispatcher, request)
                .expectStatus().isCreated()
                .expectBody(Map.class).returnResult().getResponseBody();
        return UUID.fromString((String) created.get("id"));
    }

    /** Claims a spot for the worker and returns the id of the assignment. */
    private UUID claim(UUID shiftId, TokenPair worker) {
        var claimed = post(workerShift(shiftId) + "/claim", worker)
                .expectStatus().isCreated()
                .expectBody(Map.class).returnResult().getResponseBody();
        return UUID.fromString((String) ((Map<?, ?>) claimed.get("assignment")).get("id"));
    }

    private void approve(UUID shiftId, UUID assignmentId) {
        post(assignments(shiftId) + "/" + assignmentId + "/approve", dispatcher).expectStatus().isOk();
    }

    /** Moves the shift and its claims so that it starts in ten minutes, and returns the new start. */
    private Instant startSoon(UUID shiftId) {
        var startsAt = Instant.now().plus(Duration.ofMinutes(10)).truncatedTo(ChronoUnit.SECONDS);
        for (var table : List.of("shift", "assignment")) {
            var column = "shift".equals(table) ? "id" : "shift_id";
            jdbc.sql("update " + table + " set starts_at = ?, ends_at = ? where " + column + " = ?")
                    .params(Timestamp.from(startsAt), Timestamp.from(startsAt.plus(Duration.ofHours(8))), shiftId)
                    .update();
        }
        return startsAt;
    }

    /** Moves the shift and its claims five days back, so that it has ended. */
    private void moveToThePast(UUID shiftId) {
        // Hours, not days: a day across a daylight saving change is not 24 hours long.
        var back = "interval '120 hours'";
        jdbc.sql("update shift set starts_at = starts_at - " + back + ", ends_at = ends_at - " + back
                + " where id = ?").param(shiftId).update();
        jdbc.sql("update assignment set starts_at = starts_at - " + back + ", ends_at = ends_at - " + back
                + " where shift_id = ?").param(shiftId).update();
    }

    private static Map<String, Object> hours(Instant startedAt, Instant endedAt, int breakMinutes) {
        return Map.of("startedAt", startedAt.toString(), "endedAt", endedAt.toString(), "breakMinutes", breakMinutes);
    }

    private static String workerShift(UUID shiftId) {
        return "/api/v1/worker/shifts/" + shiftId;
    }

    private static String assignments(UUID shiftId) {
        return "/api/v1/shifts/" + shiftId + "/assignments";
    }

    private static String hoursUri(Instant from, Instant to, String status) {
        return "/api/v1/hours?from=" + from + "&to=" + to + (status == null ? "" : "&status=" + status);
    }

    private RestTestClient.ResponseSpec checkIn(UUID shiftId, TokenPair worker) {
        return post(workerShift(shiftId) + "/check-in", worker);
    }

    private RestTestClient.ResponseSpec checkOut(UUID shiftId, TokenPair worker) {
        return post(workerShift(shiftId) + "/check-out", worker);
    }

    private RestTestClient.ResponseSpec approveHours(UUID shiftId, UUID assignmentId, Map<String, Object> body) {
        return approveHours(shiftId, assignmentId, body, dispatcher);
    }

    private RestTestClient.ResponseSpec approveHours(
            UUID shiftId, UUID assignmentId, Map<String, Object> body, TokenPair tokens) {
        return put(assignments(shiftId) + "/" + assignmentId + "/hours", tokens, body);
    }

    private RestTestClient.ResponseSpec put(String uri, TokenPair tokens, Map<String, Object> body) {
        return client.put().uri(uri)
                .headers(headers -> headers.setBearerAuth(tokens.accessToken()))
                .contentType(MediaType.APPLICATION_JSON)
                .body(body)
                .exchange();
    }

    private static void expectFieldError(RestTestClient.ResponseSpec response, String field, String code) {
        expectProblem(response, 400, "validation_failed")
                .jsonPath("$.errors.length()").isEqualTo(1)
                .jsonPath("$.errors[0].field").isEqualTo(field)
                .jsonPath("$.errors[0].code").isEqualTo(code);
    }
}
