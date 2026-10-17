package app.shiftboard.assignment;

import java.util.UUID;

/**
 * A pending claim was turned down: by the agency, or because the shift ended before anyone decided.
 */
public record AssignmentRejected(UUID agencyId, UUID assignmentId, UUID shiftId, UUID workerId) {
}
