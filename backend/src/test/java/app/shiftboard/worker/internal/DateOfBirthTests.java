package app.shiftboard.worker.internal;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.LocalDate;

import org.junit.jupiter.api.Test;

class DateOfBirthTests {

    static final LocalDate TODAY = LocalDate.of(2026, 10, 10);

    @Test
    void anyDayInThePastIsPlausible() {
        assertThat(DateOfBirth.Validator.isPlausible(LocalDate.of(1996, 3, 14), TODAY)).isTrue();
        assertThat(DateOfBirth.Validator.isPlausible(TODAY.minusDays(1), TODAY)).isTrue();
    }

    @Test
    void todayAndTheFutureAreNotPlausible() {
        assertThat(DateOfBirth.Validator.isPlausible(TODAY, TODAY)).isFalse();
        assertThat(DateOfBirth.Validator.isPlausible(TODAY.plusDays(1), TODAY)).isFalse();
    }

    @Test
    void moreThan120YearsAgoIsNotPlausible() {
        assertThat(DateOfBirth.Validator.isPlausible(LocalDate.of(1906, 10, 10), TODAY)).isTrue();
        assertThat(DateOfBirth.Validator.isPlausible(LocalDate.of(1906, 10, 9), TODAY)).isFalse();
    }
}
