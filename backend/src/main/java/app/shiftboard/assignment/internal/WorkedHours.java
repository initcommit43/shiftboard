package app.shiftboard.assignment.internal;

import java.time.Duration;
import java.time.Instant;

/**
 * The hours a worker worked on a shift, as the agency approved them (ADR 0028).
 *
 * @param breakMinutes unpaid break
 * @param approvedAt   when the hours were last saved
 */
record WorkedHours(Instant startedAt, Instant endedAt, int breakMinutes, Instant approvedAt) {

    /** End minus start minus break, in whole minutes; not rounded. */
    int workedMinutes() {
        return (int) Duration.between(startedAt, endedAt).toMinutes() - breakMinutes;
    }

    /** Worked minutes times the hourly rate, in euro cents, rounded half up. */
    long grossCents(int hourlyRateCents) {
        return ((long) workedMinutes() * hourlyRateCents + 30) / 60;
    }
}
