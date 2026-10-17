package app.shiftboard.assignment.internal;

import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

import app.shiftboard.agency.Agencies;
import app.shiftboard.agency.TenantContext;
import app.shiftboard.assignment.AssignmentCancelled;
import app.shiftboard.assignment.internal.WorkerShiftController.AssignmentSummary;
import app.shiftboard.assignment.internal.WorkerShiftController.ClientSummary;
import app.shiftboard.assignment.internal.WorkerShiftController.Contact;
import app.shiftboard.assignment.internal.WorkerShiftController.WorkerShiftPage;
import app.shiftboard.assignment.internal.WorkerShiftController.WorkerShiftResponse;
import app.shiftboard.identity.WorkerProfileProvider;
import app.shiftboard.shift.ShiftDetails;
import app.shiftboard.shift.Shifts;
import app.shiftboard.system.ApiException;
import app.shiftboard.system.ConflictRetry;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.dao.OptimisticLockingFailureException;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

/**
 * The shifts of the agency as one worker sees them: each with the worker's own claim, if any.
 */
@Service
class WorkerShiftService {

    private static final Sort EARLIEST_START_FIRST = Sort.by("startsAt", "id");

    private static final String ACTIVE = "ACTIVE";

    /**
     * How often a claim is tried when concurrent claims on the same shift get in its way. Every
     * attempt reads the shift again, so a shift that filled up in the meantime is reported as full
     * by its own rule and only lasting contention ends here.
     */
    private static final int CLAIM_ATTEMPTS = 3;

    private final AssignmentRepository assignments;

    private final ClaimService claims;

    private final Shifts shifts;

    private final WorkerProfileProvider workerProfiles;

    private final Agencies agencies;

    private final ApplicationEventPublisher events;

    private final TransactionTemplate transactions;

    WorkerShiftService(
            AssignmentRepository assignments, ClaimService claims, Shifts shifts,
            WorkerProfileProvider workerProfiles, Agencies agencies, ApplicationEventPublisher events,
            TransactionTemplate transactions) {
        this.assignments = assignments;
        this.claims = claims;
        this.shifts = shifts;
        this.workerProfiles = workerProfiles;
        this.agencies = agencies;
        this.events = events;
        this.transactions = transactions;
    }

    /** The published shifts that have not started yet. */
    @Transactional(readOnly = true)
    WorkerShiftPage listOpen(UUID accountId, int page, int size) {
        var workerId = activeWorker(accountId);
        var result = shifts.listOpen(page, size);
        var own = assignments
                .findByWorkerIdAndShiftIdIn(workerId, result.getContent().stream().map(ShiftDetails::id).toList())
                .stream()
                .collect(Collectors.toMap(Assignment::getShiftId, Function.identity()));
        var deadline = cancellationDeadline();
        return new WorkerShiftPage(
                result.getContent().stream().map(shift -> response(shift, own.get(shift.id()), deadline)).toList(),
                page, size, result.getTotalElements(), result.getTotalPages());
    }

    @Transactional(readOnly = true)
    WorkerShiftResponse get(UUID accountId, UUID shiftId) {
        var workerId = activeWorker(accountId);
        var shift = shifts.find(shiftId).orElseThrow(WorkerShiftService::shiftNotFound);
        return response(
                shift, assignments.findByShiftIdAndWorkerId(shiftId, workerId).orElse(null), cancellationDeadline());
    }

    /** Every shift the worker has claimed, whatever became of the claim. */
    @Transactional(readOnly = true)
    WorkerShiftPage listClaimed(UUID accountId, int page, int size) {
        var workerId = activeWorker(accountId);
        var result = assignments.findByWorkerId(workerId, PageRequest.of(page, size, EARLIEST_START_FIRST));
        Map<UUID, ShiftDetails> claimed =
                shifts.findAll(result.getContent().stream().map(Assignment::getShiftId).toList());
        var deadline = cancellationDeadline();
        List<WorkerShiftResponse> content = result.getContent().stream()
                .map(assignment -> response(
                        Objects.requireNonNull(claimed.get(assignment.getShiftId())), assignment, deadline))
                .toList();
        return new WorkerShiftPage(content, page, size, result.getTotalElements(), result.getTotalPages());
    }

    /**
     * Claims a spot. Not transactional itself: every attempt is its own transaction, and the
     * shift is read again afterwards with the slot counted.
     */
    WorkerShiftResponse claim(UUID accountId, UUID shiftId) {
        var workerId = activeWorker(accountId);
        for (var attempt = 1; ; attempt++) {
            try {
                claims.claim(shiftId, workerId);
                return get(accountId, shiftId);
            } catch (OptimisticLockingFailureException e) {
                if (attempt == CLAIM_ATTEMPTS) {
                    throw new ApiException(HttpStatus.CONFLICT, "shift_full", "The shift has no free slot left.");
                }
            }
        }
    }

    /**
     * Drops out of a claimed shift before the agency's cancellation deadline. Freeing the spot
     * changes the shift, so the attempt is repeated on a conflict there.
     */
    WorkerShiftResponse cancel(UUID accountId, UUID shiftId) {
        var workerId = activeWorker(accountId);
        ConflictRetry.run(() -> transactions.execute(_ -> {
            if (shifts.find(shiftId).isEmpty()) {
                throw shiftNotFound();
            }
            var assignment = assignments.findForUpdateByShiftIdAndWorkerId(shiftId, workerId)
                    .orElseThrow(() -> new ApiException(
                            HttpStatus.NOT_FOUND, "assignment_not_found", "The worker has not claimed this shift."));
            assignment.cancelByWorker(Instant.now(), cancellationDeadline());
            assignments.saveAndFlush(assignment);
            shifts.release(shiftId);
            events.publishEvent(new AssignmentCancelled(
                    TenantContext.require(), assignment.getId(), shiftId, workerId,
                    AssignmentCancelled.Cause.WORKER));
            return assignment;
        }), ConflictRetry::busy);
        return get(accountId, shiftId);
    }

    private Duration cancellationDeadline() {
        return agencies.settings().cancellationDeadline();
    }

    private static ApiException shiftNotFound() {
        return new ApiException(HttpStatus.NOT_FOUND, "shift_not_found", "The agency has no shift with this id.");
    }

    private UUID activeWorker(UUID accountId) {
        return workerProfiles.findByAccountId(accountId)
                .filter(worker -> ACTIVE.equals(worker.status()))
                .orElseThrow(() -> new ApiException(
                        HttpStatus.FORBIDDEN, "worker_not_active",
                        "Shifts are open to workers the agency has approved."))
                .id();
    }

    private static WorkerShiftResponse response(ShiftDetails shift, Assignment assignment, Duration deadline) {
        return new WorkerShiftResponse(
                shift.id(),
                shift.title(),
                shift.description(),
                shift.status(),
                new ClientSummary(shift.client().id(), shift.client().name()),
                shift.location(),
                shift.startsAt(),
                shift.endsAt(),
                shift.endIsEstimate(),
                shift.hourlyRateCents(),
                shift.slots(),
                shift.takenSlots(),
                shift.qualifications(),
                new Contact(shift.contact().name(), shift.contact().phone()),
                assignment == null
                        ? null
                        : new AssignmentSummary(
                                assignment.getId(),
                                assignment.getStatus(),
                                assignment.getClaimedAt(),
                                assignment.cancellableUntilIfHolding(deadline).orElse(null),
                                assignment.getCancelledBy()));
    }
}
