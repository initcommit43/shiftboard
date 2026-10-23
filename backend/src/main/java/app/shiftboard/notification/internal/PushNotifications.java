package app.shiftboard.notification.internal;

import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;

import app.shiftboard.agency.Agencies;
import app.shiftboard.agency.TenantContext;
import app.shiftboard.assignment.AssignmentCancelled;
import app.shiftboard.assignment.AssignmentConfirmed;
import app.shiftboard.assignment.AssignmentRejected;
import app.shiftboard.assignment.AssignmentShiftChanged;
import app.shiftboard.assignment.WaitlistEntryRemoved;
import app.shiftboard.assignment.WaitlistMovedUp;
import app.shiftboard.assignment.WaitlistSpotFree;
import app.shiftboard.messaging.MessageSent;
import app.shiftboard.notification.internal.PushSender.PushMessage;
import app.shiftboard.shift.ShiftDetails;
import app.shiftboard.shift.ShiftPublished;
import app.shiftboard.shift.Shifts;
import app.shiftboard.worker.Workers;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionalEventListener;

/**
 * Tells workers about what matters to them, in reaction to the events of other modules and only
 * once the change is committed. Runs in the background, so that no request waits for the push
 * service. The texts are German: the app's first language (ADR 0013); the app shows the current
 * state from the API when opened.
 */
@Component
class PushNotifications {

    private static final ZoneId ZONE = ZoneId.of("Europe/Vienna");

    private static final DateTimeFormatter DAY_AND_TIME =
            DateTimeFormatter.ofPattern("EEE, d. MMM, HH:mm", Locale.GERMAN).withZone(ZONE);

    private static final int PREVIEW_LENGTH = 180;

    private final PushService push;

    private final Shifts shifts;

    private final Workers workers;

    private final Agencies agencies;

    PushNotifications(PushService push, Shifts shifts, Workers workers, Agencies agencies) {
        this.push = push;
        this.shifts = shifts;
        this.workers = workers;
        this.agencies = agencies;
    }

    /** A new shift goes to every active worker who has not paused new-shift notifications (S3-7). */
    @Async
    @TransactionalEventListener
    void on(ShiftPublished published) {
        inAgency(published.agencyId(), () -> shifts.find(published.shiftId()).ifPresent(shift ->
                push.send(workers.reachableForNewShifts(), message(
                        "Neue Schicht: " + shift.title(),
                        when(shift) + " · " + shift.client().name(),
                        "SHIFT_PUBLISHED", shift))));
    }

    @Async
    @TransactionalEventListener
    void on(AssignmentConfirmed confirmed) {
        aboutShift(confirmed.agencyId(), confirmed.workerId(), confirmed.shiftId(),
                "Schicht bestätigt", "CLAIM_CONFIRMED");
    }

    @Async
    @TransactionalEventListener
    void on(AssignmentRejected rejected) {
        aboutShift(rejected.agencyId(), rejected.workerId(), rejected.shiftId(),
                "Anfrage abgelehnt", "CLAIM_REJECTED");
    }

    /** The worker's own cancellation needs no push; the agency's does. */
    @Async
    @TransactionalEventListener
    void on(AssignmentCancelled cancelled) {
        switch (cancelled.cause()) {
            case WORKER -> {
            }
            case REMOVED -> aboutShift(cancelled.agencyId(), cancelled.workerId(), cancelled.shiftId(),
                    "Du bist nicht mehr eingeteilt", "REMOVED_BY_AGENCY");
            case SHIFT_CANCELLED -> aboutShift(cancelled.agencyId(), cancelled.workerId(), cancelled.shiftId(),
                    "Schicht abgesagt", "SHIFT_CANCELLED");
        }
    }

    @Async
    @TransactionalEventListener
    void on(AssignmentShiftChanged changed) {
        aboutShift(changed.agencyId(), changed.workerId(), changed.shiftId(), "Schicht geändert", "SHIFT_CHANGED");
    }

    /** The only push about it, also when the claim was confirmed right away (ADR 0029). */
    @Async
    @TransactionalEventListener
    void on(WaitlistMovedUp movedUp) {
        inAgency(movedUp.agencyId(), () -> shifts.find(movedUp.shiftId()).ifPresent(shift ->
                push.send(List.of(movedUp.workerId()), message(
                        "Du bist nachgerückt",
                        shift.title() + " · " + when(shift) + " · "
                                + (movedUp.confirmed() ? "bestätigt" : "wartet auf Bestätigung"),
                        "WAITLIST_MOVED_UP", shift))));
    }

    /** After the deadline, everyone waiting may claim the free spot; the first claim wins (ADR 0029). */
    @Async
    @TransactionalEventListener
    void on(WaitlistSpotFree spotFree) {
        inAgency(spotFree.agencyId(), () -> shifts.find(spotFree.shiftId()).ifPresent(shift ->
                push.send(spotFree.workerIds(), message(
                        "Platz frei", shift.title() + " · " + when(shift), "WAITLIST_SPOT_FREE", shift))));
    }

    /** Workers waiting for a shift that is called off get the push of those who held a spot. */
    @Async
    @TransactionalEventListener
    void on(WaitlistEntryRemoved removed) {
        switch (removed.cause()) {
            case REMOVED, OVERLAP -> aboutShift(removed.agencyId(), removed.workerId(), removed.shiftId(),
                    "Nicht mehr auf der Warteliste", "WAITLIST_REMOVED");
            case SHIFT_CANCELLED -> aboutShift(removed.agencyId(), removed.workerId(), removed.shiftId(),
                    "Schicht abgesagt", "SHIFT_CANCELLED");
        }
    }

    /** Messages and broadcasts of the agency; the worker's own messages need no push. */
    @Async
    @TransactionalEventListener
    void on(MessageSent sent) {
        if (sent.fromWorker()) {
            return;
        }
        inAgency(sent.agencyId(), () -> {
            var data = new HashMap<String, String>();
            data.put("type", sent.broadcast() ? "BROADCAST" : "MESSAGE");
            if (sent.shiftId() != null) {
                data.put("shiftId", sent.shiftId().toString());
            }
            push.send(List.of(sent.workerId()), new PushMessage(
                    "Nachricht von " + agencies.current().name(), preview(sent.body()), Map.copyOf(data)));
        });
    }

    private void aboutShift(UUID agencyId, UUID workerId, UUID shiftId, String title, String type) {
        inAgency(agencyId, () -> shifts.find(shiftId).ifPresent(shift ->
                push.send(List.of(workerId), message(title, shift.title() + " · " + when(shift), type, shift))));
    }

    private static PushMessage message(String title, String body, String type, ShiftDetails shift) {
        return new PushMessage(title, body, Map.of("type", type, "shiftId", shift.id().toString()));
    }

    private static String when(ShiftDetails shift) {
        return DAY_AND_TIME.format(shift.startsAt());
    }

    private static String preview(String body) {
        return body.length() <= PREVIEW_LENGTH ? body : body.substring(0, PREVIEW_LENGTH - 1) + "…";
    }

    // Bound before any transaction starts, which keeps the agency it was opened with.
    private static void inAgency(UUID agencyId, Runnable work) {
        try (var _ = TenantContext.bind(agencyId)) {
            work.run();
        }
    }
}
