package app.shiftboard.identity;

import java.util.UUID;

public record WorkerProfile(UUID id, String firstName, String lastName, String status) {
}
