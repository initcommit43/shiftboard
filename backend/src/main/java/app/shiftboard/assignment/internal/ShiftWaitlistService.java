package app.shiftboard.assignment.internal;

import java.util.UUID;
import java.util.stream.IntStream;

import app.shiftboard.agency.TenantContext;
import app.shiftboard.assignment.WaitlistEntryRemoved;
import app.shiftboard.assignment.internal.ShiftAssignmentController.AssignedWorker;
import app.shiftboard.assignment.internal.ShiftWaitlistController.WaitlistEntryPage;
import app.shiftboard.assignment.internal.ShiftWaitlistController.WaitlistEntryResponse;
import app.shiftboard.shift.Shifts;
import app.shiftboard.system.ApiException;
import app.shiftboard.worker.Workers;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * The agency's side of a shift's waitlist (ADR 0029): who waits, in line order, and taking
 * someone off it.
 */
@Service
class ShiftWaitlistService {

    /** First come, first served; the same order the line moves up in. */
    private static final Sort LINE_ORDER = Sort.by("claimedAt", "id");

    private final AssignmentRepository assignments;

    private final Shifts shifts;

    private final Workers workers;

    private final ApplicationEventPublisher events;

    ShiftWaitlistService(
            AssignmentRepository assignments, Shifts shifts, Workers workers, ApplicationEventPublisher events) {
        this.assignments = assignments;
        this.shifts = shifts;
        this.workers = workers;
        this.events = events;
    }

    @Transactional(readOnly = true)
    WaitlistEntryPage list(UUID shiftId, int page, int size) {
        requireShift(shiftId);
        var result = assignments.findByShiftIdAndStatus(
                shiftId, AssignmentStatus.WAITLISTED, PageRequest.of(page, size, LINE_ORDER));
        var entries = result.getContent();
        // Names and phones come from the worker module in one call, whatever the length of the line.
        var contacts = workers.contacts(entries.stream().map(Assignment::getWorkerId).distinct().toList());
        var first = page * size + 1;
        var content = IntStream.range(0, entries.size())
                .mapToObj(index -> {
                    var entry = entries.get(index);
                    var worker = contacts.get(entry.getWorkerId());
                    return new WaitlistEntryResponse(
                            entry.getId(),
                            first + index,
                            new AssignedWorker(worker.id(), worker.firstName(), worker.lastName(), worker.phone()),
                            entry.getClaimedAt());
                })
                .toList();
        return new WaitlistEntryPage(content, page, size, result.getTotalElements(), result.getTotalPages());
    }

    /** Takes the worker off the waitlist and tells them; the others keep their order. */
    @Transactional
    void remove(UUID shiftId, UUID entryId) {
        requireShift(shiftId);
        var entry = assignments.findForUpdate(entryId, shiftId)
                .filter(Assignment::waiting)
                .orElseThrow(() -> new ApiException(
                        HttpStatus.NOT_FOUND, "waitlist_entry_not_found",
                        "The shift's waitlist has no entry with this id."));
        assignments.delete(entry);
        events.publishEvent(new WaitlistEntryRemoved(
                TenantContext.require(), entry.getId(), shiftId, entry.getWorkerId(),
                WaitlistEntryRemoved.Cause.REMOVED));
    }

    private void requireShift(UUID shiftId) {
        if (!shifts.exists(shiftId)) {
            throw new ApiException(HttpStatus.NOT_FOUND, "shift_not_found", "The agency has no shift with this id.");
        }
    }
}
