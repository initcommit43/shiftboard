package app.shiftboard.assignment;

import java.util.UUID;

/**
 * A claim was confirmed: by the agency, or right away because the agency confirms claims automatically.
 */
public record AssignmentConfirmed(UUID agencyId, UUID assignmentId, UUID shiftId, UUID workerId) {
}
