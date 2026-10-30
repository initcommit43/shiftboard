package app.shiftboard.staffrequest.internal;

import java.util.Optional;
import java.util.UUID;

import jakarta.persistence.LockModeType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.repository.Repository;

interface StaffRequestRepository extends Repository<StaffRequest, UUID> {

    StaffRequest save(StaffRequest request);

    Optional<StaffRequest> findById(UUID id);

    /**
     * Locks the request until the transaction ends, so that a withdrawal and a dispatcher's
     * decision at the same moment don't both win.
     */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    Optional<StaffRequest> findForUpdateById(UUID id);

    Page<StaffRequest> findByClientId(UUID clientId, Pageable pageable);
}
