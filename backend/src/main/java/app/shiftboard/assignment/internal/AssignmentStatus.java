package app.shiftboard.assignment.internal;

import java.util.List;

enum AssignmentStatus {
    /**
     * A place on the waitlist of a full shift (ADR 0029). Holds no slot and books no time. The
     * API never shows it as a status: installed apps fail on values they do not know.
     */
    WAITLISTED,
    PENDING,
    CONFIRMED,
    REJECTED,
    CANCELLED,
    COMPLETED,
    NO_SHOW;

    /** The statuses in which an assignment holds a slot of its shift and books the time of its worker. */
    static final List<AssignmentStatus> HOLDING = List.of(PENDING, CONFIRMED);

    /** The statuses of a worker who holds or held a confirmed spot: they check in and get hours. */
    static final List<AssignmentStatus> WORKED = List.of(CONFIRMED, COMPLETED);
}
