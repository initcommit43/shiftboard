package app.shiftboard.worker.internal;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import java.time.LocalDate;

import jakarta.validation.Constraint;
import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import jakarta.validation.Payload;

/**
 * A date of birth a living person can have: in the past and at most {@value #MAX_AGE_YEARS} years ago.
 * There is no minimum age.
 */
@Target(ElementType.FIELD)
@Retention(RetentionPolicy.RUNTIME)
@Constraint(validatedBy = DateOfBirth.Validator.class)
@interface DateOfBirth {

    int MAX_AGE_YEARS = 120;

    String message() default "must be a date of birth in the past";

    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};

    class Validator implements ConstraintValidator<DateOfBirth, LocalDate> {

        static boolean isPlausible(LocalDate dateOfBirth, LocalDate today) {
            return dateOfBirth.isBefore(today) && !dateOfBirth.isBefore(today.minusYears(MAX_AGE_YEARS));
        }

        @Override
        public boolean isValid(LocalDate value, ConstraintValidatorContext context) {
            return value == null || isPlausible(value, LocalDate.now(context.getClockProvider().getClock()));
        }
    }
}
