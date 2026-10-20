package app.shiftboard.assignment.internal;

import java.time.Instant;

import app.shiftboard.assignment.AssignmentCancelled;
import app.shiftboard.assignment.AssignmentRejected;
import app.shiftboard.assignment.AssignmentShiftChanged;
import app.shiftboard.shift.ShiftCancelled;
import app.shiftboard.shift.ShiftChanged;
import app.shiftboard.shift.ShiftCompleted;
import app.shiftboard.system.ApiException;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.event.EventListener;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

/**
 * Follows the shift with its claims. Runs inside the transaction that changed the shift, so that
 * a shift is never cancelled or completed while its claims still hold spots.
 */
@Component
class ShiftLifecycleListener {

    private final AssignmentRepository assignments;

    private final ApplicationEventPublisher events;

    ShiftLifecycleListener(AssignmentRepository assignments, ApplicationEventPublisher events) {
        this.assignments = assignments;
        this.events = events;
    }

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
    }

    /**
     * Books every worker who holds a spot for the new time, and tells them (ADR 0026). A new time
     * that overlaps another shift one of them holds rejects the whole change.
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
    }
}
