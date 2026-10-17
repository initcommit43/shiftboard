package app.shiftboard.shift;

import java.util.UUID;

/**
 * The agency called off a shift. Published inside the transaction of the cancellation, so that
 * whatever depends on the shift is cancelled with it or not at all.
 */
public record ShiftCancelled(UUID agencyId, UUID shiftId) {
}
