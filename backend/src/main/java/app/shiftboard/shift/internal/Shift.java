package app.shiftboard.shift.internal;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

import app.shiftboard.system.InvalidFieldException;
import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.Table;
import jakarta.persistence.Version;
import org.hibernate.annotations.BatchSize;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.TenantId;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.annotations.UuidGenerator;

/**
 * Work for one role at a client's location: several roles at one event are several shifts.
 * Starts as a draft; workers see it once it is published.
 */
@Entity
@Table(name = "shift")
class Shift {

    static final int MAX_SLOTS = 500;

    @Id
    @UuidGenerator(style = UuidGenerator.Style.VERSION_7)
    private UUID id;

    @TenantId
    private UUID agencyId;

    private UUID clientId;

    private UUID locationId;

    /** The dispatcher workers turn to with questions about this shift. */
    private UUID contactUserId;

    private String title;

    private String description;

    private Instant startsAt;

    private Instant endsAt;

    private boolean endIsEstimate;

    /** Gross pay per hour in euros. */
    private BigDecimal hourlyRate;

    private int slots;

    private int takenSlots;

    @Enumerated(EnumType.STRING)
    private ShiftStatus status;

    // Loaded for a whole page of shifts at once instead of one query per shift.
    @ElementCollection
    @CollectionTable(name = "shift_qualification", joinColumns = @JoinColumn(name = "shift_id"))
    @Column(name = "qualification_id")
    @BatchSize(size = 100)
    private Set<UUID> qualificationIds = new HashSet<>();

    /** Lets only one of two concurrent changes win, which is what keeps a shift from being overbooked. */
    @Version
    private long version;

    @CreationTimestamp
    private Instant createdAt;

    @UpdateTimestamp
    private Instant updatedAt;

    protected Shift() {
    }

    Shift(
            UUID clientId, UUID locationId, UUID contactUserId, String title, String description, Instant startsAt,
            Instant endsAt, boolean endIsEstimate, BigDecimal hourlyRate, int slots, Set<UUID> qualificationIds) {
        if (!endsAt.isAfter(startsAt)) {
            throw new InvalidFieldException("endsAt", "before_start");
        }
        if (hourlyRate.signum() <= 0) {
            throw new InvalidFieldException("hourlyRateCents", "out_of_range");
        }
        if (slots < 1 || slots > MAX_SLOTS) {
            throw new InvalidFieldException("slots", "out_of_range");
        }
        this.clientId = clientId;
        this.locationId = locationId;
        this.contactUserId = contactUserId;
        this.title = title;
        this.description = description;
        this.startsAt = startsAt;
        this.endsAt = endsAt;
        this.endIsEstimate = endIsEstimate;
        this.hourlyRate = hourlyRate;
        this.slots = slots;
        this.qualificationIds.addAll(qualificationIds);
        this.status = ShiftStatus.DRAFT;
    }

    void publish() {
        if (status != ShiftStatus.DRAFT) {
            throw new ShiftNotDraftException();
        }
        status = ShiftStatus.PUBLISHED;
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

    String getTitle() {
        return title;
    }

    String getDescription() {
        return description;
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

    BigDecimal getHourlyRate() {
        return hourlyRate;
    }

    int getSlots() {
        return slots;
    }

    int getTakenSlots() {
        return takenSlots;
    }

    ShiftStatus getStatus() {
        return status;
    }

    Set<UUID> getQualificationIds() {
        return qualificationIds;
    }

    Instant getCreatedAt() {
        return createdAt;
    }
}
