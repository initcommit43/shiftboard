package app.shiftboard.client.internal;

import java.util.Collection;
import java.util.List;
import java.util.UUID;

import org.springframework.data.repository.Repository;

interface LocationRepository extends Repository<Location, UUID> {

    List<Location> findByClientIdInOrderByNameAscIdAsc(Collection<UUID> clientIds);
}
