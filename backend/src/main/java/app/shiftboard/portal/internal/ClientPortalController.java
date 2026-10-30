package app.shiftboard.portal.internal;

import java.time.Instant;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

import app.shiftboard.assignment.Assignments;
import app.shiftboard.client.LocationDetails;
import app.shiftboard.shift.ShiftDetails;
import app.shiftboard.shift.Shifts;
import app.shiftboard.system.ApiException;
import app.shiftboard.worker.WorkerContact;
import app.shiftboard.worker.Workers;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * The shifts of the logged-in user's client, as the client sees them: no hourly rate, no requests
 * or waitlist, and of the workers only the names of the confirmed ones (ADR 0032). Client users
 * only, enforced by the security configuration; the client comes from the access token.
 */
@RestController
class ClientPortalController {

    // Set on the access tokens of client users (see the identity module).
    private static final String CLIENT_CLAIM = "client_id";

    private static final Comparator<ClientShiftWorker> BY_NAME =
            Comparator.comparing(ClientShiftWorker::lastName).thenComparing(ClientShiftWorker::firstName);

    private final Shifts shifts;

    private final Assignments assignments;

    private final Workers workers;

    ClientPortalController(Shifts shifts, Assignments assignments, Workers workers) {
        this.shifts = shifts;
        this.assignments = assignments;
        this.workers = workers;
    }

    @GetMapping("/client/shifts")
    @Transactional(readOnly = true)
    ClientShiftPage list(
            @AuthenticationPrincipal Jwt accessToken,
            @RequestParam(defaultValue = "UPCOMING") ClientShiftPeriod period,
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size) {
        var result = shifts.listForClient(clientId(accessToken), period == ClientShiftPeriod.PAST, page, size);
        var confirmed = assignments.confirmedCounts(result.getContent().stream().map(ShiftDetails::id).toList());
        var content = result.getContent().stream()
                .map(shift -> ClientShift.of(shift, confirmed.getOrDefault(shift.id(), 0)))
                .toList();
        return new ClientShiftPage(content, page, size, result.getTotalElements(), result.getTotalPages());
    }

    @GetMapping("/client/shifts/{shiftId}")
    @Transactional(readOnly = true)
    ClientShiftDetail get(@AuthenticationPrincipal Jwt accessToken, @PathVariable UUID shiftId) {
        var clientId = clientId(accessToken);
        // Another client's shift answers like an unknown one.
        var shift = shifts.find(shiftId)
                .filter(found -> found.client().id().equals(clientId))
                .orElseThrow(() -> new ApiException(
                        HttpStatus.NOT_FOUND, "shift_not_found", "Your client has no shift with this id."));
        var workerIds = assignments.confirmedWorkers(shiftId);
        var names = workers.contacts(workerIds).values().stream()
                .map(ClientShiftWorker::of)
                .sorted(BY_NAME)
                .toList();
        var summary = ClientShift.of(shift, workerIds.size());
        return new ClientShiftDetail(
                summary.id(), summary.title(), summary.status(), summary.location(), summary.startsAt(),
                summary.endsAt(), summary.endIsEstimate(), summary.slots(), summary.confirmedCount(),
                shift.description() == null ? "" : shift.description(), names);
    }

    private static UUID clientId(Jwt accessToken) {
        return UUID.fromString(accessToken.getClaimAsString(CLIENT_CLAIM));
    }

    enum ClientShiftPeriod {
        UPCOMING,
        PAST
    }

    record ClientShift(
            UUID id, String title, String status, LocationDetails location, Instant startsAt, Instant endsAt,
            boolean endIsEstimate, int slots, int confirmedCount) {

        static ClientShift of(ShiftDetails shift, int confirmedCount) {
            return new ClientShift(shift.id(), shift.title(), shift.status(), shift.location(), shift.startsAt(),
                    shift.endsAt(), shift.endIsEstimate(), shift.slots(), confirmedCount);
        }
    }

    record ClientShiftPage(List<ClientShift> content, int page, int size, long totalElements, int totalPages) {
    }

    record ClientShiftWorker(String firstName, String lastName) {

        static ClientShiftWorker of(WorkerContact worker) {
            return new ClientShiftWorker(worker.firstName(), worker.lastName());
        }
    }

    record ClientShiftDetail(
            UUID id, String title, String status, LocationDetails location, Instant startsAt, Instant endsAt,
            boolean endIsEstimate, int slots, int confirmedCount, String description,
            List<ClientShiftWorker> confirmedWorkers) {
    }
}
