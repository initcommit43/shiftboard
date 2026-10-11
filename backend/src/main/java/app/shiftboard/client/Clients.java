package app.shiftboard.client;

import java.util.Collection;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

public interface Clients {

    /** The client with its locations, if the current agency has one with this id. */
    Optional<ClientDetails> find(UUID clientId);

    /** The clients with these ids by id, each with its locations; unknown ids are left out. */
    Map<UUID, ClientDetails> findAll(Collection<UUID> clientIds);
}
