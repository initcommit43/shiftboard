package app.shiftboard.assignment;

import java.util.UUID;

/**
 * The first in line of a shift's waitlist moved up into a freed spot (ADR 0029): their place
 * became a claim, made at that moment. Stands in for the confirmation when the agency confirms
 * claims automatically, so that the worker is told once.
 *
 * @param confirmed the claim was confirmed right away; otherwise it waits for the agency
 */
public record WaitlistMovedUp(UUID agencyId, UUID assignmentId, UUID shiftId, UUID workerId, boolean confirmed) {
}
