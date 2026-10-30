package app.shiftboard.assignment.internal;

import java.time.Instant;
import java.util.UUID;

import app.shiftboard.agency.Agencies;
import app.shiftboard.agency.TenantContext;
import app.shiftboard.assignment.AssignmentConfirmed;
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
 * or neither. A worker on the waitlist of the shift claims a free spot too, and their place in
 * line becomes the claim (ADR 0029).
 */
@Service
class ClaimService {

    private final AssignmentRepository assignments;

    private final Shifts shifts;

    private final Agencies agencies;

    private final ApplicationEventPublisher events;

    ClaimService(AssignmentRepository assignments, Shifts shifts, Agencies agencies, ApplicationEventPublisher events) {
        this.assignments = assignments;
        this.shifts = shifts;
        this.agencies = agencies;
        this.events = events;
    }

    /**
     * @throws OptimisticLockingFailureException if a concurrent claim on the same shift won; the
     *         attempt can be repeated
     */
    @Transactional
    void claim(UUID shiftId, UUID workerId) {
        // Only the status: the place in line is loaded once it is locked, below.
        var existing = assignments.findStatus(shiftId, workerId);
        if (existing.isPresent() && existing.get() != AssignmentStatus.WAITLISTED) {
            throw alreadyClaimed();
        }
        // The slot first: every change that frees or takes a slot changes the shift before it
        // locks assignments, so that two of them wait for each other instead of deadlocking.
        var shift = shifts.claim(shiftId);
        // Then the worker: a concurrent claim of the same worker on another shift waits here and
        // sees this one in the check below once it is committed.
        assignments.lockBookings(workerId);
        if (assignments.isBooked(workerId, AssignmentStatus.HOLDING, shift.startsAt(), shift.endsAt())) {
            throw overlap();
        }
        var autoConfirm = agencies.settings().autoConfirm();
        var now = Instant.now();
        Assignment assignment;
        try {
            if (existing.isPresent()) {
                var waiting = assignments.findForUpdateByShiftIdAndWorkerId(shiftId, workerId)
                        .filter(Assignment::waiting)
                        .orElseThrow(ClaimService::alreadyClaimed);
                waiting.moveUp(now, autoConfirm);
                assignment = assignments.saveAndFlush(waiting);
            } else {
                assignment = assignments.saveAndFlush(Assignment.claim(
                        shiftId, workerId, shift.startsAt(), shift.endsAt(), now, autoConfirm));
            }
        } catch (DataIntegrityViolationException e) {
            // The constraints back up the checks above, e.g. against a change that books the
            // worker without taking their lock.
            throw byConstraint(e);
        }
        var agencyId = TenantContext.require();
        events.publishEvent(new ShiftClaimed(agencyId, assignment.getId(), shiftId, workerId));
        if (assignment.getStatus() == AssignmentStatus.CONFIRMED) {
            events.publishEvent(new AssignmentConfirmed(agencyId, assignment.getId(), shiftId, workerId));
        }
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

    static ApiException alreadyClaimed() {
        return new ApiException(
                HttpStatus.CONFLICT, "shift_already_claimed", "The worker has already claimed this shift.");
    }

    static ApiException overlap() {
        return new ApiException(
                HttpStatus.CONFLICT, "shift_overlap", "The shift overlaps another shift the worker is booked for.");
    }
}
