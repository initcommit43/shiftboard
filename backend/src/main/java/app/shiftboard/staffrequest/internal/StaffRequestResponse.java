package app.shiftboard.staffrequest.internal;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import app.shiftboard.client.LocationDetails;
import com.fasterxml.jackson.annotation.JsonInclude;

/**
 * A staff request as clients and dispatchers see it. Nothing about pay.
 *
 * @param notes   empty when the client wrote nothing
 * @param shiftId for clients only once the shift is published
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
record StaffRequestResponse(
        UUID id,
        StaffRequestStatus status,
        ClientSummary client,
        LocationDetails location,
        String role,
        Instant startsAt,
        Instant endsAt,
        boolean endIsEstimate,
        int workerCount,
        String notes,
        String requestedBy,
        Instant createdAt,
        Instant decidedAt,
        String declineReason,
        UUID shiftId) {

    record ClientSummary(UUID id, String name) {
    }

    record Page(List<StaffRequestResponse> content, int page, int size, long totalElements, int totalPages) {
    }
}
