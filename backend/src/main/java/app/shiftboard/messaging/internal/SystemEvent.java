package app.shiftboard.messaging.internal;

/**
 * What a system message reports. Clients word it in their language; the body is a German fallback.
 */
enum SystemEvent {
    CLAIM_CONFIRMED,
    CLAIM_REJECTED,
    CLAIM_CANCELLED_BY_WORKER,
    REMOVED_BY_AGENCY,
    SHIFT_CANCELLED,
    /**
     * The agency changed the shift (ADR 0026). The body says what changed; the API leaves the
     * event out until clients accept event values they do not know.
     */
    SHIFT_CHANGED,
    // The waitlist (ADR 0029); not in the API yet either.
    /** Moved up from the waitlist into a claim that waits for the agency. */
    WAITLIST_MOVED_UP,
    /** Moved up from the waitlist into a confirmed spot. */
    WAITLIST_MOVED_UP_CONFIRMED,
    /** The agency took the worker off the waitlist. */
    WAITLIST_REMOVED_BY_AGENCY,
    /** First in line, but booked for a shift at the same time by now, so off the waitlist. */
    WAITLIST_SKIPPED;

    /**
     * Whether the API shows the event. Installed apps reject event values they do not know, so a
     * new one stays out until clients accept unknown values; its body says what happened.
     */
    boolean inApi() {
        return switch (this) {
            case CLAIM_CONFIRMED, CLAIM_REJECTED, CLAIM_CANCELLED_BY_WORKER, REMOVED_BY_AGENCY, SHIFT_CANCELLED -> true;
            case SHIFT_CHANGED, WAITLIST_MOVED_UP, WAITLIST_MOVED_UP_CONFIRMED, WAITLIST_REMOVED_BY_AGENCY,
                    WAITLIST_SKIPPED -> false;
        };
    }
}
