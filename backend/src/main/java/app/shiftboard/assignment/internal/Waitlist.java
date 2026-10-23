package app.shiftboard.assignment.internal;

import java.time.Duration;
import java.time.Instant;
import java.util.UUID;

import app.shiftboard.agency.Agencies;
import app.shiftboard.agency.TenantContext;
import app.shiftboard.assignment.WaitlistEntryRemoved;
import app.shiftboard.assignment.WaitlistMovedUp;
import app.shiftboard.assignment.WaitlistSpotFree;
import app.shiftboard.shift.ShiftDetails;
import app.shiftboard.shift.Shifts;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.dao.OptimisticLockingFailureException;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

/**
 * Hands freed spots of a shift to its waitlist (ADR 0029). Until the cancellation deadline, the
 * first in line moves up into each free spot; after it, everyone waiting is told that a spot is
 * free, and the first claim wins. The agency setting only governs joining: those already waiting
 * move up also when the agency switched the waitlist off since.
 */
@Component
class Waitlist {

    private static final String PUBLISHED = "PUBLISHED";

    private final AssignmentRepository assignments;

    private final Shifts shifts;

    private final Agencies agencies;

    private final ApplicationEventPublisher events;

    Waitlist(AssignmentRepository assignments, Shifts shifts, Agencies agencies, ApplicationEventPublisher events) {
        this.assignments = assignments;
        this.shifts = shifts;
        this.agencies = agencies;
        this.events = events;
    }

    /** What a free spot of a shift means for its waitlist. */
    enum Decision {
        /** No spot is free, or the shift is no longer offered: it has started, ended or was called off. */
        NONE,
        /** Before the cancellation deadline: the first in line moves up. */
        MOVE_UP,
        /** After the deadline: everyone waiting is told, nobody is moved in without a say. */
        OFFER
    }

    static Decision decide(ShiftDetails shift, Duration cancellationDeadline, Instant now) {
        if (!PUBLISHED.equals(shift.status()) || !now.isBefore(shift.startsAt())
                || shift.takenSlots() >= shift.slots()) {
            return Decision.NONE;
        }
        return now.isBefore(shift.startsAt().minus(cancellationDeadline)) ? Decision.MOVE_UP : Decision.OFFER;
    }

    /**
     * Fills the free spots of the shift from its waitlist. Runs inside the transaction that freed
     * a spot, so that the spot is freed and taken again at once, and a concurrent claim cannot
     * take it in between. Whoever is first in line but booked for a shift at the same time by now
     * is taken off the list instead, and the next one is tried.
     *
     * @throws OptimisticLockingFailureException if a concurrent change of the shift or a claim of
     *         the same worker won; the whole change can be repeated
     */
    @Transactional(propagation = Propagation.MANDATORY)
    void fill(UUID shiftId) {
        var shift = shifts.find(shiftId).orElseThrow();
        var settings = agencies.settings();
        var now = Instant.now();
        var decision = decide(shift, settings.cancellationDeadline(), now);
        if (decision == Decision.NONE) {
            return;
        }
        var line = assignments.findLineForUpdate(shiftId, AssignmentStatus.WAITLISTED);
        if (line.isEmpty()) {
            return;
        }
        var agencyId = TenantContext.require();
        if (decision == Decision.OFFER) {
            events.publishEvent(new WaitlistSpotFree(
                    agencyId, shiftId, line.stream().map(Assignment::getWorkerId).toList()));
            return;
        }
        var free = shift.slots() - shift.takenSlots();
        for (var entry : line) {
            if (free == 0) {
                return;
            }
            if (assignments.isBooked(entry.getWorkerId(), AssignmentStatus.HOLDING, entry.getStartsAt(),
                    entry.getEndsAt())) {
                assignments.delete(entry);
                events.publishEvent(new WaitlistEntryRemoved(
                        agencyId, entry.getId(), shiftId, entry.getWorkerId(), WaitlistEntryRemoved.Cause.OVERLAP));
                continue;
            }
            shifts.claim(shiftId);
            entry.moveUp(now, settings.autoConfirm());
            try {
                // Written right away: a claim of the same worker made elsewhere at the same moment
                // fails the exclusion constraint here.
                assignments.saveAndFlush(entry);
            } catch (DataIntegrityViolationException e) {
                // The transaction cannot go on; the next attempt sees the claim and skips the worker.
                throw new OptimisticLockingFailureException("A concurrent claim of the first in line won", e);
            }
            free--;
            events.publishEvent(new WaitlistMovedUp(
                    agencyId, entry.getId(), shiftId, entry.getWorkerId(),
                    entry.getStatus() == AssignmentStatus.CONFIRMED));
        }
    }
}
