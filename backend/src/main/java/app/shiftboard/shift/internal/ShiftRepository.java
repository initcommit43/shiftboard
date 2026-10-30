package app.shiftboard.shift.internal;

import java.time.Instant;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import jakarta.persistence.LockModeType;
import org.springframework.data.domain.Limit;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.repository.Repository;

interface ShiftRepository extends Repository<Shift, UUID> {

    /** Writes the shift right away, so that the values the database sets on insert are there to return. */
    Shift saveAndFlush(Shift shift);

    Optional<Shift> findById(UUID id);

    /** The shift, with a shared row lock ({@code for share}) held until the transaction ends. */
    @Lock(LockModeType.PESSIMISTIC_READ)
    Optional<Shift> findAndLockById(UUID id);

    boolean existsById(UUID id);

    List<Shift> findAllById(Iterable<UUID> ids);

    Page<Shift> findByStatusInAndEndsAtAfter(Collection<ShiftStatus> statuses, Instant time, Pageable pageable);

    Page<Shift> findByStatusInAndEndsAtLessThanEqual(
            Collection<ShiftStatus> statuses, Instant time, Pageable pageable);

    Page<Shift> findByStatusAndStartsAtAfter(ShiftStatus status, Instant time, Pageable pageable);

    /** The ids of the shifts in this status that ended by the given time, the earliest end first. */
    List<ShiftIdOnly> findByStatusAndEndsAtLessThanEqualOrderByEndsAt(ShiftStatus status, Instant time, Limit limit);

    interface ShiftIdOnly {

        UUID getId();
    }
}
