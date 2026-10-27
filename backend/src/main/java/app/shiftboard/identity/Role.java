package app.shiftboard.identity;

public enum Role {
    ADMIN,
    DISPATCHER,
    WORKER,
    /** Someone at one of the agency's clients, in the client portal (ADR 0032). */
    CLIENT
}
