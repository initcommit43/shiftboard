package app.shiftboard.shift.internal;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.EnumSet;
import java.util.HashSet;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;

import app.shiftboard.shift.ShiftChanged.Change;
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
        checkTerms(startsAt, endsAt, hourlyRate, slots);
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

    /**
     * Replaces every field of a draft, or of a published shift that has not started (ADR 0026).
     * Status, spots taken and contact stay. Spots cannot drop below the spots taken.
     *
     * @return what changed that matters to a worker who holds a spot; empty if nothing did
     */
    Set<Change> update(
            UUID clientId, UUID locationId, String title, String description, Instant startsAt, Instant endsAt,
            boolean endIsEstimate, BigDecimal hourlyRate, int slots, Set<UUID> qualificationIds, Instant now) {
        var editable = status == ShiftStatus.DRAFT || (status == ShiftStatus.PUBLISHED && now.isBefore(this.startsAt));
        if (!editable) {
            throw new ShiftNotEditableException();
        }
        checkTerms(startsAt, endsAt, hourlyRate, slots);
        if (slots < takenSlots) {
            throw new InvalidFieldException("slots", "below_taken");
        }

        var changes = EnumSet.noneOf(Change.class);
        if (!startsAt.equals(this.startsAt) || !endsAt.equals(this.endsAt) || endIsEstimate != this.endIsEstimate) {
            changes.add(Change.TIME);
        }
        if (!clientId.equals(this.clientId)) {
            changes.add(Change.CLIENT);
        }
        if (!locationId.equals(this.locationId)) {
            changes.add(Change.LOCATION);
        }
        if (!title.equals(this.title)) {
            changes.add(Change.TITLE);
        }
        if (!Objects.equals(description, this.description)) {
            changes.add(Change.DESCRIPTION);
        }
        if (hourlyRate.compareTo(this.hourlyRate) != 0) {
            changes.add(Change.PAY);
        }
        if (!qualificationIds.equals(this.qualificationIds)) {
            changes.add(Change.QUALIFICATIONS);
        }

        this.clientId = clientId;
        this.locationId = locationId;
        this.title = title;
        this.description = description;
        this.startsAt = startsAt;
        this.endsAt = endsAt;
        this.endIsEstimate = endIsEstimate;
        this.hourlyRate = hourlyRate;
        this.slots = slots;
        this.qualificationIds.clear();
        this.qualificationIds.addAll(qualificationIds);
        return changes;
    }

    private static void checkTerms(Instant startsAt, Instant endsAt, BigDecimal hourlyRate, int slots) {
        if (!endsAt.isAfter(startsAt)) {
            throw new InvalidFieldException("endsAt", "before_start");
        }
        if (hourlyRate.signum() <= 0) {
            throw new InvalidFieldException("hourlyRateCents", "out_of_range");
        }
        if (slots < 1 || slots > MAX_SLOTS) {
            throw new InvalidFieldException("slots", "out_of_range");
        }
    }

    void publish() {
        if (status != ShiftStatus.DRAFT) {
            throw new ShiftNotDraftException();
        }
        status = ShiftStatus.PUBLISHED;
    }

    /**
     * Takes one slot for a claim. Only a published shift that has not started and has a free slot
     * can be claimed.
     */
    void claim(Instant now) {
        if (status != ShiftStatus.PUBLISHED) {
            throw ShiftNotClaimableException.notOpen();
        }
        if (!now.isBefore(startsAt)) {
            throw ShiftNotClaimableException.started();
        }
        if (takenSlots >= slots) {
            throw ShiftNotClaimableException.full();
        }
        takenSlots++;
    }

    /**
     * Frees the slot of a claim that no longer holds one. Only a published shift offers its
     * slots; a cancelled or completed one keeps its count.
     */
    void release() {
        if (status != ShiftStatus.PUBLISHED) {
            return;
        }
        if (takenSlots == 0) {
            throw new IllegalStateException("No slot of shift " + id + " is taken");
        }
        takenSlots--;
    }

    /**
     * Calls the shift off. A draft or published shift can be cancelled until it ends, also while
     * it runs; its claims are cancelled with it, so no slot stays taken.
     */
    void cancel(Instant now) {
        if ((status != ShiftStatus.DRAFT && status != ShiftStatus.PUBLISHED) || !now.isBefore(endsAt)) {
            throw new ShiftNotCancellableException();
        }
        status = ShiftStatus.CANCELLED;
        takenSlots = 0;
    }

    /** A published shift that has ended took place. */
    void complete(Instant now) {
        if (status != ShiftStatus.PUBLISHED || now.isBefore(endsAt)) {
            throw new IllegalStateException("Shift " + id + " cannot be completed");
        }
        status = ShiftStatus.COMPLETED;
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

    UUID getContactUserId() {
        return contactUserId;
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
