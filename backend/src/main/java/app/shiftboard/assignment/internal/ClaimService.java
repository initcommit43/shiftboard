package app.shiftboard.assignment.internal;

import java.time.Instant;
import java.util.UUID;

import app.shiftboard.agency.TenantContext;
import app.shiftboard.assignment.ShiftClaimed;
import app.shiftboard.shift.Shifts;
import app.shiftboard.system.ApiException;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.dao.OptimisticLockingFailureException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * One attempt to claim a spot, in one transaction: the slot is taken and the assignment stored,
 * or neither.
 */
@Service
class ClaimService {

    private final AssignmentRepository assignments;

    private final Shifts shifts;

    private final ApplicationEventPublisher events;

    ClaimService(AssignmentRepository assignments, Shifts shifts, ApplicationEventPublisher events) {
        this.assignments = assignments;
        this.shifts = shifts;
        this.events = events;
    }

    /**
     * @throws OptimisticLockingFailureException if a concurrent claim on the same shift won; the
     *         attempt can be repeated
     */
    @Transactional
    void claim(UUID shiftId, UUID workerId) {
        if (assignments.existsByShiftIdAndWorkerId(shiftId, workerId)) {
            throw alreadyClaimed();
        }
        var shift = shifts.claim(shiftId);
        if (assignments.isBooked(workerId, AssignmentStatus.HOLDING, shift.startsAt(), shift.endsAt())) {
            throw overlap();
        }
        Assignment assignment;
        try {
            assignment = assignments.saveAndFlush(
                    Assignment.claim(shiftId, workerId, shift.startsAt(), shift.endsAt(), Instant.now()));
        } catch (DataIntegrityViolationException e) {
            // A concurrent claim of the same worker was stored between the checks above and this
            // insert; the constraints caught it.
            throw byConstraint(e);
        }
        events.publishEvent(new ShiftClaimed(TenantContext.require(), assignment.getId(), shiftId, workerId));
    }

    private static RuntimeException byConstraint(DataIntegrityViolationException e) {
        var message = String.valueOf(e.getMostSpecificCause().getMessage());
        if (message.contains("assignment_shift_id_worker_id_key")) {
            return alreadyClaimed();
        }
        if (message.contains("assignment_no_overlap")) {
            return overlap();
        }
        return e;
    }

    private static ApiException alreadyClaimed() {
        return new ApiException(
                HttpStatus.CONFLICT, "shift_already_claimed", "The worker has already claimed this shift.");
    }

    private static ApiException overlap() {
        return new ApiException(
                HttpStatus.CONFLICT, "shift_overlap", "The shift overlaps another shift the worker is booked for.");
    }
}
