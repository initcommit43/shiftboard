package app.shiftboard.assignment.internal;

import java.time.Instant;
import java.util.Objects;

import app.shiftboard.assignment.internal.HoursController.Client;
import app.shiftboard.assignment.internal.HoursController.HoursEntry;
import app.shiftboard.assignment.internal.HoursController.HoursEntryPage;
import app.shiftboard.assignment.internal.HoursController.HoursShift;
import app.shiftboard.assignment.internal.HoursController.HoursStatus;
import app.shiftboard.assignment.internal.ShiftAssignmentController.AssignedWorker;
import app.shiftboard.assignment.internal.ShiftAssignmentController.HoursResponse;
import app.shiftboard.shift.Shifts;
import app.shiftboard.system.InvalidFieldException;
import app.shiftboard.worker.Workers;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Every worker who held a confirmed spot on a shift that has started, with the hours the agency
 * approved for them (ADR 0028).
 */
@Service
class HoursService {

    private static final Sort EARLIEST_START_FIRST = Sort.by("startsAt", "shiftId", "id");

    private final AssignmentRepository assignments;

    private final Shifts shifts;

    private final Workers workers;

    HoursService(AssignmentRepository assignments, Shifts shifts, Workers workers) {
        this.assignments = assignments;
        this.shifts = shifts;
        this.workers = workers;
    }

    /** The entries of shifts starting in {@code [from, to)}, earliest start first. */
    @Transactional(readOnly = true)
    HoursEntryPage list(Instant from, Instant to, HoursStatus status, int page, int size) {
        if (!to.isAfter(from)) {
            throw new InvalidFieldException("to", "before_start");
        }
        var pageable = PageRequest.of(page, size, EARLIEST_START_FIRST);
        var now = Instant.now();
        var worked = AssignmentStatus.WORKED;
        var result = status == null
                ? assignments.findWorked(worked, from, to, now, pageable)
                : status == HoursStatus.OPEN
                        ? assignments.findWorkedWithoutHours(worked, from, to, now, pageable)
                        : assignments.findWorkedWithHours(worked, from, to, now, pageable);
        var content = result.getContent();
        var shiftsById = shifts.findAll(content.stream().map(Assignment::getShiftId).distinct().toList());
        var contacts = workers.contacts(content.stream().map(Assignment::getWorkerId).distinct().toList());
        var entries = content.stream()
                .map(assignment -> {
                    var shift = Objects.requireNonNull(shiftsById.get(assignment.getShiftId()));
                    var worker = contacts.get(assignment.getWorkerId());
                    var hours = assignment.hours();
                    return new HoursEntry(
                            assignment.getId(),
                            hours.isPresent() ? HoursStatus.APPROVED : HoursStatus.OPEN,
                            new HoursShift(
                                    shift.id(), shift.title(), shift.startsAt(), shift.endsAt(),
                                    shift.hourlyRateCents(), new Client(shift.client().id(), shift.client().name()),
                                    shift.location()),
                            new AssignedWorker(worker.id(), worker.firstName(), worker.lastName(), worker.phone()),
                            assignment.getCheckedInAt(),
                            assignment.getCheckedOutAt(),
                            hours.map(approved -> HoursResponse.of(approved, shift.hourlyRateCents())).orElse(null));
                })
                .toList();
        return new HoursEntryPage(entries, page, size, result.getTotalElements(), result.getTotalPages());
    }
}
