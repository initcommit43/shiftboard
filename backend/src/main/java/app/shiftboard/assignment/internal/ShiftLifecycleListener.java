package app.shiftboard.assignment.internal;

import java.time.Instant;

import app.shiftboard.assignment.AssignmentCancelled;
import app.shiftboard.assignment.AssignmentRejected;
import app.shiftboard.shift.ShiftCancelled;
import app.shiftboard.shift.ShiftCompleted;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.event.EventListener;
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
