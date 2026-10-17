package app.shiftboard.assignment.internal;

import java.time.Instant;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import jakarta.persistence.LockModeType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.Repository;

interface AssignmentRepository extends Repository<Assignment, UUID> {

    /** Writes the claim right away, so that a constraint it breaks is reported inside the claim. */
    Assignment saveAndFlush(Assignment assignment);

    boolean existsByShiftIdAndWorkerId(UUID shiftId, UUID workerId);

    Optional<Assignment> findByShiftIdAndWorkerId(UUID shiftId, UUID workerId);

    List<Assignment> findByWorkerIdAndShiftIdIn(UUID workerId, Collection<UUID> shiftIds);

    Page<Assignment> findByWorkerId(UUID workerId, Pageable pageable);

    Page<Assignment> findByShiftId(UUID shiftId, Pageable pageable);

    Page<Assignment> findByShiftIdAndStatus(UUID shiftId, AssignmentStatus status, Pageable pageable);

    @Query("select a.workerId from Assignment a where a.shiftId = :shiftId and a.status = :status order by a.claimedAt")
    List<UUID> findWorkerIdsByShiftIdAndStatus(UUID shiftId, AssignmentStatus status);

    // The finders below lock the rows they return, so that two concurrent changes of one claim,
    // such as an approval and a rejection, run one after the other and the second sees the first.

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select a from Assignment a where a.id = :id and a.shiftId = :shiftId")
    Optional<Assignment> findForUpdate(UUID id, UUID shiftId);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select a from Assignment a where a.shiftId = :shiftId and a.workerId = :workerId")
    Optional<Assignment> findForUpdateByShiftIdAndWorkerId(UUID shiftId, UUID workerId);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select a from Assignment a where a.shiftId = :shiftId and a.status in :statuses order by a.id")
    List<Assignment> findForUpdateByShiftIdAndStatusIn(UUID shiftId, Collection<AssignmentStatus> statuses);

    /** Whether the worker is booked, in one of the given statuses, for any time between start and end. */
    @Query("""
            select count(a) > 0 from Assignment a
            where a.workerId = :workerId and a.status in :statuses
              and a.startsAt < :endsAt and a.endsAt > :startsAt
            """)
    boolean isBooked(UUID workerId, Collection<AssignmentStatus> statuses, Instant startsAt, Instant endsAt);
}
