package app.shiftboard.assignment.internal;

import java.util.List;

enum AssignmentStatus {
    PENDING,
    CONFIRMED,
    REJECTED,
    CANCELLED,
    COMPLETED,
    NO_SHOW;

    /** The statuses in which an assignment holds a slot of its shift and books the time of its worker. */
    static final List<AssignmentStatus> HOLDING = List.of(PENDING, CONFIRMED);
}
