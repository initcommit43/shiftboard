package app.shiftboard.assignment;

import java.util.UUID;

/**
 * A worker claimed a spot on a shift; the claim waits for the agency to decide.
 */
public record ShiftClaimed(UUID agencyId, UUID assignmentId, UUID shiftId, UUID workerId) {
}
