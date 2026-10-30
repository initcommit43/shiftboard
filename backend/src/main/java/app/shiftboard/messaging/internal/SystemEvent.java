package app.shiftboard.messaging.internal;

/**
 * What a system message reports. Clients word it in their language; the body is a German fallback,
 * which clients also show for events they do not know (ADR 0030).
 */
enum SystemEvent {
    CLAIM_CONFIRMED,
    CLAIM_REJECTED,
    CLAIM_CANCELLED_BY_WORKER,
    REMOVED_BY_AGENCY,
    SHIFT_CANCELLED,
    /** The agency changed the shift (ADR 0026). The body says what changed. */
    SHIFT_CHANGED,
    // The waitlist (ADR 0029).
    /** Moved up from the waitlist into a claim that waits for the agency. */
    WAITLIST_MOVED_UP,
    /** Moved up from the waitlist into a confirmed spot. */
    WAITLIST_MOVED_UP_CONFIRMED,
    /** The agency took the worker off the waitlist. */
    WAITLIST_REMOVED_BY_AGENCY,
    /** First in line, but booked for a shift at the same time by now, so off the waitlist. */
    WAITLIST_SKIPPED
}
