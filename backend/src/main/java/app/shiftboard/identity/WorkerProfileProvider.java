package app.shiftboard.identity;

import java.util.Optional;
import java.util.UUID;

/**
 * Supplies the worker profile shown with the current user. Implemented by the worker module,
 * so that this module does not depend on it.
 */
public interface WorkerProfileProvider {

    Optional<WorkerProfile> findByAccountId(UUID accountId);
}
