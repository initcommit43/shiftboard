package app.shiftboard.worker;

import java.util.UUID;

/**
 * The agency rejected a pending signup; the worker is inactive.
 */
public record WorkerRejected(UUID agencyId, UUID workerId) {
}
