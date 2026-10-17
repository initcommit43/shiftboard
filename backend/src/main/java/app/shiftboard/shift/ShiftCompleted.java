package app.shiftboard.shift;

import java.util.UUID;

/**
 * A published shift has ended and counts as having taken place. Published inside the
 * transaction of the completion.
 */
public record ShiftCompleted(UUID agencyId, UUID shiftId) {
}
