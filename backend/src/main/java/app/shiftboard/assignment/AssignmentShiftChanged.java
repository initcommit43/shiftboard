package app.shiftboard.assignment;

import java.util.Set;
import java.util.UUID;

import app.shiftboard.shift.ShiftChanged;

/**
 * The agency changed the shift of a pending or confirmed claim (ADR 0026). The claim keeps its
 * spot; its booked time already follows the shift.
 *
 * @param changeId the change of the shift, the same for every claim on it
 * @param changes  what changed; never empty
 */
public record AssignmentShiftChanged(
        UUID agencyId, UUID assignmentId, UUID shiftId, UUID workerId, UUID changeId,
        Set<ShiftChanged.Change> changes) {

    public AssignmentShiftChanged {
        changes = Set.copyOf(changes);
    }
}
