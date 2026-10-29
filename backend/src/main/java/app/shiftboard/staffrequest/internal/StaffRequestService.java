package app.shiftboard.staffrequest.internal;

import java.time.Instant;
import java.util.List;
import java.util.Objects;
import java.util.UUID;
import java.util.function.Predicate;

import app.shiftboard.client.Clients;
import app.shiftboard.identity.UserAccounts;
import app.shiftboard.shift.Shifts;
import app.shiftboard.system.ApiException;
import app.shiftboard.system.InvalidFieldException;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
class StaffRequestService {

    private static final Sort NEWEST_FIRST = Sort.by(Sort.Order.desc("createdAt"), Sort.Order.desc("id"));

    private final StaffRequestRepository requests;

    private final Clients clients;

    private final UserAccounts userAccounts;

    private final Shifts shifts;

    StaffRequestService(StaffRequestRepository requests, Clients clients, UserAccounts userAccounts, Shifts shifts) {
        this.requests = requests;
        this.clients = clients;
        this.userAccounts = userAccounts;
        this.shifts = shifts;
    }

    /**
     * @throws InvalidFieldException {@code not_found} on {@code locationId} when it is not a
     *         location of the client, or what {@link StaffRequest} rejects
     */
    @Transactional
    StaffRequestResponse create(UUID clientId, UUID requestedBy, NewStaffRequest request) {
        var client = clients.find(clientId).orElseThrow();
        if (client.location(request.locationId()).isEmpty()) {
            throw new InvalidFieldException("locationId", "not_found");
        }
        var created = requests.save(new StaffRequest(
                clientId,
                request.locationId(),
                requestedBy,
                request.role().strip(),
                request.startsAt(),
                request.endsAt(),
                Boolean.TRUE.equals(request.endIsEstimate()),
                request.workerCount(),
                request.notes() == null || request.notes().isBlank() ? null : request.notes().strip(),
                Instant.now()));
        return forClient(List.of(created)).getFirst();
    }

    @Transactional(readOnly = true)
    StaffRequestResponse.Page listForClient(UUID clientId, int page, int size) {
        var result = requests.findByClientId(clientId, PageRequest.of(page, size, NEWEST_FIRST));
        return new StaffRequestResponse.Page(
                forClient(result.getContent()), page, size, result.getTotalElements(), result.getTotalPages());
    }

    /**
     * @throws ApiException {@code staff_request_not_found}, also for another client's request, or
     *         {@code staff_request_not_open}
     */
    @Transactional
    StaffRequestResponse withdraw(UUID clientId, UUID requestId) {
        var request = requests.findForUpdateById(requestId)
                .filter(found -> found.getClientId().equals(clientId))
                .orElseThrow(StaffRequestService::notFound);
        request.withdraw(Instant.now());
        return forClient(List.of(request)).getFirst();
    }

    static ApiException notFound() {
        return new ApiException(
                HttpStatus.NOT_FOUND, "staff_request_not_found", "There is no staff request with this id.");
    }

    /** Clients never see drafts, so the shift id only shows once the shift is published. */
    private List<StaffRequestResponse> forClient(List<StaffRequest> page) {
        var visible = shifts.findAll(page.stream()
                .map(StaffRequest::getShiftId)
                .filter(Objects::nonNull)
                .toList()).keySet();
        return responses(page, visible::contains);
    }

    // Clients, locations and names come from their modules in one call each, whatever the number of requests.
    List<StaffRequestResponse> responses(List<StaffRequest> page, Predicate<UUID> showShift) {
        var clientsById = clients.findAll(page.stream().map(StaffRequest::getClientId).distinct().toList());
        var names = userAccounts.staffContacts(page.stream().map(StaffRequest::getRequestedBy).distinct().toList());
        return page.stream()
                .map(request -> {
                    var client = clientsById.get(request.getClientId());
                    var requester = names.get(request.getRequestedBy());
                    var shiftId = request.getShiftId();
                    return new StaffRequestResponse(
                            request.getId(),
                            request.getStatus(),
                            new StaffRequestResponse.ClientSummary(client.id(), client.name()),
                            client.location(request.getLocationId()).orElseThrow(),
                            request.getRole(),
                            request.getStartsAt(),
                            request.getEndsAt(),
                            request.isEndIsEstimate(),
                            request.getWorkerCount(),
                            request.getNotes() == null ? "" : request.getNotes(),
                            requester == null ? "" : requester.name(),
                            request.getCreatedAt(),
                            request.getDecidedAt(),
                            request.getDeclineReason(),
                            shiftId != null && showShift.test(shiftId) ? shiftId : null);
                })
                .toList();
    }

    record NewStaffRequest(
            UUID locationId, String role, Instant startsAt, Instant endsAt, Boolean endIsEstimate,
            int workerCount, String notes) {
    }
}
