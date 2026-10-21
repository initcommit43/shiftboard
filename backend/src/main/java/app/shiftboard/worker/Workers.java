package app.shiftboard.worker;

import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * The workers of the current agency, as other modules need them.
 */
public interface Workers {

    /** Name and phone of the given workers, by worker id; unknown ids are left out. */
    Map<UUID, WorkerContact> contacts(Collection<UUID> workerIds);

    /** The active workers who have not paused notifications about new shifts. */
    List<UUID> reachableForNewShifts();
}
