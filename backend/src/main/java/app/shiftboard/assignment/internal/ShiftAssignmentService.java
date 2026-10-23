package app.shiftboard.assignment.internal;

import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.function.Function;

import app.shiftboard.agency.TenantContext;
import app.shiftboard.assignment.AssignmentCancelled;
import app.shiftboard.assignment.AssignmentConfirmed;
import app.shiftboard.assignment.AssignmentRejected;
import app.shiftboard.assignment.internal.ShiftAssignmentController.AssignedWorker;
import app.shiftboard.assignment.internal.ShiftAssignmentController.HoursResponse;
import app.shiftboard.assignment.internal.ShiftAssignmentController.ShiftAssignmentPage;
import app.shiftboard.assignment.internal.ShiftAssignmentController.ShiftAssignmentResponse;
import app.shiftboard.shift.ShiftDetails;
import app.shiftboard.shift.Shifts;
import app.shiftboard.system.ApiException;
import app.shiftboard.system.ConflictRetry;
import app.shiftboard.system.InvalidFieldException;
import app.shiftboard.worker.Workers;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

/**
 * The agency's side of the claims on a shift: who claimed it, and the decisions on them.
 */
@Service
class ShiftAssignmentService {

    private static final Sort OLDEST_CLAIM_FIRST = Sort.by("claimedAt", "id");

    private final AssignmentRepository assignments;

    private final Shifts shifts;

    private final Waitlist waitlist;

    private final Workers workers;

    private final ApplicationEventPublisher events;

    private final TransactionTemplate transactions;

    ShiftAssignmentService(
            AssignmentRepository assignments, Shifts shifts, Waitlist waitlist, Workers workers,
            ApplicationEventPublisher events, TransactionTemplate transactions) {
        this.assignments = assignments;
        this.shifts = shifts;
        this.waitlist = waitlist;
        this.workers = workers;
        this.events = events;
        this.transactions = transactions;
    }

    /** The claims only: the waitlist is not part of them, and its status is not one of the API's (ADR 0029). */
    @Transactional(readOnly = true)
    ShiftAssignmentPage list(UUID shiftId, AssignmentStatus status, int page, int size) {
        if (status == AssignmentStatus.WAITLISTED) {
            throw new InvalidFieldException("status", "invalid_format");
        }
        requireShift(shiftId);
        var pageable = PageRequest.of(page, size, OLDEST_CLAIM_FIRST);
        var result = status == null
                ? assignments.findByShiftIdAndStatusNot(shiftId, AssignmentStatus.WAITLISTED, pageable)
                : assignments.findByShiftIdAndStatus(shiftId, status, pageable);
        return new ShiftAssignmentPage(
                responses(shiftId, result.getContent()), page, size, result.getTotalElements(),
                result.getTotalPages());
    }

    ShiftAssignmentResponse approve(UUID shiftId, UUID assignmentId) {
        return change(shiftId, assignmentId, assignment -> {
            assignment.approve(Instant.now());
            events.publishEvent(new AssignmentConfirmed(
                    TenantContext.require(), assignment.getId(), shiftId, assignment.getWorkerId()));
            return assignment;
        });
    }

    /**
     * Rejecting frees the spot, for the first in line on the waitlist (ADR 0029). It changes the
     * shift too, so it is repeated on a conflict there.
     */
    ShiftAssignmentResponse reject(UUID shiftId, UUID assignmentId) {
        return ConflictRetry.run(() -> change(shiftId, assignmentId, assignment -> {
            assignment.reject(Instant.now());
            shifts.release(shiftId);
            events.publishEvent(new AssignmentRejected(
                    TenantContext.require(), assignment.getId(), shiftId, assignment.getWorkerId()));
            waitlist.fill(shiftId);
            return assignment;
        }), ConflictRetry::busy);
    }

    /**
     * Removing frees the spot, for the first in line on the waitlist (ADR 0029). It changes the
     * shift too, so it is repeated on a conflict there.
     */
    ShiftAssignmentResponse remove(UUID shiftId, UUID assignmentId, String reason) {
        return ConflictRetry.run(() -> change(shiftId, assignmentId, assignment -> {
            assignment.remove(reason, Instant.now());
            shifts.release(shiftId);
            events.publishEvent(new AssignmentCancelled(
                    TenantContext.require(), assignment.getId(), shiftId, assignment.getWorkerId(),
                    AssignmentCancelled.Cause.REMOVED));
            waitlist.fill(shiftId);
            return assignment;
        }), ConflictRetry::busy);
    }

    /** Saves and approves the hours a worker worked; saving again replaces them (ADR 0028). */
    ShiftAssignmentResponse approveHours(
            UUID shiftId, UUID assignmentId, Instant startedAt, Instant endedAt, int breakMinutes, UUID approvedBy) {
        return change(shiftId, assignmentId, assignment -> {
            assignment.approveHours(startedAt, endedAt, breakMinutes, approvedBy, Instant.now());
            return assignment;
        });
    }

    ShiftAssignmentResponse markNoShow(UUID shiftId, UUID assignmentId) {
        return change(shiftId, assignmentId, assignment -> {
            assignment.markNoShow(Instant.now());
            return assignment;
        });
    }

    /** Applies the change to the locked claim in a transaction of its own; a place on the waitlist is no claim. */
    private ShiftAssignmentResponse change(
            UUID shiftId, UUID assignmentId, Function<Assignment, Assignment> change) {
        return transactions.execute(_ -> {
            requireShift(shiftId);
            var assignment = assignments.findForUpdate(assignmentId, shiftId)
                    .filter(found -> !found.waiting())
                    .orElseThrow(() -> new ApiException(
                            HttpStatus.NOT_FOUND, "assignment_not_found", "The shift has no claim with this id."));
            return responses(shiftId, List.of(assignments.saveAndFlush(change.apply(assignment)))).getFirst();
        });
    }

    private void requireShift(UUID shiftId) {
        if (!shifts.exists(shiftId)) {
            throw new ApiException(HttpStatus.NOT_FOUND, "shift_not_found", "The agency has no shift with this id.");
        }
    }

    // Names and phones come from the worker module in one call, whatever the number of claims.
    // The hourly rate for the gross pay is only looked up when someone has approved hours.
    private List<ShiftAssignmentResponse> responses(UUID shiftId, List<Assignment> page) {
        var contacts = workers.contacts(page.stream().map(Assignment::getWorkerId).distinct().toList());
        var hourlyRateCents = page.stream().anyMatch(assignment -> assignment.hours().isPresent())
                ? shifts.find(shiftId).map(ShiftDetails::hourlyRateCents).orElse(0)
                : 0;
        return page.stream()
                .map(assignment -> {
                    var worker = contacts.get(assignment.getWorkerId());
                    return new ShiftAssignmentResponse(
                            assignment.getId(),
                            assignment.getStatus(),
                            new AssignedWorker(worker.id(), worker.firstName(), worker.lastName(), worker.phone()),
                            assignment.getClaimedAt(),
                            assignment.getDecidedAt(),
                            assignment.getCancelledBy(),
                            assignment.getReason(),
                            assignment.getCheckedInAt(),
                            assignment.getCheckedOutAt(),
                            assignment.hours().map(hours -> HoursResponse.of(hours, hourlyRateCents)).orElse(null));
                })
                .toList();
    }
}
