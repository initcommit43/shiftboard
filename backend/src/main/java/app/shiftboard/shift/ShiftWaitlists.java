package app.shiftboard.shift;

import java.util.Collection;
import java.util.Map;
import java.util.UUID;

/**
 * Supplies how many workers wait for a spot on each shift (ADR 0029). Implemented by the
 * assignment module, so that this module does not depend on it.
 */
public interface ShiftWaitlists {

    /** The number of workers on the waitlist of each of the shifts; shifts nobody waits for are left out. */
    Map<UUID, Integer> waitingCounts(Collection<UUID> shiftIds);
}
