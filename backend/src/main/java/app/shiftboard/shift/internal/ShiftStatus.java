package app.shiftboard.shift.internal;

/**
 * Only what cannot be derived is stored: whether a published shift is open or full follows from
 * its slots, whether it is in progress from the time.
 */
enum ShiftStatus {
    DRAFT,
    PUBLISHED,
    COMPLETED,
    CANCELLED
}
