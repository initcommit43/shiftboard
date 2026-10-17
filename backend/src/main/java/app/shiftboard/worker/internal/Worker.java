package app.shiftboard.worker.internal;

import java.time.Instant;
import java.time.LocalDate;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.Table;
import org.hibernate.annotations.BatchSize;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.TenantId;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.annotations.UuidGenerator;

/**
 * A person in an agency's pool. Signs up as pending; the agency then approves or rejects.
 */
@Entity
@Table(name = "worker")
class Worker {

    @Id
    @UuidGenerator(style = UuidGenerator.Style.VERSION_7)
    private UUID id;

    @TenantId
    private UUID agencyId;

    private UUID userAccountId;

    private String firstName;

    private String lastName;

    private LocalDate dateOfBirth;

    private String phone;

    @Enumerated(EnumType.STRING)
    private WorkerStatus status;

    // Loaded for a whole page of workers at once instead of one query per worker.
    @ElementCollection
    @CollectionTable(name = "worker_qualification", joinColumns = @JoinColumn(name = "worker_id"))
    @Column(name = "qualification_id")
    @BatchSize(size = 100)
    private Set<UUID> qualificationIds = new HashSet<>();

    @CreationTimestamp
    private Instant createdAt;

    /** No push for new shifts while true; decisions and messages still reach the worker. */
    private boolean notificationsPaused;

    @UpdateTimestamp
    private Instant updatedAt;

    protected Worker() {
    }

    Worker(UUID userAccountId, String firstName, String lastName, LocalDate dateOfBirth, String phone) {
        this.userAccountId = userAccountId;
        this.firstName = firstName;
        this.lastName = lastName;
        this.dateOfBirth = dateOfBirth;
        this.phone = phone;
        this.status = WorkerStatus.PENDING;
    }

    void approve() {
        decide(WorkerStatus.ACTIVE);
    }

    void reject() {
        decide(WorkerStatus.INACTIVE);
    }

    private void decide(WorkerStatus decision) {
        if (status != WorkerStatus.PENDING) {
            throw new WorkerNotPendingException();
        }
        status = decision;
    }

    void pauseNewShiftNotifications(boolean paused) {
        notificationsPaused = paused;
    }

    boolean isNotificationsPaused() {
        return notificationsPaused;
    }

    UUID getId() {
        return id;
    }

    UUID getUserAccountId() {
        return userAccountId;
    }

    String getFirstName() {
        return firstName;
    }

    String getLastName() {
        return lastName;
    }

    LocalDate getDateOfBirth() {
        return dateOfBirth;
    }

    String getPhone() {
        return phone;
    }

    WorkerStatus getStatus() {
        return status;
    }

    Set<UUID> getQualificationIds() {
        return qualificationIds;
    }

    Instant getCreatedAt() {
        return createdAt;
    }
}
