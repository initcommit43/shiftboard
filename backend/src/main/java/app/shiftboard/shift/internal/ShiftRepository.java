package app.shiftboard.shift.internal;

import java.time.Instant;
import java.util.Collection;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.repository.Repository;

interface ShiftRepository extends Repository<Shift, UUID> {

    /** Writes the shift right away, so that the values the database sets on insert are there to return. */
    Shift saveAndFlush(Shift shift);

    Optional<Shift> findById(UUID id);

    Page<Shift> findByStatusInAndEndsAtAfter(Collection<ShiftStatus> statuses, Instant time, Pageable pageable);
}
