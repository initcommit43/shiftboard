package app.shiftboard.assignment.internal;

import java.time.Duration;
import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

import app.shiftboard.shift.ShiftDetails;
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
 * The claim of a worker on a shift and what became of it. A worker claims a shift once.
 *
 * <ul>
 *   <li>{@code PENDING} until the agency approves ({@code CONFIRMED}) or rejects ({@code REJECTED}).
 *   <li>Pending or confirmed, it is {@code CANCELLED} when the worker drops out, the agency
 *       removes them or calls off the shift.
 *   <li>When the shift has taken place, a confirmed claim is {@code COMPLETED} and one nobody
 *       decided on is {@code REJECTED}. A completed one can be marked {@code NO_SHOW}, unless
 *       the worker checked in or has approved hours.
 * </ul>
 *
 * Pending and confirmed assignments hold a slot of their shift; leaving those statuses frees it.
 *
 * <p>A worker can also wait for a spot on a full shift: {@code WAITLISTED}, first come, first
 * served (ADR 0029). The place in line holds no slot. When a spot frees up, the first in line
 * moves up and the place becomes a claim, as if it had been made at that moment. Leaving the
 * waitlist deletes the place, so it leaves no trace.
 *
 * <p>A worker with a confirmed spot checks in and out in the app, and the agency approves the
 * hours they worked (ADR 0028).
 */
@Entity
@Table(name = "assignment")
class Assignment {

    /** How long before the booked start a worker can check in. */
    static final Duration CHECK_IN_EARLY = Duration.ofMinutes(30);

    private static final String PUBLISHED = "PUBLISHED";

    /** The longest stretch of approved hours. */
    private static final Duration LONGEST_WORK = Duration.ofHours(24);

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

    /** When the claim was made; while on the waitlist, when the worker joined it. */
    private Instant claimedAt;

    /** When the claim last changed after it was made: decided on, cancelled or completed. */
    private Instant decidedAt;

    @Enumerated(EnumType.STRING)
    private CancelledBy cancelledBy;

    /** Why the agency removed the worker; for the agency only. */
    private String reason;

    private Instant checkedInAt;

    private Instant checkedOutAt;

    private Instant workedStartedAt;

    private Instant workedEndedAt;

    private Integer breakMinutes;

    private Instant hoursApprovedAt;

    /** The account of the dispatcher or admin who last saved the hours. */
    private UUID hoursApprovedBy;

    @CreationTimestamp
    private Instant createdAt;

    @UpdateTimestamp
    private Instant updatedAt;

    protected Assignment() {
    }

    private Assignment(
            UUID shiftId, UUID workerId, Instant startsAt, Instant endsAt, Instant claimedAt, AssignmentStatus status) {
        this.shiftId = shiftId;
        this.workerId = workerId;
        this.startsAt = startsAt;
        this.endsAt = endsAt;
        this.claimedAt = claimedAt;
        this.status = status;
    }

    /**
     * A new claim. It waits for the agency to decide, unless the agency confirms claims
     * automatically.
     */
    static Assignment claim(
            UUID shiftId, UUID workerId, Instant startsAt, Instant endsAt, Instant now, boolean autoConfirm) {
        var assignment = new Assignment(shiftId, workerId, startsAt, endsAt, now, AssignmentStatus.PENDING);
        if (autoConfirm) {
            assignment.approve(now);
        }
        return assignment;
    }

    /**
     * A place at the back of the waitlist of a shift: only when the agency uses the waitlist, and
     * the shift is published, full and has not started. Whether the worker is on the shift
     * already or booked at the same time is up to the caller, who knows their other assignments.
     */
    static Assignment join(ShiftDetails shift, UUID workerId, boolean waitlistEnabled, Instant now) {
        if (!waitlistEnabled) {
            throw AssignmentConflictException.waitlistDisabled();
        }
        if (!PUBLISHED.equals(shift.status())) {
            throw AssignmentConflictException.shiftNotOpen();
        }
        if (!now.isBefore(shift.startsAt())) {
            throw AssignmentConflictException.shiftStarted();
        }
        if (shift.takenSlots() < shift.slots()) {
            throw AssignmentConflictException.shiftNotFull();
        }
        return new Assignment(
                shift.id(), workerId, shift.startsAt(), shift.endsAt(), now, AssignmentStatus.WAITLISTED);
    }

