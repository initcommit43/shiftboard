package app.shiftboard.client.internal;

import static java.util.stream.Collectors.groupingBy;
import static java.util.stream.Collectors.toMap;

import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import app.shiftboard.client.ClientDetails;
import app.shiftboard.client.Clients;
import app.shiftboard.client.LocationDetails;
import app.shiftboard.client.internal.ClientController.ClientPage;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
class ClientService implements Clients {

    private static final Sort BY_NAME = Sort.by("name", "id");

    private final ClientRepository clients;
    private final LocationRepository locations;

    ClientService(ClientRepository clients, LocationRepository locations) {
        this.clients = clients;
        this.locations = locations;
    }

    @Transactional(readOnly = true)
    ClientPage list(int page, int size) {
        var result = clients.findAll(PageRequest.of(page, size, BY_NAME));
        return new ClientPage(
                details(result.getContent()), page, size, result.getTotalElements(), result.getTotalPages());
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<ClientDetails> find(UUID clientId) {
        return Optional.ofNullable(findAll(List.of(clientId)).get(clientId));
    }

    @Override
    @Transactional(readOnly = true)
    public Map<UUID, ClientDetails> findAll(Collection<UUID> clientIds) {
        return details(clients.findByIdIn(clientIds)).stream().collect(toMap(ClientDetails::id, client -> client));
    }

    // The locations of all clients come from one query, whatever the number of clients.
    private List<ClientDetails> details(List<Client> page) {
        var locationsByClient = locations
                .findByClientIdInOrderByNameAscIdAsc(page.stream().map(Client::getId).toList()).stream()
                .collect(groupingBy(Location::getClientId));
        return page.stream()
                .map(client -> new ClientDetails(
                        client.getId(),
                        client.getName(),
                        locationsByClient.getOrDefault(client.getId(), List.of()).stream()
                                .map(location -> new LocationDetails(
                                        location.getId(), location.getName(), location.getAddress()))
                                .toList()))
                .toList();
    }
}
