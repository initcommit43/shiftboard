package app.shiftboard.assignment;

import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * The claims of the current agency, as other modules need them.
 */
public interface Assignments {

    /** The workers whose claim on the shift is confirmed. */
    List<UUID> confirmedWorkers(UUID shiftId);

    /** How many workers are confirmed per shift; shifts without any are left out. */
    Map<UUID, Integer> confirmedCounts(Collection<UUID> shiftIds);
}
