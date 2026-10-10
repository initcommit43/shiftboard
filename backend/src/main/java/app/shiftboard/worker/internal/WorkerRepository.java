package app.shiftboard.worker.internal;

import java.util.Optional;
import java.util.UUID;

import jakarta.persistence.LockModeType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.Repository;

interface WorkerRepository extends Repository<Worker, UUID> {

    Worker save(Worker worker);

    Optional<Worker> findByUserAccountId(UUID userAccountId);

    Page<Worker> findAll(Pageable pageable);

    Page<Worker> findByStatus(WorkerStatus status, Pageable pageable);

    /** Locks the row, so that two concurrent decisions on the same signup run one after the other. */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select w from Worker w where w.id = :id")
    Optional<Worker> findByIdForUpdate(UUID id);
}
