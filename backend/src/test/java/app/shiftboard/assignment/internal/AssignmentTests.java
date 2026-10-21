package app.shiftboard.assignment.internal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatExceptionOfType;

import java.time.Duration;
import java.time.Instant;
import java.util.UUID;
import java.util.function.Consumer;

import app.shiftboard.system.InvalidFieldException;
import org.junit.jupiter.api.Test;

class AssignmentTests {

    private static final Instant START = Instant.parse("2026-11-02T07:00:00Z");

    private static final Instant BEFORE = START.minus(Duration.ofDays(3));

    private static final Duration DEADLINE = Duration.ofHours(24);

    private static final Instant END = START.plus(Duration.ofHours(8));

    private static final UUID APPROVER = UUID.randomUUID();

    @Test
    void aNewClaimIsPendingAndBooksTheTimeOfTheShift() {
        var shiftId = UUID.randomUUID();
        var workerId = UUID.randomUUID();
        var now = START.minus(Duration.ofDays(1));

        var assignment = Assignment.claim(shiftId, workerId, START, START.plus(Duration.ofHours(8)), now, false);

        assertThat(assignment.getStatus()).isEqualTo(AssignmentStatus.PENDING);
        assertThat(assignment.getShiftId()).isEqualTo(shiftId);
        assertThat(assignment.getWorkerId()).isEqualTo(workerId);
        assertThat(assignment.getStartsAt()).isEqualTo(START);
        assertThat(assignment.getEndsAt()).isEqualTo(START.plus(Duration.ofHours(8)));
        assertThat(assignment.getClaimedAt()).isEqualTo(now);
        assertThat(assignment.getDecidedAt()).isNull();
    }

    @Test
    void withAutoConfirmAClaimIsConfirmedRightAway() {
        var assignment = Assignment.claim(
                UUID.randomUUID(), UUID.randomUUID(), START, START.plus(Duration.ofHours(8)), BEFORE, true);

        assertThat(assignment.getStatus()).isEqualTo(AssignmentStatus.CONFIRMED);
        assertThat(assignment.getDecidedAt()).isEqualTo(BEFORE);
    }

    @Test
    void pendingAndConfirmedClaimsHoldASpot() {
        assertThat(AssignmentStatus.HOLDING)
                .containsExactlyInAnyOrder(AssignmentStatus.PENDING, AssignmentStatus.CONFIRMED);
    }

    @Test
    void aPendingClaimIsApprovedOrRejectedOnce() {
        var approved = pending();
        approved.approve(BEFORE);
        assertThat(approved.getStatus()).isEqualTo(AssignmentStatus.CONFIRMED);
        assertThat(approved.getDecidedAt()).isEqualTo(BEFORE);
        assertConflict("assignment_not_pending", approved, assignment -> assignment.approve(BEFORE));
        assertConflict("assignment_not_pending", approved, assignment -> assignment.reject(BEFORE));

        var rejected = pending();
        rejected.reject(BEFORE);
        assertThat(rejected.getStatus()).isEqualTo(AssignmentStatus.REJECTED);
        assertThat(rejected.holdsSlot()).isFalse();
        assertConflict("assignment_not_pending", rejected, assignment -> assignment.approve(BEFORE));
    }

    @Test
    void aWorkerDropsOutUntilTheDeadline() {
        var pending = pending();
        var confirmed = confirmed();
        var lastMoment = START.minus(DEADLINE).minusSeconds(1);

        assertThat(pending.cancellableUntilIfHolding(DEADLINE)).contains(START.minus(DEADLINE));
        pending.cancelByWorker(lastMoment, DEADLINE);
        confirmed.cancelByWorker(lastMoment, DEADLINE);

        for (var assignment : java.util.List.of(pending, confirmed)) {
            assertThat(assignment.getStatus()).isEqualTo(AssignmentStatus.CANCELLED);
            assertThat(assignment.getCancelledBy()).isEqualTo(CancelledBy.WORKER);
            assertThat(assignment.getReason()).isNull();
            assertThat(assignment.getDecidedAt()).isEqualTo(lastMoment);
            assertThat(assignment.cancellableUntilIfHolding(DEADLINE)).isEmpty();
        }
        assertConflict("assignment_not_active", pending, assignment -> assignment.cancelByWorker(BEFORE, DEADLINE));
    }

    @Test
    void afterTheDeadlineTheWorkerCannotDropOut() {
        assertConflict(
                "cancellation_deadline_passed", confirmed(),
                assignment -> assignment.cancelByWorker(START.minus(DEADLINE), DEADLINE));
        assertConflict(
                "cancellation_deadline_passed", confirmed(),
                assignment -> assignment.cancelByWorker(START.plusSeconds(1), Duration.ZERO));
        // Without a deadline, dropping out is possible until the start.
        var assignment = confirmed();
        assignment.cancelByWorker(START.minusSeconds(1), Duration.ZERO);
        assertThat(assignment.getStatus()).isEqualTo(AssignmentStatus.CANCELLED);
    }

