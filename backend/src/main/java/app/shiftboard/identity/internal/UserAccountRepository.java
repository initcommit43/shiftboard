package app.shiftboard.identity.internal;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.repository.Repository;

interface UserAccountRepository extends Repository<UserAccount, UUID> {

    UserAccount saveAndFlush(UserAccount account);

    Optional<UserAccount> findById(UUID id);

    List<UserAccount> findAllById(Iterable<UUID> ids);

    Optional<UserAccount> findByEmail(String email);

    boolean existsByEmail(String email);

    List<UserAccount> findByClientIdOrderByLastNameAscFirstNameAsc(UUID clientId);
}
