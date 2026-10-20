package app.shiftboard.shift.internal;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalTime;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

import app.shiftboard.system.InvalidFieldException;
import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.Table;
import org.hibernate.annotations.BatchSize;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcType;
import org.hibernate.annotations.TenantId;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.annotations.UuidGenerator;
import org.hibernate.type.descriptor.jdbc.LocalTimeJdbcType;

/**
 * A shift without a date, shared by the whole agency (ADR 0025). The start is a local time of
 * day; the dashboard places it on the date the dispatcher picks.
 */
@Entity
@Table(name = "shift_template")
class ShiftTemplate {

    /** One minute short of a day: a shift ends before the same time on the next day. */
    static final int MAX_DURATION_MINUTES = 24 * 60 - 1;

    @Id
    @UuidGenerator(style = UuidGenerator.Style.VERSION_7)
    private UUID id;

    @TenantId
    private UUID agencyId;

    private String name;

    private UUID clientId;

    private UUID locationId;

    private String title;

    private String description;

    /**
     * Bound as a plain {@code time}. The default binding converts through the JDBC time zone (UTC),
     * which moves the time by the server's offset.
     */
    @JdbcType(LocalTimeJdbcType.class)
    private LocalTime startTime;

    private int durationMinutes;

    private boolean endIsEstimate;

    /** Gross pay per hour in euros. */
    private BigDecimal hourlyRate;

    private int slots;

    @ElementCollection
    @CollectionTable(name = "shift_template_qualification", joinColumns = @JoinColumn(name = "shift_template_id"))
    @Column(name = "qualification_id")
    @BatchSize(size = 100)
    private Set<UUID> qualificationIds = new HashSet<>();

    @CreationTimestamp
    private Instant createdAt;

    @UpdateTimestamp
    private Instant updatedAt;

    protected ShiftTemplate() {
    }

    ShiftTemplate(
            String name, UUID clientId, UUID locationId, String title, String description, LocalTime startTime,
            int durationMinutes, boolean endIsEstimate, BigDecimal hourlyRate, int slots,
            Set<UUID> qualificationIds) {
        if (durationMinutes < 1 || durationMinutes > MAX_DURATION_MINUTES) {
            throw new InvalidFieldException("durationMinutes", "out_of_range");
        }
        if (hourlyRate.signum() <= 0) {
            throw new InvalidFieldException("hourlyRateCents", "out_of_range");
        }
        if (slots < 1 || slots > Shift.MAX_SLOTS) {
            throw new InvalidFieldException("slots", "out_of_range");
        }
        this.name = name;
        this.clientId = clientId;
        this.locationId = locationId;
        this.title = title;
        this.description = description;
        // Minutes are all a template keeps of the time.
        this.startTime = startTime.withSecond(0).withNano(0);
        this.durationMinutes = durationMinutes;
        this.endIsEstimate = endIsEstimate;
        this.hourlyRate = hourlyRate;
        this.slots = slots;
        this.qualificationIds.addAll(qualificationIds);
    }

    UUID getId() {
        return id;
    }

    String getName() {
        return name;
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

    LocalTime getStartTime() {
        return startTime;
    }

    int getDurationMinutes() {
        return durationMinutes;
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

    Set<UUID> getQualificationIds() {
        return qualificationIds;
    }

    Instant getCreatedAt() {
        return createdAt;
    }
}
