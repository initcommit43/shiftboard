package app.shiftboard.shift.internal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatExceptionOfType;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.Instant;
import java.util.Set;
import java.util.UUID;

import app.shiftboard.system.InvalidFieldException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

class ShiftTests {

    private static final Instant START = Instant.parse("2026-11-02T07:00:00Z");

    @Test
    void aNewShiftIsADraftWithNoSlotTaken() {
        var qualification = UUID.randomUUID();

        var shift = shift(START.plus(Duration.ofHours(8)), "16.50", 5, Set.of(qualification));

        assertThat(shift.getStatus()).isEqualTo(ShiftStatus.DRAFT);
        assertThat(shift.getTakenSlots()).isZero();
        assertThat(shift.getSlots()).isEqualTo(5);
        assertThat(shift.getHourlyRate()).isEqualByComparingTo("16.50");
        assertThat(shift.getQualificationIds()).containsExactly(qualification);
    }

    @Test
    void aDraftCanBePublishedOnce() {
        var shift = shift(START.plus(Duration.ofHours(8)), "16.50", 5, Set.of());

        shift.publish();

        assertThat(shift.getStatus()).isEqualTo(ShiftStatus.PUBLISHED);
        assertThatExceptionOfType(ShiftNotDraftException.class).isThrownBy(shift::publish);
    }

    @Test
    void theEndHasToBeAfterTheStart() {
        assertRejected("endsAt", "before_start", () -> shift(START, "16.50", 5, Set.of()));
        assertRejected(
                "endsAt", "before_start", () -> shift(START.minus(Duration.ofMinutes(1)), "16.50", 5, Set.of()));
    }

    @ParameterizedTest
    @ValueSource(strings = {"0", "0.00", "-1"})
    void theHourlyRateHasToBePositive(String hourlyRate) {
        assertRejected(
                "hourlyRateCents", "out_of_range",
                () -> shift(START.plus(Duration.ofHours(8)), hourlyRate, 5, Set.of()));
    }

    @ParameterizedTest
    @ValueSource(ints = {0, -1, 501})
    void aShiftNeedsBetweenOneAndFiveHundredSlots(int slots) {
        assertRejected(
                "slots", "out_of_range", () -> shift(START.plus(Duration.ofHours(8)), "16.50", slots, Set.of()));
    }

    @Test
    void aClaimTakesOneSlotUntilTheShiftIsFull() {
        var shift = shift(START.plus(Duration.ofHours(8)), "16.50", 2, Set.of());
        shift.publish();

        shift.claim(START.minus(Duration.ofDays(1)));
        shift.claim(START.minus(Duration.ofSeconds(1)));

        assertThat(shift.getTakenSlots()).isEqualTo(2);
        assertNotClaimable("shift_full", shift, START.minus(Duration.ofSeconds(1)));
        assertThat(shift.getTakenSlots()).isEqualTo(2);
    }

    @Test
    void aShiftCannotBeClaimedOnceItHasStarted() {
        var shift = shift(START.plus(Duration.ofHours(8)), "16.50", 2, Set.of());
        shift.publish();

        assertNotClaimable("shift_started", shift, START);
        assertNotClaimable("shift_started", shift, START.plus(Duration.ofHours(1)));
        assertThat(shift.getTakenSlots()).isZero();
    }

    @Test
    void onlyAPublishedShiftCanBeClaimed() {
        var draft = shift(START.plus(Duration.ofHours(8)), "16.50", 2, Set.of());

        assertNotClaimable("shift_not_open", draft, START.minus(Duration.ofDays(1)));
        assertThat(draft.getTakenSlots()).isZero();
    }

    @Test
    void releasingASlotFreesItOnAPublishedShiftOnly() {
        var shift = shift(START.plus(Duration.ofHours(8)), "16.50", 2, Set.of());
        shift.publish();
        shift.claim(START.minus(Duration.ofDays(1)));
        shift.claim(START.minus(Duration.ofDays(1)));

        shift.release();

        assertThat(shift.getTakenSlots()).isEqualTo(1);
        shift.cancel(START.minus(Duration.ofDays(1)));
        shift.release();
        assertThat(shift.getTakenSlots()).isZero();
    }

    @Test
    void aDraftOrPublishedShiftCanBeCancelledUntilItEnds() {
        var end = START.plus(Duration.ofHours(8));
        var draft = shift(end, "16.50", 2, Set.of());
        var running = shift(end, "16.50", 2, Set.of());
        running.publish();
        running.claim(START.minus(Duration.ofDays(1)));

        draft.cancel(START.minus(Duration.ofDays(1)));
        running.cancel(end.minusSeconds(1));

        assertThat(draft.getStatus()).isEqualTo(ShiftStatus.CANCELLED);
        assertThat(running.getStatus()).isEqualTo(ShiftStatus.CANCELLED);
        assertThat(running.getTakenSlots()).isZero();
        assertThatExceptionOfType(ShiftNotCancellableException.class).isThrownBy(() -> running.cancel(START));

        var ended = shift(end, "16.50", 2, Set.of());
        ended.publish();
        assertThatExceptionOfType(ShiftNotCancellableException.class).isThrownBy(() -> ended.cancel(end));
        ended.complete(end);
        assertThatExceptionOfType(ShiftNotCancellableException.class)
                .isThrownBy(() -> ended.cancel(START.minus(Duration.ofDays(1))));
    }

    @Test
    void aPublishedShiftIsCompletedOnceItHasEnded() {
        var end = START.plus(Duration.ofHours(8));
        var shift = shift(end, "16.50", 2, Set.of());
        assertThatExceptionOfType(IllegalStateException.class).isThrownBy(() -> shift.complete(end));
        shift.publish();
        assertThatExceptionOfType(IllegalStateException.class).isThrownBy(() -> shift.complete(end.minusSeconds(1)));

        shift.complete(end);

        assertThat(shift.getStatus()).isEqualTo(ShiftStatus.COMPLETED);
        assertNotClaimable("shift_not_open", shift, START.minus(Duration.ofDays(1)));
    }

    private static void assertNotClaimable(String code, Shift shift, Instant now) {
        assertThatExceptionOfType(ShiftNotClaimableException.class)
                .isThrownBy(() -> shift.claim(now))
                .satisfies(rejection -> assertThat(rejection.getCode()).isEqualTo(code));
    }

    private static Shift shift(Instant endsAt, String hourlyRate, int slots, Set<UUID> qualificationIds) {
        return new Shift(
                UUID.randomUUID(), UUID.randomUUID(), UUID.randomUUID(), "Lagerunterstützung", null, START, endsAt,
                false, new BigDecimal(hourlyRate), slots, qualificationIds);
    }

    private static void assertRejected(String field, String code, Runnable creation) {
        assertThatExceptionOfType(InvalidFieldException.class)
                .isThrownBy(creation::run)
                .satisfies(rejection -> {
                    assertThat(rejection.getField()).isEqualTo(field);
                    assertThat(rejection.getCode()).isEqualTo(code);
                });
    }
}
