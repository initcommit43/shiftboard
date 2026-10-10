package app.shiftboard.worker;

import java.util.UUID;

/**
 * The agency approved a pending signup; the worker is active.
 */
public record WorkerApproved(UUID agencyId, UUID workerId) {
}
