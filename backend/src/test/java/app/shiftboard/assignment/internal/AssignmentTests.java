package app.shiftboard.assignment.internal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatExceptionOfType;

import java.time.Duration;
import java.time.Instant;
import java.util.UUID;
import java.util.function.Consumer;

import org.junit.jupiter.api.Test;

class AssignmentTests {

    private static final Instant START = Instant.parse("2026-11-02T07:00:00Z");

    private static final Instant BEFORE = START.minus(Duration.ofDays(3));

    private static final Duration DEADLINE = Duration.ofHours(24);

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

    private static Assignment pending() {
        return Assignment.claim(
                UUID.randomUUID(), UUID.randomUUID(), START, START.plus(Duration.ofHours(8)), BEFORE, false);
    }

    private static Assignment confirmed() {
        var assignment = pending();
        assignment.approve(BEFORE);
        return assignment;
    }

    private static void assertConflict(String code, Assignment assignment, Consumer<Assignment> change) {
        var status = assignment.getStatus();
        assertThatExceptionOfType(AssignmentConflictException.class)
                .isThrownBy(() -> change.accept(assignment))
                .satisfies(conflict -> assertThat(conflict.getCode()).isEqualTo(code));
        assertThat(assignment.getStatus()).isEqualTo(status);
    }
}
