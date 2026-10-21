package app.shiftboard.shift;

import java.util.UUID;

/**
 * A shift became visible to workers: created as published, or a draft was published.
 */
public record ShiftPublished(UUID agencyId, UUID shiftId) {
}
