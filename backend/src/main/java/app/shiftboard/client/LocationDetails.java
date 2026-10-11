package app.shiftboard.client;

import java.util.UUID;

/**
 * @param address the postal address in one line
 */
public record LocationDetails(UUID id, String name, String address) {
}
