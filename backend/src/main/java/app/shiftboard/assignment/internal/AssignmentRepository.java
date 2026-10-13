package app.shiftboard.assignment.internal;

import java.time.Instant;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.Repository;

interface AssignmentRepository extends Repository<Assignment, UUID> {

    /** Writes the claim right away, so that a constraint it breaks is reported inside the claim. */
    Assignment saveAndFlush(Assignment assignment);

    boolean existsByShiftIdAndWorkerId(UUID shiftId, UUID workerId);

    Optional<Assignment> findByShiftIdAndWorkerId(UUID shiftId, UUID workerId);

    List<Assignment> findByWorkerIdAndShiftIdIn(UUID workerId, Collection<UUID> shiftIds);

    Page<Assignment> findByWorkerId(UUID workerId, Pageable pageable);

    /** Whether the worker is booked, in one of the given statuses, for any time between start and end. */
    @Query("""
            select count(a) > 0 from Assignment a
            where a.workerId = :workerId and a.status in :statuses
              and a.startsAt < :endsAt and a.endsAt > :startsAt
            """)
    boolean isBooked(UUID workerId, Collection<AssignmentStatus> statuses, Instant startsAt, Instant endsAt);
}