    @Test
    void theAgencyRemovesAPendingOrConfirmedWorkerWithAReason() {
        var assignment = confirmed();

        assignment.remove("Kann laut Rücksprache nicht kommen", START.minusSeconds(60));

        assertThat(assignment.getStatus()).isEqualTo(AssignmentStatus.CANCELLED);
        assertThat(assignment.getCancelledBy()).isEqualTo(CancelledBy.AGENCY);
        assertThat(assignment.getReason()).isEqualTo("Kann laut Rücksprache nicht kommen");
        assertConflict("assignment_not_active", assignment, again -> again.remove("Nochmal", BEFORE));
    }

    @Test
    void aCancelledShiftCancelsItsClaims() {
        var assignment = pending();

        assignment.cancelWithShift(BEFORE);

        assertThat(assignment.getStatus()).isEqualTo(AssignmentStatus.CANCELLED);
        assertThat(assignment.getCancelledBy()).isEqualTo(CancelledBy.AGENCY);
        assertThat(assignment.getReason()).isNull();
    }

    @Test
    void whenTheShiftTookPlaceConfirmedClaimsAreCompletedAndUndecidedOnesRejected() {
        var confirmed = confirmed();
        var pending = pending();
        var end = START.plus(Duration.ofHours(8));

        confirmed.completeWithShift(end);
        pending.completeWithShift(end);

        assertThat(confirmed.getStatus()).isEqualTo(AssignmentStatus.COMPLETED);
        assertThat(pending.getStatus()).isEqualTo(AssignmentStatus.REJECTED);
        assertThat(confirmed.getDecidedAt()).isEqualTo(end);
    }

    @Test
    void onlyACompletedAssignmentCanBeANoShow() {
        var assignment = confirmed();
        assertConflict("assignment_not_completed", assignment, noShow -> noShow.markNoShow(BEFORE));

        assignment.completeWithShift(START.plus(Duration.ofHours(8)));
        assignment.markNoShow(START.plus(Duration.ofHours(9)));

        assertThat(assignment.getStatus()).isEqualTo(AssignmentStatus.NO_SHOW);
        assertConflict("assignment_not_completed", assignment, noShow -> noShow.markNoShow(BEFORE));
    }

    @Test
    void aConfirmedWorkerChecksInOnceFromHalfAnHourBeforeTheStartUntilTheEnd() {
        var assignment = confirmed();

        assertThat(assignment.checkInFrom()).isEqualTo(START.minus(Duration.ofMinutes(30)));
        assertConflict("check_in_not_open", assignment, a -> a.checkIn(START.minus(Duration.ofMinutes(31))));
        assertConflict("check_in_not_open", assignment, a -> a.checkIn(END));

        assignment.checkIn(START.minus(Duration.ofMinutes(30)));

        assertThat(assignment.getCheckedInAt()).isEqualTo(START.minus(Duration.ofMinutes(30)));
        assertConflict("already_checked_in", assignment, a -> a.checkIn(START));

        var late = confirmed();
        late.checkIn(END.minusSeconds(1));
        assertThat(late.getCheckedInAt()).isEqualTo(END.minusSeconds(1));
    }

    @Test
    void onlyAConfirmedWorkerChecksIn() {
        assertConflict("assignment_not_confirmed", pending(), a -> a.checkIn(START));

        var removed = confirmed();
        removed.remove("Krank gemeldet", BEFORE);
        assertConflict("assignment_not_confirmed", removed, a -> a.checkIn(START));
    }

    @Test
    void aWorkerChecksOutOnceAfterCheckingInAlsoAfterTheShiftCompleted() {
        var assignment = confirmed();
        assertConflict("not_checked_in", assignment, a -> a.checkOut(START));

        assignment.checkIn(START);
        assignment.completeWithShift(END.plusSeconds(60));
        assignment.checkOut(END.plus(Duration.ofMinutes(20)));

        assertThat(assignment.getStatus()).isEqualTo(AssignmentStatus.COMPLETED);
        assertThat(assignment.getCheckedOutAt()).isEqualTo(END.plus(Duration.ofMinutes(20)));
        assertConflict("already_checked_out", assignment, a -> a.checkOut(END.plus(Duration.ofHours(1))));
    }

    @Test
    void noCheckOutOnceTheHoursAreApprovedOrTheWorkerWasRemoved() {
        var approved = confirmed();
        approved.checkIn(START);
        approved.approveHours(START, END, 30, APPROVER, END);
        assertConflict("hours_approved", approved, a -> a.checkOut(END));

        var removed = confirmed();
        removed.checkIn(START);
        removed.remove("Nach Hause geschickt", START.plus(Duration.ofHours(1)));
        assertConflict("assignment_not_confirmed", removed, a -> a.checkOut(START.plus(Duration.ofHours(2))));
    }

