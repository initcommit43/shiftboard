package app.shiftboard.shift.internal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatExceptionOfType;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.Instant;
import java.util.Set;
import java.util.UUID;

import app.shiftboard.shift.ShiftChanged.Change;
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

    @Test
    void anUpdateReplacesEveryFieldAndNamesWhatWorkersSeeChanged() {
        var shift = shift(START.plus(Duration.ofHours(8)), "16.50", 5, Set.of());
        shift.publish();
        shift.claim(START.minus(Duration.ofDays(1)));
        var client = UUID.randomUUID();
        var location = UUID.randomUUID();
        var qualification = UUID.randomUUID();
        var start = START.plus(Duration.ofHours(1));

        var changes = shift.update(
                client, location, "Kommissionierung", "Tor 3", start, start.plus(Duration.ofHours(6)), true,
                new BigDecimal("17.00"), 4, Set.of(qualification), START.minus(Duration.ofDays(1)));

        assertThat(changes).containsExactlyInAnyOrder(Change.values());
        assertThat(shift.getClientId()).isEqualTo(client);
        assertThat(shift.getLocationId()).isEqualTo(location);
        assertThat(shift.getTitle()).isEqualTo("Kommissionierung");
        assertThat(shift.getDescription()).isEqualTo("Tor 3");
        assertThat(shift.getStartsAt()).isEqualTo(start);
        assertThat(shift.getEndsAt()).isEqualTo(start.plus(Duration.ofHours(6)));
        assertThat(shift.isEndIsEstimate()).isTrue();
        assertThat(shift.getHourlyRate()).isEqualByComparingTo("17.00");
        assertThat(shift.getSlots()).isEqualTo(4);
        assertThat(shift.getQualificationIds()).containsExactly(qualification);
        assertThat(shift.getStatus()).isEqualTo(ShiftStatus.PUBLISHED);
        assertThat(shift.getTakenSlots()).isEqualTo(1);
    }

    @Test
    void onlyTheChangedFieldsAreNamedAndSpotsAreNoneOfThem() {
        var end = START.plus(Duration.ofHours(8));
        var shift = shift(end, "16.50", 5, Set.of());
        var before = START.minus(Duration.ofDays(1));

        assertThat(update(shift, START, end, "16.50", 5, before)).isEmpty();
        assertThat(update(shift, START, end, "16.50", 8, before)).isEmpty();
        assertThat(update(shift, START, end, "16.5", 8, before)).isEmpty();
        assertThat(update(shift, START, end.plusSeconds(1800), "16.50", 8, before)).containsExactly(Change.TIME);
        assertThat(update(shift, START, end.plusSeconds(1800), "18.00", 8, before)).containsExactly(Change.PAY);
    }

    @Test
    void aPublishedShiftCanBeEditedUntilItStartsAndADraftAnyTime() {
        var end = START.plus(Duration.ofHours(8));
        var draft = shift(end, "16.50", 2, Set.of());
        var published = shift(end, "16.50", 2, Set.of());
        published.publish();

        update(draft, START, end, "18.00", 2, end.plus(Duration.ofDays(1)));
        update(published, START, end, "18.00", 2, START.minusSeconds(1));

        assertThat(draft.getHourlyRate()).isEqualByComparingTo("18.00");
        assertThat(published.getHourlyRate()).isEqualByComparingTo("18.00");
        assertThatExceptionOfType(ShiftNotEditableException.class)
                .isThrownBy(() -> update(published, START, end, "19.00", 2, START));

        var cancelled = shift(end, "16.50", 2, Set.of());
        cancelled.cancel(START.minus(Duration.ofDays(1)));
        assertThatExceptionOfType(ShiftNotEditableException.class)
                .isThrownBy(() -> update(cancelled, START, end, "19.00", 2, START.minus(Duration.ofDays(1))));
    }

    @Test
    void spotsCannotDropBelowTheSpotsTaken() {
        var end = START.plus(Duration.ofHours(8));
        var shift = shift(end, "16.50", 3, Set.of());
        shift.publish();
        var before = START.minus(Duration.ofDays(1));
        shift.claim(before);
        shift.claim(before);

        assertRejected("slots", "below_taken", () -> update(shift, START, end, "16.50", 1, before));
        update(shift, START, end, "16.50", 2, before);

        assertThat(shift.getSlots()).isEqualTo(2);
        assertNotClaimable("shift_full", shift, before);
    }

    @Test
    void anUpdateChecksTheSameTermsAsANewShift() {
        var end = START.plus(Duration.ofHours(8));
        var shift = shift(end, "16.50", 3, Set.of());
        var before = START.minus(Duration.ofDays(1));

        assertRejected("endsAt", "before_start", () -> update(shift, START, START, "16.50", 3, before));
        assertRejected("hourlyRateCents", "out_of_range", () -> update(shift, START, end, "0", 3, before));
        assertRejected("slots", "out_of_range", () -> update(shift, START, end, "16.50", 501, before));
        assertThat(shift.getEndsAt()).isEqualTo(end);
    }

    private static Set<Change> update(
            Shift shift, Instant startsAt, Instant endsAt, String hourlyRate, int slots, Instant now) {
        return shift.update(
                shift.getClientId(), shift.getLocationId(), shift.getTitle(), shift.getDescription(), startsAt,
                endsAt, shift.isEndIsEstimate(), new BigDecimal(hourlyRate), slots, Set.copyOf(shift.getQualificationIds()),
                now);
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
