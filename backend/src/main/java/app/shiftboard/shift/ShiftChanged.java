package app.shiftboard.shift;

import java.time.Instant;
import java.util.Set;
import java.util.UUID;

/**
 * The agency changed a published shift in a way that matters to the workers who hold a spot on
 * it (ADR 0026). Published inside the transaction of the change, so that the booked time of each
 * claim follows the shift, or the change fails.
 *
 * @param changeId tells one change from the next, so that its notices are delivered once
 * @param changes  what changed; never empty
 * @param startsAt the start after the change
 * @param endsAt   the end after the change
 */
public record ShiftChanged(
        UUID agencyId, UUID shiftId, UUID changeId, Set<Change> changes, Instant startsAt, Instant endsAt) {

    public ShiftChanged {
        changes = Set.copyOf(changes);
    }

    /** What a worker on the shift sees changed. The number of spots is not part of it. */
    public enum Change {
        /** Start, end or whether the end is an estimate. */
        TIME,
        CLIENT,
        LOCATION,
        TITLE,
        DESCRIPTION,
        /** The hourly rate. */
        PAY,
        QUALIFICATIONS
    }
}
