package app.shiftboard.assignment;

import java.util.UUID;

/**
 * A pending or confirmed claim was cancelled and its spot freed.
 */
public record AssignmentCancelled(UUID agencyId, UUID assignmentId, UUID shiftId, UUID workerId, Cause cause) {

    public enum Cause {
        /** The worker dropped out. */
        WORKER,
        /** The agency removed the worker from the shift. */
        REMOVED,
        /** The agency called off the whole shift. */
        SHIFT_CANCELLED
    }
}
