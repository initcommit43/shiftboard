package app.shiftboard.messaging.internal;

import java.util.UUID;

import app.shiftboard.agency.TenantContext;
import app.shiftboard.assignment.AssignmentCancelled;
import app.shiftboard.assignment.AssignmentConfirmed;
import app.shiftboard.assignment.AssignmentRejected;
import app.shiftboard.assignment.AssignmentShiftChanged;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionalEventListener;

/**
 * Writes what happened to a worker's claims into their conversation, in reaction to the events
 * of the assignment module and only once the change is committed. Delivered at least once
 * (ADR 0010); the dedup key keeps a message from appearing twice.
 */
@Component
class SystemMessages {

    private final MessagingService messaging;

    SystemMessages(MessagingService messaging) {
        this.messaging = messaging;
    }

    @TransactionalEventListener
    void on(AssignmentConfirmed confirmed) {
        record(confirmed.agencyId(), confirmed.workerId(), confirmed.shiftId(), confirmed.assignmentId(),
                SystemEvent.CLAIM_CONFIRMED);
    }

    @TransactionalEventListener
    void on(AssignmentRejected rejected) {
        record(rejected.agencyId(), rejected.workerId(), rejected.shiftId(), rejected.assignmentId(),
                SystemEvent.CLAIM_REJECTED);
    }

    @TransactionalEventListener
    void on(AssignmentCancelled cancelled) {
        var event = switch (cancelled.cause()) {
            case WORKER -> SystemEvent.CLAIM_CANCELLED_BY_WORKER;
            case REMOVED -> SystemEvent.REMOVED_BY_AGENCY;
            case SHIFT_CANCELLED -> SystemEvent.SHIFT_CANCELLED;
        };
        record(cancelled.agencyId(), cancelled.workerId(), cancelled.shiftId(), cancelled.assignmentId(), event);
    }

    /** Every change gets a message of its own. */
    @TransactionalEventListener
    void on(AssignmentShiftChanged changed) {
        try (var _ = TenantContext.bind(changed.agencyId())) {
            messaging.recordShiftChange(
                    changed.workerId(), changed.shiftId(), changed.changes(),
                    "assignment:" + changed.assignmentId() + ":" + SystemEvent.SHIFT_CHANGED + ":" + changed.changeId());
        }
    }

    private void record(UUID agencyId, UUID workerId, UUID shiftId, UUID assignmentId, SystemEvent event) {
        // Bound before the transaction of the message starts, which keeps the agency it was opened with.
        try (var _ = TenantContext.bind(agencyId)) {
            messaging.recordSystemMessage(workerId, shiftId, event, "assignment:" + assignmentId + ":" + event);
        }
    }
}
