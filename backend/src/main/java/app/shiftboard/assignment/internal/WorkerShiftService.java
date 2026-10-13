package app.shiftboard.assignment.internal;

import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

import app.shiftboard.assignment.internal.WorkerShiftController.AssignmentSummary;
import app.shiftboard.assignment.internal.WorkerShiftController.ClientSummary;
import app.shiftboard.assignment.internal.WorkerShiftController.Contact;
import app.shiftboard.assignment.internal.WorkerShiftController.WorkerShiftPage;
import app.shiftboard.assignment.internal.WorkerShiftController.WorkerShiftResponse;
import app.shiftboard.identity.WorkerProfileProvider;
import app.shiftboard.shift.ShiftDetails;
import app.shiftboard.shift.Shifts;
import app.shiftboard.system.ApiException;
import org.springframework.dao.OptimisticLockingFailureException;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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

    WorkerShiftService(
            AssignmentRepository assignments, ClaimService claims, Shifts shifts,
            WorkerProfileProvider workerProfiles) {
        this.assignments = assignments;
        this.claims = claims;
        this.shifts = shifts;
        this.workerProfiles = workerProfiles;
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
        return new WorkerShiftPage(
                result.getContent().stream().map(shift -> response(shift, own.get(shift.id()))).toList(),
                page, size, result.getTotalElements(), result.getTotalPages());
    }

    @Transactional(readOnly = true)
    WorkerShiftResponse get(UUID accountId, UUID shiftId) {
        var workerId = activeWorker(accountId);
        var shift = shifts.find(shiftId)
                .orElseThrow(() -> new ApiException(
                        HttpStatus.NOT_FOUND, "shift_not_found", "The agency has no shift with this id."));
        return response(shift, assignments.findByShiftIdAndWorkerId(shiftId, workerId).orElse(null));
    }

    /** Every shift the worker has claimed, whatever became of the claim. */
    @Transactional(readOnly = true)
    WorkerShiftPage listClaimed(UUID accountId, int page, int size) {
        var workerId = activeWorker(accountId);
        var result = assignments.findByWorkerId(workerId, PageRequest.of(page, size, EARLIEST_START_FIRST));
        Map<UUID, ShiftDetails> claimed =
                shifts.findAll(result.getContent().stream().map(Assignment::getShiftId).toList());
        List<WorkerShiftResponse> content = result.getContent().stream()
                .map(assignment -> response(Objects.requireNonNull(claimed.get(assignment.getShiftId())), assignment))
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

    private UUID activeWorker(UUID accountId) {
        return workerProfiles.findByAccountId(accountId)
                .filter(worker -> ACTIVE.equals(worker.status()))
                .orElseThrow(() -> new ApiException(
                        HttpStatus.FORBIDDEN, "worker_not_active",
                        "Shifts are open to workers the agency has approved."))
                .id();
    }

    private static WorkerShiftResponse response(ShiftDetails shift, Assignment assignment) {
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
                                assignment.getId(), assignment.getStatus(), assignment.getClaimedAt()));
    }
}
