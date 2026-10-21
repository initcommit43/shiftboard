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
    SHIFT_CHANGED
}
