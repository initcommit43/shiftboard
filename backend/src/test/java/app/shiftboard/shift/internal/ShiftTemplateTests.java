package app.shiftboard.shift.internal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatExceptionOfType;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.Set;
import java.util.UUID;

import app.shiftboard.system.InvalidFieldException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

class ShiftTemplateTests {

    @Test
    void keepsEverythingButTheDate() {
        var qualification = UUID.randomUUID();

        var template = template(LocalTime.of(22, 0), 8 * 60, "16.50", 5, Set.of(qualification));

        assertThat(template.getName()).isEqualTo("Lager Nachtschicht");
        assertThat(template.getStartTime()).isEqualTo(LocalTime.of(22, 0));
        assertThat(template.getDurationMinutes()).isEqualTo(480);
        assertThat(template.getHourlyRate()).isEqualByComparingTo("16.50");
        assertThat(template.getSlots()).isEqualTo(5);
        assertThat(template.getQualificationIds()).containsExactly(qualification);
    }

    @Test
    void keepsTheStartToTheMinute() {
        var template = template(LocalTime.of(7, 0, 42, 5), 60, "16.50", 1, Set.of());

        assertThat(template.getStartTime()).isEqualTo(LocalTime.of(7, 0));
    }

    @ParameterizedTest
    @ValueSource(ints = {0, -1, 24 * 60})
    void aShiftRunsBetweenOneMinuteAndJustUnderADay(int durationMinutes) {
        assertRejected(
                "durationMinutes", "out_of_range",
                () -> template(LocalTime.of(7, 0), durationMinutes, "16.50", 1, Set.of()));
    }

    @Test
    void aShiftCanRunUntilAMinuteBeforeTheSameTimeNextDay() {
        var template = template(LocalTime.of(7, 0), 24 * 60 - 1, "16.50", 1, Set.of());

        assertThat(template.getDurationMinutes()).isEqualTo(1439);
    }

    @ParameterizedTest
    @ValueSource(strings = {"0", "-1"})
    void theHourlyRateHasToBePositive(String hourlyRate) {
        assertRejected(
                "hourlyRateCents", "out_of_range", () -> template(LocalTime.of(7, 0), 60, hourlyRate, 1, Set.of()));
    }

    @ParameterizedTest
    @ValueSource(ints = {0, 501})
    void aTemplateNeedsBetweenOneAndFiveHundredSlots(int slots) {
        assertRejected("slots", "out_of_range", () -> template(LocalTime.of(7, 0), 60, "16.50", slots, Set.of()));
    }

    private static ShiftTemplate template(
            LocalTime startTime, int durationMinutes, String hourlyRate, int slots, Set<UUID> qualificationIds) {
        return new ShiftTemplate(
                "Lager Nachtschicht", UUID.randomUUID(), UUID.randomUUID(), "Lagerunterstützung", null, startTime,
                durationMinutes, false, new BigDecimal(hourlyRate), slots, qualificationIds);
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
