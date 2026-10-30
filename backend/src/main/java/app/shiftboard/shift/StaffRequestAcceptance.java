package app.shiftboard.shift;

import java.util.UUID;

/**
 * Closes a client's staff request with the shift a dispatcher created from it (ADR 0032).
 * Implemented by the staffrequest module, so that this module does not depend on it.
 */
public interface StaffRequestAcceptance {

    /**
     * Marks the request as turned into the shift. Joins the transaction of the caller, so the
     * shift is only kept if the request accepts it.
     *
     * @param clientId the client of the shift, which has to be the one who sent the request
     * @throws app.shiftboard.system.ApiException {@code staff_request_not_found} or
     *         {@code staff_request_not_open}
     * @throws app.shiftboard.system.InvalidFieldException {@code not_request_client} on {@code clientId}
     */
    void accept(UUID requestId, UUID clientId, UUID shiftId);
}
