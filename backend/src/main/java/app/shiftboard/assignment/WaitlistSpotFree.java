package app.shiftboard.assignment;

import java.util.List;
import java.util.UUID;

/**
 * A spot of a shift with a waitlist freed up after the cancellation deadline (ADR 0029). Nobody
 * moves up then; everyone waiting may claim it, and the first claim wins.
 *
 * @param workerIds the workers on the waitlist, in line order; never empty
 */
public record WaitlistSpotFree(UUID agencyId, UUID shiftId, List<UUID> workerIds) {

    public WaitlistSpotFree {
        workerIds = List.copyOf(workerIds);
    }
}
