package app.shiftboard.client.internal;

import java.util.Collection;
import java.util.List;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.repository.Repository;

interface ClientRepository extends Repository<Client, UUID> {

    Page<Client> findAll(Pageable pageable);

    List<Client> findByIdIn(Collection<UUID> ids);
}
