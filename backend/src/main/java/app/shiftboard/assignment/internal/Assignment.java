package app.shiftboard.assignment.internal;

import java.time.Duration;
import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.TenantId;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.annotations.UuidGenerator;

/**
 * The claim of a worker on a shift and what became of it. A worker claims a shift once.
 *
 * <ul>
 *   <li>{@code PENDING} until the agency approves ({@code CONFIRMED}) or rejects ({@code REJECTED}).
 *   <li>Pending or confirmed, it is {@code CANCELLED} when the worker drops out, the agency
 *       removes them or calls off the shift.
 *   <li>When the shift has taken place, a confirmed claim is {@code COMPLETED} and one nobody
 *       decided on is {@code REJECTED}. A completed one can be marked {@code NO_SHOW}.
 * </ul>
 *
 * Pending and confirmed assignments hold a slot of their shift; leaving those statuses frees it.
 */
@Entity
@Table(name = "assignment")
class Assignment {

    @Id
    @UuidGenerator(style = UuidGenerator.Style.VERSION_7)
    private UUID id;

    @TenantId
    private UUID agencyId;

    private UUID shiftId;

    private UUID workerId;

    @Enumerated(EnumType.STRING)
    private AssignmentStatus status;

    // The time the worker is booked for, copied from the shift: overlaps are checked and the
    // worker's shifts are sorted without asking the shift module. Whatever moves a shift later
    // has to move its assignments with it.
    private Instant startsAt;

    private Instant endsAt;

    private Instant claimedAt;

    /** When the claim last changed after it was made: decided on, cancelled or completed. */
    private Instant decidedAt;

    @Enumerated(EnumType.STRING)
    private CancelledBy cancelledBy;

    /** Why the agency removed the worker; for the agency only. */
    private String reason;

    @CreationTimestamp
    private Instant createdAt;

    @UpdateTimestamp
    private Instant updatedAt;

    protected Assignment() {
    }

    private Assignment(UUID shiftId, UUID workerId, Instant startsAt, Instant endsAt, Instant claimedAt) {
        this.shiftId = shiftId;
        this.workerId = workerId;
        this.startsAt = startsAt;
        this.endsAt = endsAt;
        this.claimedAt = claimedAt;
        this.status = AssignmentStatus.PENDING;
    }

    /**
     * A new claim. It waits for the agency to decide, unless the agency confirms claims
     * automatically.
     */
    static Assignment claim(
            UUID shiftId, UUID workerId, Instant startsAt, Instant endsAt, Instant now, boolean autoConfirm) {
        var assignment = new Assignment(shiftId, workerId, startsAt, endsAt, now);
        if (autoConfirm) {
            assignment.approve(now);
        }
        return assignment;
    }

    void approve(Instant now) {
        requirePending();
        status = AssignmentStatus.CONFIRMED;
        decidedAt = now;
    }

    void reject(Instant now) {
        requirePending();
        status = AssignmentStatus.REJECTED;
        decidedAt = now;
    }

    /**
     * The worker drops out. Possible until the cancellation deadline before the start; afterwards
     * they have to talk to the agency.
     */
    void cancelByWorker(Instant now, Duration deadline) {
        requireHoldsSlot();
        if (!now.isBefore(cancellableUntil(deadline))) {
            throw AssignmentConflictException.deadlinePassed();
        }
        cancel(CancelledBy.WORKER, null, now);
    }

    /** The agency takes the worker off the shift, for a reason it keeps to itself. */
    void remove(String reason, Instant now) {
        requireHoldsSlot();
        cancel(CancelledBy.AGENCY, reason, now);
    }

    /** The agency called off the whole shift. */
    void cancelWithShift(Instant now) {
        requireHoldsSlot();
        cancel(CancelledBy.AGENCY, null, now);
    }

    /**
     * The shift took place: a confirmed worker worked it, a claim nobody decided on is turned
     * down.
     */
    void completeWithShift(Instant now) {
        requireHoldsSlot();
        status = status == AssignmentStatus.CONFIRMED ? AssignmentStatus.COMPLETED : AssignmentStatus.REJECTED;
        decidedAt = now;
    }

    /** The worker did not turn up for a shift that took place. */
    void markNoShow(Instant now) {
        if (status != AssignmentStatus.COMPLETED) {
            throw AssignmentConflictException.notCompleted();
        }
        status = AssignmentStatus.NO_SHOW;
        decidedAt = now;
    }

    boolean holdsSlot() {
        return AssignmentStatus.HOLDING.contains(status);
    }

    /** Until when the worker can drop out in the app; empty once the claim holds no slot. */
    Optional<Instant> cancellableUntilIfHolding(Duration deadline) {
        return holdsSlot() ? Optional.of(cancellableUntil(deadline)) : Optional.empty();
    }

    private Instant cancellableUntil(Duration deadline) {
        return startsAt.minus(deadline);
    }

    private void cancel(CancelledBy by, String reason, Instant now) {
        status = AssignmentStatus.CANCELLED;
        cancelledBy = by;
        this.reason = reason;
        decidedAt = now;
    }

    private void requirePending() {
        if (status != AssignmentStatus.PENDING) {
            throw AssignmentConflictException.notPending();
        }
    }

    private void requireHoldsSlot() {
        if (!holdsSlot()) {
            throw AssignmentConflictException.notActive();
        }
    }

    UUID getId() {
        return id;
    }

    UUID getShiftId() {
        return shiftId;
    }

    UUID getWorkerId() {
        return workerId;
    }

    AssignmentStatus getStatus() {
        return status;
    }

    Instant getStartsAt() {
        return startsAt;
    }

    Instant getEndsAt() {
        return endsAt;
    }

    Instant getClaimedAt() {
        return claimedAt;
    }

    Instant getDecidedAt() {
        return decidedAt;
    }

    CancelledBy getCancelledBy() {
        return cancelledBy;
    }

    String getReason() {
        return reason;
    }
}
