package app.shiftboard.identity.internal;

import app.shiftboard.identity.Role;

/**
 * The client a login comes from. Workers use the app, dispatchers and admins the dashboard.
 */
enum ClientType {
    WORKER_APP,
    DASHBOARD;

    boolean admits(Role role) {
        return switch (this) {
            case WORKER_APP -> role == Role.WORKER;
            case DASHBOARD -> role == Role.DISPATCHER || role == Role.ADMIN || role == Role.CLIENT;
        };
    }
}
