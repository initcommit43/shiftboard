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

    /** Only for places on the waitlist: a claim is never deleted. */
    void delete(Assignment assignment);

    Optional<Assignment> findByShiftIdAndWorkerId(UUID shiftId, UUID workerId);

    @Query("select a.status from Assignment a where a.shiftId = :shiftId and a.workerId = :workerId")
    Optional<AssignmentStatus> findStatus(UUID shiftId, UUID workerId);

    List<Assignment> findByWorkerIdAndShiftIdIn(UUID workerId, Collection<UUID> shiftIds);

    Page<Assignment> findByWorkerId(UUID workerId, Pageable pageable);

    Page<Assignment> findByWorkerIdAndStatusNot(UUID workerId, AssignmentStatus status, Pageable pageable);

    Page<Assignment> findByShiftIdAndStatusNot(UUID shiftId, AssignmentStatus status, Pageable pageable);

    Page<Assignment> findByShiftId(UUID shiftId, Pageable pageable);

    Page<Assignment> findByShiftIdAndStatus(UUID shiftId, AssignmentStatus status, Pageable pageable);

    @Query("select a.workerId from Assignment a where a.shiftId = :shiftId and a.status = :status order by a.claimedAt")
    List<UUID> findWorkerIdsByShiftIdAndStatus(UUID shiftId, AssignmentStatus status);

    /** The waitlist of the shift in line order: who joined first, then by id for the same moment. */
    @Query("""
            select a.id from Assignment a where a.shiftId = :shiftId and a.status = :status
            order by a.claimedAt, a.id
            """)
    List<UUID> findIdsInLine(UUID shiftId, AssignmentStatus status);

    @Query("""
            select a.shiftId as shiftId, count(a) as waiting from Assignment a
            where a.shiftId in :shiftIds and a.status = :status
            group by a.shiftId
            """)
    List<WaitingPerShift> countWaiting(Collection<UUID> shiftIds, AssignmentStatus status);

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

    /** The waitlist of the shift in line order, like {@link #findIdsInLine}. */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select a from Assignment a where a.shiftId = :shiftId and a.status = :status order by a.claimedAt, a.id")
    List<Assignment> findLineForUpdate(UUID shiftId, AssignmentStatus status);

    // The hours of a period: the claims of workers with a confirmed spot on shifts that have
    // started, by booked start (ADR 0028).

    @Query("""
            select a from Assignment a
            where a.status in :statuses and a.startsAt >= :from and a.startsAt < :to and a.startsAt <= :now
            """)
    Page<Assignment> findWorked(
            Collection<AssignmentStatus> statuses, Instant from, Instant to, Instant now, Pageable pageable);

    @Query("""
            select a from Assignment a
            where a.status in :statuses and a.startsAt >= :from and a.startsAt < :to and a.startsAt <= :now
              and a.hoursApprovedAt is null
            """)
    Page<Assignment> findWorkedWithoutHours(
            Collection<AssignmentStatus> statuses, Instant from, Instant to, Instant now, Pageable pageable);

    @Query("""
            select a from Assignment a
            where a.status in :statuses and a.startsAt >= :from and a.startsAt < :to and a.startsAt <= :now
              and a.hoursApprovedAt is not null
            """)
    Page<Assignment> findWorkedWithHours(
            Collection<AssignmentStatus> statuses, Instant from, Instant to, Instant now, Pageable pageable);

    /** Whether the worker is booked, in one of the given statuses, for any time between start and end. */
    @Query("""
            select count(a) > 0 from Assignment a
            where a.workerId = :workerId and a.status in :statuses
              and a.startsAt < :endsAt and a.endsAt > :startsAt
            """)
    boolean isBooked(UUID workerId, Collection<AssignmentStatus> statuses, Instant startsAt, Instant endsAt);

    /** Like {@link #isBooked}, leaving out one claim of the worker. */
    @Query("""
            select count(a) > 0 from Assignment a
            where a.workerId = :workerId and a.id <> :except and a.status in :statuses
              and a.startsAt < :endsAt and a.endsAt > :startsAt
            """)
    boolean isBookedElsewhere(
            UUID workerId, UUID except, Collection<AssignmentStatus> statuses, Instant startsAt, Instant endsAt);

    interface WaitingPerShift {

        UUID getShiftId();

        long getWaiting();
    }
}
