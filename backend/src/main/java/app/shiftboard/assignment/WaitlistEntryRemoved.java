package app.shiftboard.assignment;

import java.util.UUID;

/**
 * A worker was taken off the waitlist of a shift without having asked for it (ADR 0029). A worker
 * who leaves on their own, or whose shift ended, leaves no event.
 *
 * @param entryId the place in line, gone now
 */
public record WaitlistEntryRemoved(UUID agencyId, UUID entryId, UUID shiftId, UUID workerId, Cause cause) {

    public enum Cause {
        /** The agency took the worker off the waitlist. */
        REMOVED,
        /** The worker was first in line, but is booked for a shift at the same time by now. */
        OVERLAP,
        /** The agency called off the whole shift. */
        SHIFT_CANCELLED
    }
}