    /**
     * The place in line becomes a claim, made now: the first in line moves up into a freed spot,
     * or the worker claims a free spot from the waitlist. Like any claim, it waits for the agency
     * to decide, unless the agency confirms claims automatically. The caller takes the slot.
     */
    void moveUp(Instant now, boolean autoConfirm) {
        requireWaiting();
        status = AssignmentStatus.PENDING;
        claimedAt = now;
        if (autoConfirm) {
            approve(now);
        }
    }

    /**
     * The worker leaves the waitlist: possible until the start, also when the agency no longer
     * uses the waitlist. The caller deletes the place, so it leaves no trace.
     */
    void leave(Instant now) {
        requireWaiting();
        if (!now.isBefore(startsAt)) {
            throw AssignmentConflictException.shiftStarted();
        }
    }

    /** Whether this is a place on the waitlist rather than a claim. */
    boolean waiting() {
        return status == AssignmentStatus.WAITLISTED;
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

    /**
     * The shift moved: the worker keeps the spot, or the place in line, and is booked for the new
     * time (ADR 0026).
     */
    void reschedule(Instant startsAt, Instant endsAt) {
        if (!holdsSlot() && !waiting()) {
            throw AssignmentConflictException.notActive();
        }
        this.startsAt = startsAt;
        this.endsAt = endsAt;
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
        if (checkedInAt != null || hoursApprovedAt != null) {
            throw AssignmentConflictException.workerAttended();
        }
        status = AssignmentStatus.NO_SHOW;
        decidedAt = now;
    }

    /** The worker arrived: once, with a confirmed spot, from shortly before the start until the end. */
    void checkIn(Instant now) {
        if (checkedInAt != null) {
            throw AssignmentConflictException.alreadyCheckedIn();
        }
        if (status != AssignmentStatus.CONFIRMED) {
            throw AssignmentConflictException.notConfirmed();
        }
        if (now.isBefore(checkInFrom()) || !now.isBefore(endsAt)) {
            throw AssignmentConflictException.checkInNotOpen();
        }
        checkedInAt = now;
    }

    /**
     * The worker left: once after checking in, also after the planned end, until the agency
     * approved the hours.
     */
    void checkOut(Instant now) {
        if (!worked()) {
            throw AssignmentConflictException.notConfirmed();
        }
        if (checkedInAt == null) {
            throw AssignmentConflictException.notCheckedIn();
        }
        if (checkedOutAt != null) {
            throw AssignmentConflictException.alreadyCheckedOut();
        }
        if (hoursApprovedAt != null) {
            throw AssignmentConflictException.hoursApproved();
        }
        checkedOutAt = now;
    }

    /**
     * The agency approves the hours of a worker who held a confirmed spot, once the shift has
     * started. Saving again replaces them.
     */
    void approveHours(Instant startedAt, Instant endedAt, int breakMinutes, UUID approvedBy, Instant now) {
        if (!worked()) {
            throw AssignmentConflictException.notWorked();
        }
        if (now.isBefore(startsAt)) {
            throw AssignmentConflictException.shiftNotStarted();
        }
        if (!endedAt.isAfter(startedAt)) {
            throw new InvalidFieldException("endedAt", "before_start");
        }
        var length = Duration.between(startedAt, endedAt);
        if (length.compareTo(LONGEST_WORK) > 0) {
            throw new InvalidFieldException("endedAt", "too_long");
        }
        if (breakMinutes < 0) {
            throw new InvalidFieldException("breakMinutes", "out_of_range");
        }
        if (Duration.ofMinutes(breakMinutes).compareTo(length) >= 0) {
            throw new InvalidFieldException("breakMinutes", "too_long");
        }
        workedStartedAt = startedAt;
        workedEndedAt = endedAt;
        this.breakMinutes = breakMinutes;
        hoursApprovedBy = approvedBy;
        hoursApprovedAt = now;
    }

    /** Whether the worker holds or held a confirmed spot: they check in and out and get hours. */
    boolean worked() {
        return AssignmentStatus.WORKED.contains(status);
    }

    /** From when the worker can check in; possible until the booked end. */
    Instant checkInFrom() {
        return startsAt.minus(CHECK_IN_EARLY);
    }

    /** The approved hours; empty until the agency approved them. */
    Optional<WorkedHours> hours() {
        return hoursApprovedAt == null
                ? Optional.empty()
                : Optional.of(new WorkedHours(workedStartedAt, workedEndedAt, breakMinutes, hoursApprovedAt));
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

    private void requireWaiting() {
        if (!waiting()) {
            throw new IllegalStateException("Assignment " + id + " is not on the waitlist");
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

    Instant getCheckedInAt() {
        return checkedInAt;
    }

    Instant getCheckedOutAt() {
        return checkedOutAt;
    }
}
