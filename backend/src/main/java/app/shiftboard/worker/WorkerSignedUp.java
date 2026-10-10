package app.shiftboard.worker;

import java.util.UUID;

/**
 * A worker signed up through the agency's signup link and waits for approval.
 */
public record WorkerSignedUp(UUID agencyId, UUID workerId) {
}
