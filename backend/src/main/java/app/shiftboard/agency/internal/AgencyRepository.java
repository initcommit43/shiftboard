package app.shiftboard.agency.internal;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.Repository;

interface AgencyRepository extends Repository<Agency, UUID> {

    Optional<Agency> findById(UUID id);

    Optional<Agency> findBySignupCode(String signupCode);

    @Query("select a.id from Agency a order by a.id")
    List<UUID> findAllIds();
}
