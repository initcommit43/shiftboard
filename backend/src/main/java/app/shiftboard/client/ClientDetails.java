package app.shiftboard.client;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * @param locations the client's locations, sorted by name
 */
public record ClientDetails(UUID id, String name, List<LocationDetails> locations) {

    public Optional<LocationDetails> location(UUID locationId) {
        return locations.stream().filter(location -> location.id().equals(locationId)).findFirst();
    }
}
