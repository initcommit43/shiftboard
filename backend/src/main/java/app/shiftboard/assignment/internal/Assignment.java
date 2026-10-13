package app.shiftboard.assignment.internal;

import java.time.Instant;
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

    private Instant decidedAt;

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

    /** A new claim. It waits for the agency to decide. */
    static Assignment claim(UUID shiftId, UUID workerId, Instant startsAt, Instant endsAt, Instant now) {
        return new Assignment(shiftId, workerId, startsAt, endsAt, now);
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
}
