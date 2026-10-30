package app.shiftboard.assignment.internal;

import java.time.Duration;
import java.time.Instant;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.function.Consumer;
import java.util.function.Function;
import java.util.stream.Collectors;

import app.shiftboard.agency.Agencies;
import app.shiftboard.agency.TenantContext;
import app.shiftboard.assignment.AssignmentCancelled;
import app.shiftboard.assignment.internal.WorkerShiftController.AssignmentSummary;
import app.shiftboard.assignment.internal.WorkerShiftController.ClientSummary;
import app.shiftboard.assignment.internal.WorkerShiftController.Contact;
import app.shiftboard.assignment.internal.WorkerShiftController.WaitlistPlace;
import app.shiftboard.assignment.internal.WorkerShiftController.WorkerShiftPage;
import app.shiftboard.assignment.internal.WorkerShiftController.WorkerShiftResponse;
import app.shiftboard.identity.WorkerProfileProvider;
import app.shiftboard.shift.ShiftDetails;
import app.shiftboard.shift.Shifts;
import app.shiftboard.system.ApiException;
import app.shiftboard.system.ConflictRetry;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.dao.OptimisticLockingFailureException;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

/**
 * The shifts of the agency as one worker sees them: each with the worker's own claim, or their
 * place on its waitlist, if any.
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

    private final Waitlist waitlist;

    private final Shifts shifts;

    private final WorkerProfileProvider workerProfiles;

    private final Agencies agencies;

    private final ApplicationEventPublisher events;

    private final TransactionTemplate transactions;

    WorkerShiftService(
            AssignmentRepository assignments, ClaimService claims, Waitlist waitlist, Shifts shifts,
            WorkerProfileProvider workerProfiles, Agencies agencies, ApplicationEventPublisher events,
            TransactionTemplate transactions) {
        this.assignments = assignments;
        this.claims = claims;
        this.waitlist = waitlist;
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
        var terms = terms();
        var positions = positions(own.values());
        return new WorkerShiftPage(
                result.getContent().stream()
                        .map(shift -> response(shift, own.get(shift.id()), positions, terms))
                        .toList(),
                page, size, result.getTotalElements(), result.getTotalPages());
    }

    @Transactional(readOnly = true)
    WorkerShiftResponse get(UUID accountId, UUID shiftId) {
        var workerId = activeWorker(accountId);
        var shift = shifts.find(shiftId).orElseThrow(WorkerShiftService::shiftNotFound);
        var own = assignments.findByShiftIdAndWorkerId(shiftId, workerId);
        return response(shift, own.orElse(null), positions(own.stream().toList()), terms());
    }

    /**
     * Every shift the worker has claimed, whatever became of the claim, and with
     * {@code includeWaitlist} the shifts they are waiting for.
     */
    @Transactional(readOnly = true)
    WorkerShiftPage listClaimed(UUID accountId, boolean includeWaitlist, int page, int size) {
        var workerId = activeWorker(accountId);
        var pageable = PageRequest.of(page, size, EARLIEST_START_FIRST);
        var result = includeWaitlist
                ? assignments.findByWorkerId(workerId, pageable)
                : assignments.findByWorkerIdAndStatusNot(workerId, AssignmentStatus.WAITLISTED, pageable);
        Map<UUID, ShiftDetails> claimed =
                shifts.findAll(result.getContent().stream().map(Assignment::getShiftId).toList());
        var terms = terms();
        var positions = positions(result.getContent());
        List<WorkerShiftResponse> content = result.getContent().stream()
                .map(assignment -> response(
                        Objects.requireNonNull(claimed.get(assignment.getShiftId())), assignment, positions, terms))
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
     * Drops out of a claimed shift before the agency's cancellation deadline. The first in line
     * on the waitlist moves up into the spot in the same transaction. Freeing the spot changes the
     * shift, so the attempt is repeated on a conflict there.
     */
    WorkerShiftResponse cancel(UUID accountId, UUID shiftId) {
        var workerId = activeWorker(accountId);
        ConflictRetry.run(() -> transactions.execute(_ -> {
            if (shifts.find(shiftId).isEmpty()) {
                throw shiftNotFound();
            }
            var assignment = ownClaimForUpdate(shiftId, workerId);
            assignment.cancelByWorker(Instant.now(), cancellationDeadline());
            assignments.saveAndFlush(assignment);
            shifts.release(shiftId);
            events.publishEvent(new AssignmentCancelled(
                    TenantContext.require(), assignment.getId(), shiftId, workerId,
                    AssignmentCancelled.Cause.WORKER));
            waitlist.fill(shiftId);
            return assignment;
        }), ConflictRetry::busy);
        return get(accountId, shiftId);
    }

    /**
     * Puts the worker at the back of the waitlist of a full shift (ADR 0029). Not when they are on
     * the shift already, in any status, or booked for a shift at the same time.
     *
     * <p>The shift is read with a shared lock held until the entry is stored, so a change that
     * frees a spot at the same moment cannot slip in between: either it waits for the join and
     * then moves the new entry up, or it went first and the join sees the free spot and is
     * refused. The lock comes before any assignment is touched, as with every change of a slot,
     * and joins of different workers share it.
     */
    WorkerShiftResponse joinWaitlist(UUID accountId, UUID shiftId) {
        var workerId = activeWorker(accountId);
        transactions.executeWithoutResult(_ -> {
            var shift = shifts.findAndLock(shiftId).orElseThrow(WorkerShiftService::shiftNotFound);
            var existing = assignments.findStatus(shiftId, workerId);
            if (existing.isPresent()) {
                throw existing.get() == AssignmentStatus.WAITLISTED
                        ? AssignmentConflictException.alreadyOnWaitlist()
                        : ClaimService.alreadyClaimed();
            }
            var entry = Assignment.join(shift, workerId, agencies.settings().waitlist(), Instant.now());
            if (assignments.isBooked(workerId, AssignmentStatus.HOLDING, shift.startsAt(), shift.endsAt())) {
                throw ClaimService.overlap();
            }
            try {
                assignments.saveAndFlush(entry);
            } catch (DataIntegrityViolationException e) {
                // The same worker joined at the same moment, from another device.
                throw AssignmentConflictException.alreadyOnWaitlist();
            }
        });
        return get(accountId, shiftId);
    }

    /** Takes the worker off the waitlist without a trace; they can join again at the back. */
    WorkerShiftResponse leaveWaitlist(UUID accountId, UUID shiftId) {
        var workerId = activeWorker(accountId);
        transactions.executeWithoutResult(_ -> {
            if (shifts.find(shiftId).isEmpty()) {
                throw shiftNotFound();
            }
            var entry = assignments.findForUpdateByShiftIdAndWorkerId(shiftId, workerId)
                    .filter(Assignment::waiting)
                    .orElseThrow(() -> new ApiException(
                            HttpStatus.NOT_FOUND, "not_on_waitlist", "The worker is not on the waitlist of this shift."));
            entry.leave(Instant.now());
            assignments.delete(entry);
        });
        return get(accountId, shiftId);
    }

    /** The worker arrived at the shift; only when the agency uses check-in (ADR 0028). */
    WorkerShiftResponse checkIn(UUID accountId, UUID shiftId) {
        return changeOwn(accountId, shiftId, assignment -> assignment.checkIn(Instant.now()));
    }

    /** The worker left the shift; only when the agency uses check-in (ADR 0028). */
    WorkerShiftResponse checkOut(UUID accountId, UUID shiftId) {
        return changeOwn(accountId, shiftId, assignment -> assignment.checkOut(Instant.now()));
    }

    /** Applies a change of check-in or check-out to the worker's locked assignment. */
    private WorkerShiftResponse changeOwn(UUID accountId, UUID shiftId, Consumer<Assignment> change) {
        var workerId = activeWorker(accountId);
        if (!agencies.features().checkIn()) {
            throw new ApiException(
                    HttpStatus.CONFLICT, "check_in_disabled", "The agency does not use check-in in the app.");
        }
        transactions.executeWithoutResult(_ -> {
            if (shifts.find(shiftId).isEmpty()) {
                throw shiftNotFound();
            }
            var assignment = ownClaimForUpdate(shiftId, workerId);
            change.accept(assignment);
            assignments.saveAndFlush(assignment);
        });
        return get(accountId, shiftId);
    }

    /** The worker's locked claim on the shift; a place on its waitlist is no claim. */
    private Assignment ownClaimForUpdate(UUID shiftId, UUID workerId) {
        return assignments.findForUpdateByShiftIdAndWorkerId(shiftId, workerId)
                .filter(assignment -> !assignment.waiting())
                .orElseThrow(WorkerShiftService::assignmentNotFound);
    }

    /** The place in line of each of the assignments that is on a waitlist, by assignment id. */
    private Map<UUID, Integer> positions(Collection<Assignment> own) {
        return own.stream()
                .filter(Assignment::waiting)
                .collect(Collectors.toMap(Assignment::getId, entry -> assignments
                        .findIdsInLine(entry.getShiftId(), AssignmentStatus.WAITLISTED)
                        .indexOf(entry.getId()) + 1));
    }

    private Terms terms() {
        var settings = agencies.settings();
        return new Terms(settings.cancellationDeadline(), agencies.features().checkIn(), settings.waitlist());
    }

    private Duration cancellationDeadline() {
        return agencies.settings().cancellationDeadline();
    }

    private static ApiException assignmentNotFound() {
        return new ApiException(HttpStatus.NOT_FOUND, "assignment_not_found", "The worker has not claimed this shift.");
    }

    /**
     * What the agency's settings and features mean for the worker's claims.
     *
     * @param deadline how long before the start a worker can drop out
     * @param checkIn  whether the agency uses check-in in the app
     * @param waitlist whether the agency uses the waitlist
     */
    private record Terms(Duration deadline, boolean checkIn, boolean waitlist) {
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

    /**
     * @param assignment the worker's own claim or place on the waitlist; {@code null} if neither
     * @param positions  the places in line by assignment id
     */
    private static WorkerShiftResponse response(
            ShiftDetails shift, Assignment assignment, Map<UUID, Integer> positions, Terms terms) {
        var waiting = assignment != null && assignment.waiting();
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
                assignment == null || waiting
                        ? null
                        : new AssignmentSummary(
                                assignment.getId(),
                                assignment.getStatus(),
                                assignment.getClaimedAt(),
                                assignment.cancellableUntilIfHolding(terms.deadline()).orElse(null),
                                assignment.getCancelledBy(),
                                terms.checkIn() && assignment.worked() ? assignment.checkInFrom() : null,
                                assignment.getCheckedInAt(),
                                assignment.getCheckedOutAt(),
                                assignment.hours().isPresent()),
                terms.waitlist(),
                waiting ? new WaitlistPlace(positions.get(assignment.getId()), assignment.getClaimedAt()) : null);
    }
}
