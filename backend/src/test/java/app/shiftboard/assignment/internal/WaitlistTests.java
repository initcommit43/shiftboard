package app.shiftboard.assignment.internal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatExceptionOfType;
import static org.assertj.core.api.Assertions.assertThatIllegalStateException;

import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.function.Consumer;

import app.shiftboard.client.LocationDetails;
import app.shiftboard.identity.StaffContact;
import app.shiftboard.shift.ShiftDetails;
import org.junit.jupiter.api.Test;

class WaitlistTests {

    private static final Instant START = Instant.parse("2026-11-02T07:00:00Z");

    private static final Instant END = START.plus(Duration.ofHours(8));

    private static final Instant BEFORE = START.minus(Duration.ofDays(3));

    private static final UUID WORKER = UUID.randomUUID();

    @Test
    void aWorkerJoinsTheWaitlistOfAFullShiftWithoutTakingASpot() {
        var shift = shift("PUBLISHED", 2, 2);

        var entry = Assignment.join(shift, WORKER, true, BEFORE);

        assertThat(entry.getStatus()).isEqualTo(AssignmentStatus.WAITLISTED);
        assertThat(entry.waiting()).isTrue();
        assertThat(entry.holdsSlot()).isFalse();
        assertThat(entry.worked()).isFalse();
        assertThat(entry.getShiftId()).isEqualTo(shift.id());
        assertThat(entry.getWorkerId()).isEqualTo(WORKER);
        assertThat(entry.getStartsAt()).isEqualTo(START);
        assertThat(entry.getEndsAt()).isEqualTo(END);
        assertThat(entry.getClaimedAt()).as("joined at").isEqualTo(BEFORE);
        assertThat(entry.getDecidedAt()).isNull();
        assertThat(entry.cancellableUntilIfHolding(Duration.ofHours(24))).isEmpty();
    }

    @Test
    void theWaitlistIsWaitedOnNeitherInHoldingNorInWorkedStatuses() {
        assertThat(AssignmentStatus.HOLDING).doesNotContain(AssignmentStatus.WAITLISTED);
        assertThat(AssignmentStatus.WORKED).doesNotContain(AssignmentStatus.WAITLISTED);
    }

    @Test
    void joiningNeedsTheSettingAndAPublishedFullShiftThatHasNotStarted() {
        assertConflict("waitlist_disabled", () -> Assignment.join(shift("PUBLISHED", 2, 2), WORKER, false, BEFORE));
        assertConflict("shift_not_full", () -> Assignment.join(shift("PUBLISHED", 2, 1), WORKER, true, BEFORE));
        assertConflict("shift_not_open", () -> Assignment.join(shift("CANCELLED", 2, 0), WORKER, true, BEFORE));
        assertConflict("shift_not_open", () -> Assignment.join(shift("COMPLETED", 2, 2), WORKER, true, BEFORE));
        assertConflict("shift_started", () -> Assignment.join(shift("PUBLISHED", 2, 2), WORKER, true, START));
        assertConflict("shift_started",
                () -> Assignment.join(shift("PUBLISHED", 2, 2), WORKER, true, START.plusSeconds(1)));
    }

    @Test
    void movingUpTurnsThePlaceIntoAPendingClaimMadeNow() {
        var entry = waiting();
        var now = BEFORE.plus(Duration.ofHours(5));

        entry.moveUp(now, false);

        assertThat(entry.getStatus()).isEqualTo(AssignmentStatus.PENDING);
        assertThat(entry.holdsSlot()).isTrue();
        assertThat(entry.waiting()).isFalse();
        assertThat(entry.getClaimedAt()).isEqualTo(now);
        assertThat(entry.getDecidedAt()).isNull();
    }

    @Test
    void withAutoConfirmMovingUpConfirmsRightAway() {
        var entry = waiting();
        var now = BEFORE.plus(Duration.ofHours(5));

        entry.moveUp(now, true);

        assertThat(entry.getStatus()).isEqualTo(AssignmentStatus.CONFIRMED);
        assertThat(entry.getClaimedAt()).isEqualTo(now);
        assertThat(entry.getDecidedAt()).isEqualTo(now);
    }

    @Test
    void onlyAPlaceInLineMovesUpOrIsLeft() {
        var claim = Assignment.claim(UUID.randomUUID(), WORKER, START, END, BEFORE, false);

        assertThatIllegalStateException().isThrownBy(() -> claim.moveUp(BEFORE, false));
        assertThatIllegalStateException().isThrownBy(() -> claim.leave(BEFORE));
        assertThat(claim.getStatus()).isEqualTo(AssignmentStatus.PENDING);
    }

    @Test
    void aWorkerLeavesTheWaitlistUntilTheStart() {
        waiting().leave(START.minusSeconds(1));

        assertConflict("shift_started", () -> waiting().leave(START));
    }

    @Test
    void aPlaceInLineFollowsTheShiftToItsNewTime() {
        var entry = waiting();

        entry.reschedule(START.plus(Duration.ofHours(2)), END.plus(Duration.ofHours(2)));

        assertThat(entry.getStartsAt()).isEqualTo(START.plus(Duration.ofHours(2)));
        assertThat(entry.getEndsAt()).isEqualTo(END.plus(Duration.ofHours(2)));
        assertThat(entry.waiting()).isTrue();
    }

    @Test
    void aPlaceInLineIsNoClaimTheAgencyDecidesOn() {
        assertConflictOn("assignment_not_pending", waiting(), entry -> entry.approve(BEFORE));
        assertConflictOn("assignment_not_pending", waiting(), entry -> entry.reject(BEFORE));
        assertConflictOn("assignment_not_active", waiting(), entry -> entry.remove("Zu spät", BEFORE));
        assertConflictOn("assignment_not_active", waiting(), entry -> entry.cancelByWorker(BEFORE, Duration.ZERO));
        assertConflictOn("assignment_not_confirmed", waiting(), entry -> entry.checkIn(START));
    }

    private static Assignment waiting() {
        return Assignment.join(shift("PUBLISHED", 1, 1), WORKER, true, BEFORE);
    }

    static ShiftDetails shift(String status, int slots, int takenSlots) {
        return new ShiftDetails(
                UUID.randomUUID(), "Lagerunterstützung", null, status,
                new ShiftDetails.Client(UUID.randomUUID(), "Nordlicht Logistik"),
                new LocationDetails(UUID.randomUUID(), "Zentrallager Linz", "Hafenstraße 12, 4020 Linz"),
                START, END, false, 1650, slots, takenSlots, List.of(),
                new StaffContact("Anna Berger", null));
    }

    private static void assertConflict(String code, Runnable change) {
        assertThatExceptionOfType(AssignmentConflictException.class)
                .isThrownBy(change::run)
                .satisfies(conflict -> assertThat(conflict.getCode()).isEqualTo(code));
    }

    private static void assertConflictOn(String code, Assignment entry, Consumer<Assignment> change) {
        assertConflict(code, () -> change.accept(entry));
        assertThat(entry.getStatus()).isEqualTo(AssignmentStatus.WAITLISTED);
    }
}
