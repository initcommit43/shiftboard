package app.shiftboard.identity.internal;

/** Staff and workers are always {@code ACTIVE}; client users go through all three. */
enum AccountStatus {
    INVITED,
    ACTIVE,
    DEACTIVATED
}
