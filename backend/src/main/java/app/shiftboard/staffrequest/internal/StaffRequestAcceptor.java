package app.shiftboard.staffrequest.internal;

import java.time.Instant;
import java.util.UUID;

import app.shiftboard.shift.StaffRequestAcceptance;
import app.shiftboard.system.InvalidFieldException;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * Closes a request with the shift a dispatcher created from it. Kept apart from
 * {@link StaffRequestService}, which reads shifts, so that the shift module can call it without a
 * cycle between the two.
 */
@Component
class StaffRequestAcceptor implements StaffRequestAcceptance {

    private final StaffRequestRepository requests;

    StaffRequestAcceptor(StaffRequestRepository requests) {
        this.requests = requests;
    }

    @Override
    @Transactional
    public void accept(UUID requestId, UUID clientId, UUID shiftId) {
        var request = requests.findForUpdateById(requestId).orElseThrow(StaffRequestService::notFound);
        if (!request.getClientId().equals(clientId)) {
            throw new InvalidFieldException("clientId", "not_request_client");
        }
        request.accept(shiftId, Instant.now());
    }
}
