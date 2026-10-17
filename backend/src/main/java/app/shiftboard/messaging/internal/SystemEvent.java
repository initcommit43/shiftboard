package app.shiftboard.messaging.internal;

/**
 * What a system message reports. Clients word it in their language; the body is a German fallback.
 */
enum SystemEvent {
    CLAIM_CONFIRMED,
    CLAIM_REJECTED,
    CLAIM_CANCELLED_BY_WORKER,
    REMOVED_BY_AGENCY,
    SHIFT_CANCELLED
}
