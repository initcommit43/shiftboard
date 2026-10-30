package app.shiftboard.staffrequest.internal;

import java.time.Instant;
import java.util.UUID;

import app.shiftboard.system.InvalidFieldException;
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
 * A client's request for staff (ADR 0032). It stays {@code OPEN} until a dispatcher turns it into
 * a shift or declines it, or the client withdraws it; after that it no longer changes.
 */
@Entity
@Table(name = "staff_request")
class StaffRequest {

    static final int MAX_WORKERS = 500;

    @Id
    @UuidGenerator(style = UuidGenerator.Style.VERSION_7)
    private UUID id;

    @TenantId
    private UUID agencyId;

    private UUID clientId;

    private UUID locationId;

    /** The client user who sent it. */
    private UUID requestedBy;

    private String role;

    private Instant startsAt;

    private Instant endsAt;

    private boolean endIsEstimate;

    private int workerCount;

    private String notes;

    @Enumerated(EnumType.STRING)
    private StaffRequestStatus status = StaffRequestStatus.OPEN;

    private String declineReason;

    private UUID shiftId;

    private Instant decidedAt;

    @CreationTimestamp
    private Instant createdAt;

    @UpdateTimestamp
    private Instant updatedAt;

    protected StaffRequest() {
    }

    /**
     * @throws InvalidFieldException {@code in_past} on {@code startsAt}, {@code before_start} on
     *         {@code endsAt} or {@code out_of_range} on {@code workerCount}
     */
    StaffRequest(
            UUID clientId, UUID locationId, UUID requestedBy, String role, Instant startsAt, Instant endsAt,
            boolean endIsEstimate, int workerCount, String notes, Instant now) {
        if (startsAt.isBefore(now)) {
            throw new InvalidFieldException("startsAt", "in_past");
        }
        if (!endsAt.isAfter(startsAt)) {
            throw new InvalidFieldException("endsAt", "before_start");
        }
        if (workerCount < 1 || workerCount > MAX_WORKERS) {
            throw new InvalidFieldException("workerCount", "out_of_range");
        }
        this.clientId = clientId;
        this.locationId = locationId;
        this.requestedBy = requestedBy;
        this.role = role;
        this.startsAt = startsAt;
        this.endsAt = endsAt;
        this.endIsEstimate = endIsEstimate;
        this.workerCount = workerCount;
        this.notes = notes;
    }

    /** The client takes the request back. */
    void withdraw(Instant now) {
        close(StaffRequestStatus.WITHDRAWN, now);
    }

    /** A dispatcher turned the request into this shift. */
    void accept(UUID shiftId, Instant now) {
        close(StaffRequestStatus.ACCEPTED, now);
        this.shiftId = shiftId;
    }

    /** A dispatcher declined the request; the client sees the reason. */
    void decline(String reason, Instant now) {
        close(StaffRequestStatus.DECLINED, now);
        this.declineReason = reason;
    }

    private void close(StaffRequestStatus outcome, Instant now) {
        if (status != StaffRequestStatus.OPEN) {
            throw new StaffRequestNotOpenException();
        }
        status = outcome;
        decidedAt = now;
    }

    UUID getId() {
        return id;
    }

    UUID getClientId() {
        return clientId;
    }

    UUID getLocationId() {
        return locationId;
    }

    UUID getRequestedBy() {
        return requestedBy;
    }

    String getRole() {
        return role;
    }

    Instant getStartsAt() {
        return startsAt;
    }

    Instant getEndsAt() {
        return endsAt;
    }

    boolean isEndIsEstimate() {
        return endIsEstimate;
    }

    int getWorkerCount() {
        return workerCount;
    }

    String getNotes() {
        return notes;
    }

    StaffRequestStatus getStatus() {
        return status;
    }

    String getDeclineReason() {
        return declineReason;
    }

    UUID getShiftId() {
        return shiftId;
    }

    Instant getDecidedAt() {
        return decidedAt;
    }

    Instant getCreatedAt() {
        return createdAt;
    }
}