    @Test
    void theAgencyApprovesTheHoursOfAWorkerWithAConfirmedSpotOnceTheShiftStarted() {
        var assignment = confirmed();
        assertThat(assignment.hours()).isEmpty();
        assertConflict("shift_not_started", assignment, a -> a.approveHours(START, END, 30, APPROVER, BEFORE));

        assignment.approveHours(START.plus(Duration.ofMinutes(5)), END, 30, APPROVER, START);

        var hours = assignment.hours().orElseThrow();
        assertThat(hours.startedAt()).isEqualTo(START.plus(Duration.ofMinutes(5)));
        assertThat(hours.endedAt()).isEqualTo(END);
        assertThat(hours.breakMinutes()).isEqualTo(30);
        assertThat(hours.workedMinutes()).isEqualTo(8 * 60 - 5 - 30);
        assertThat(hours.approvedAt()).isEqualTo(START);

        // Saving again replaces the hours, also after the shift completed.
        assignment.completeWithShift(END);
        assignment.approveHours(START, END, 0, APPROVER, END.plusSeconds(60));
        assertThat(assignment.hours().orElseThrow().workedMinutes()).isEqualTo(8 * 60);
        assertThat(assignment.hours().orElseThrow().approvedAt()).isEqualTo(END.plusSeconds(60));
    }

    @Test
    void onlyAWorkerWhoHeldAConfirmedSpotGetsHours() {
        assertConflict("assignment_not_worked", pending(), a -> a.approveHours(START, END, 0, APPROVER, END));

        var noShow = confirmed();
        noShow.completeWithShift(END);
        noShow.markNoShow(END);
        assertConflict("assignment_not_worked", noShow, a -> a.approveHours(START, END, 0, APPROVER, END));
    }

    @Test
    void hoursEndAfterTheyStartLastAtMostADayAndTheBreakIsShorter() {
        var assignment = confirmed();

        assertInvalid("endedAt", "before_start", () -> assignment.approveHours(END, START, 0, APPROVER, END));
        assertInvalid("endedAt", "before_start", () -> assignment.approveHours(START, START, 0, APPROVER, END));
        assertInvalid("endedAt", "too_long", () -> assignment.approveHours(
                START, START.plus(Duration.ofHours(24)).plusSeconds(60), 0, APPROVER, END));
        assertInvalid("breakMinutes", "too_long", () -> assignment.approveHours(START, END, 8 * 60, APPROVER, END));
        assertInvalid("breakMinutes", "out_of_range", () -> assignment.approveHours(START, END, -1, APPROVER, END));
        assertThat(assignment.hours()).isEmpty();

        assignment.approveHours(START, START.plus(Duration.ofHours(24)), 8 * 60 - 1, APPROVER, END);
        assertThat(assignment.hours()).isPresent();
    }

    @Test
    void grossPayIsTheWorkedMinutesTimesTheRateRoundedHalfUp() {
        var hours = new WorkedHours(START, START.plus(Duration.ofMinutes(480)), 30, END);

        assertThat(hours.workedMinutes()).isEqualTo(450);
        assertThat(hours.grossCents(1650)).isEqualTo(12_375);
        // 1 minute at 16,50 € is 27.5 cents.
        assertThat(new WorkedHours(START, START.plus(Duration.ofMinutes(1)), 0, END).grossCents(1650)).isEqualTo(28);
        // 1 minute at 16,49 € is 27.48 cents.
        assertThat(new WorkedHours(START, START.plus(Duration.ofMinutes(1)), 0, END).grossCents(1649)).isEqualTo(27);
    }

    @Test
    void aWorkerWhoCheckedInOrHasHoursIsNoNoShow() {
        var checkedIn = confirmed();
        checkedIn.checkIn(START);
        checkedIn.completeWithShift(END);
        assertConflict("worker_attended", checkedIn, a -> a.markNoShow(END));

        var withHours = confirmed();
        withHours.approveHours(START, END, 30, APPROVER, END);
        withHours.completeWithShift(END);
        assertConflict("worker_attended", withHours, a -> a.markNoShow(END));
    }

    private static Assignment pending() {
        return Assignment.claim(
                UUID.randomUUID(), UUID.randomUUID(), START, START.plus(Duration.ofHours(8)), BEFORE, false);
    }

    private static Assignment confirmed() {
        var assignment = pending();
        assignment.approve(BEFORE);
        return assignment;
    }

    private static void assertInvalid(String field, String code, Runnable change) {
        assertThatExceptionOfType(InvalidFieldException.class)
                .isThrownBy(change::run)
                .satisfies(invalid -> {
                    assertThat(invalid.getField()).isEqualTo(field);
                    assertThat(invalid.getCode()).isEqualTo(code);
                });
    }

    private static void assertConflict(String code, Assignment assignment, Consumer<Assignment> change) {
        var status = assignment.getStatus();
        assertThatExceptionOfType(AssignmentConflictException.class)
                .isThrownBy(() -> change.accept(assignment))
                .satisfies(conflict -> assertThat(conflict.getCode()).isEqualTo(code));
        assertThat(assignment.getStatus()).isEqualTo(status);
    }
}
