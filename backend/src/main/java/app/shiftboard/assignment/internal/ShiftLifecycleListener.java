package app.shiftboard.assignment.internal;

import java.time.Instant;

import app.shiftboard.assignment.AssignmentCancelled;
import app.shiftboard.assignment.AssignmentRejected;
import app.shiftboard.assignment.AssignmentShiftChanged;
import app.shiftboard.assignment.WaitlistEntryRemoved;
import app.shiftboard.shift.ShiftCancelled;
import app.shiftboard.shift.ShiftChanged;
import app.shiftboard.shift.ShiftCompleted;
import app.shiftboard.shift.ShiftSpotsAdded;
import app.shiftboard.system.ApiException;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.event.EventListener;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

/**
 * Follows the shift with its claims and its waitlist. Runs inside the transaction that changed
 * the shift, so that a shift is never cancelled or completed while its claims still hold spots,
 * and new spots go to the waitlist with the change.
 */
@Component
class ShiftLifecycleListener {

    private final AssignmentRepository assignments;

    private final Waitlist waitlist;

    private final ApplicationEventPublisher events;

    ShiftLifecycleListener(AssignmentRepository assignments, Waitlist waitlist, ApplicationEventPublisher events) {
        this.assignments = assignments;
        this.waitlist = waitlist;
        this.events = events;
    }

    /**
     * Cancels the claims that hold a spot and clears the waitlist. The workers on the waitlist
     * are told like those who held a spot (ADR 0029).
     */
    @EventListener
    @Transactional(propagation = Propagation.MANDATORY)
    void on(ShiftCancelled cancelled) {
        var now = Instant.now();
        for (var assignment : assignments.findForUpdateByShiftIdAndStatusIn(
                cancelled.shiftId(), AssignmentStatus.HOLDING)) {
            assignment.cancelWithShift(now);
            events.publishEvent(new AssignmentCancelled(
                    cancelled.agencyId(), assignment.getId(), assignment.getShiftId(), assignment.getWorkerId(),
                    AssignmentCancelled.Cause.SHIFT_CANCELLED));
        }
        for (var entry : assignments.findLineForUpdate(cancelled.shiftId(), AssignmentStatus.WAITLISTED)) {
            assignments.delete(entry);
            events.publishEvent(new WaitlistEntryRemoved(
                    cancelled.agencyId(), entry.getId(), entry.getShiftId(), entry.getWorkerId(),
                    WaitlistEntryRemoved.Cause.SHIFT_CANCELLED));
        }
    }

    /**
     * Books every worker who holds a spot for the new time, and tells them (ADR 0026). A new time
     * that overlaps another shift one of them holds rejects the whole change. The waitlist follows
     * the shift without a check: whoever overlaps by then is skipped when they would move up.
     */
    @EventListener
    @Transactional(propagation = Propagation.MANDATORY)
    void on(ShiftChanged changed) {
        var holding = assignments.findForUpdateByShiftIdAndStatusIn(changed.shiftId(), AssignmentStatus.HOLDING);
        if (changed.changes().contains(ShiftChanged.Change.TIME)) {
            for (var assignment : holding) {
                if (assignments.isBookedElsewhere(
                        assignment.getWorkerId(), assignment.getId(), AssignmentStatus.HOLDING, changed.startsAt(),
                        changed.endsAt())) {
                    throw overlap();
                }
                assignment.reschedule(changed.startsAt(), changed.endsAt());
                try {
                    // Written right away: a claim made elsewhere at the same moment fails the exclusion constraint here.
                    assignments.saveAndFlush(assignment);
                } catch (DataIntegrityViolationException e) {
                    throw overlap();
                }
            }
        }
        if (changed.changes().contains(ShiftChanged.Change.TIME)) {
            for (var entry : assignments.findLineForUpdate(changed.shiftId(), AssignmentStatus.WAITLISTED)) {
                entry.reschedule(changed.startsAt(), changed.endsAt());
            }
        }
        for (var assignment : holding) {
            events.publishEvent(new AssignmentShiftChanged(
                    changed.agencyId(), assignment.getId(), assignment.getShiftId(), assignment.getWorkerId(),
                    changed.changeId(), changed.changes()));
        }
    }

    private static ApiException overlap() {
        return new ApiException(
                HttpStatus.CONFLICT, "shift_overlap",
                "At the new time, a worker on this shift would overlap another shift they hold.");
    }

    /** The new spots go to the first in line, like spots that free up (ADR 0029). */
    @EventListener
    @Transactional(propagation = Propagation.MANDATORY)
    void on(ShiftSpotsAdded added) {
        waitlist.fill(added.shiftId());
    }

    /** Completes or turns down the claims that hold a spot, and clears the waitlist without a word (ADR 0029). */
    @EventListener
    @Transactional(propagation = Propagation.MANDATORY)
    void on(ShiftCompleted completed) {
        var now = Instant.now();
        for (var assignment : assignments.findForUpdateByShiftIdAndStatusIn(
                completed.shiftId(), AssignmentStatus.HOLDING)) {
            assignment.completeWithShift(now);
            if (assignment.getStatus() == AssignmentStatus.REJECTED) {
                events.publishEvent(new AssignmentRejected(
                        completed.agencyId(), assignment.getId(), assignment.getShiftId(), assignment.getWorkerId()));
            }
        }
        for (var entry : assignments.findLineForUpdate(completed.shiftId(), AssignmentStatus.WAITLISTED)) {
            assignments.delete(entry);
        }
    }
}
