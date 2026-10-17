package app.shiftboard.worker;

import java.util.UUID;

/**
 * How the agency reaches a worker.
 */
public record WorkerContact(UUID id, String firstName, String lastName, String phone) {
}
