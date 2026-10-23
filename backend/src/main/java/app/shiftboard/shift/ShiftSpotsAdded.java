package app.shiftboard.shift;

import java.util.UUID;

/**
 * The agency raised the number of spots of a published shift (ADR 0026). Published inside the
 * transaction of the change, so that the new spots go to the shift's waitlist with it (ADR 0029).
 */
public record ShiftSpotsAdded(UUID agencyId, UUID shiftId) {
}
