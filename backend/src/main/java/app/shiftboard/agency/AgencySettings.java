package app.shiftboard.agency;

import java.time.Duration;

/**
 * How an agency runs the claim workflow.
 *
 * @param autoConfirm               claims are confirmed right away instead of waiting for the agency
 * @param cancellationDeadlineHours how many hours before the start a worker can still drop out in the app
 */
public record AgencySettings(boolean autoConfirm, int cancellationDeadlineHours) {

    public static final int MAX_CANCELLATION_DEADLINE_HOURS = 336;

    /** Approval required, and workers can drop out until 24 hours before the start. */
    public static final AgencySettings DEFAULTS = new AgencySettings(false, 24);

    public AgencySettings {
        if (cancellationDeadlineHours < 0 || cancellationDeadlineHours > MAX_CANCELLATION_DEADLINE_HOURS) {
            throw new IllegalArgumentException("cancellationDeadlineHours out of range");
        }
    }

    public Duration cancellationDeadline() {
        return Duration.ofHours(cancellationDeadlineHours);
    }
}
