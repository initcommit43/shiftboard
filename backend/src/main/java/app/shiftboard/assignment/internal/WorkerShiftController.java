package app.shiftboard.assignment.internal;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import app.shiftboard.agency.QualificationSummary;
import app.shiftboard.client.LocationDetails;
import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/**
 * The worker app's view of the agency's shifts. Workers only, enforced by the security
 * configuration; the worker also has to be active.
 */
@RestController
@RequestMapping("/worker")
class WorkerShiftController {

    private final WorkerShiftService workerShiftService;

    WorkerShiftController(WorkerShiftService workerShiftService) {
        this.workerShiftService = workerShiftService;
    }

    @GetMapping("/shifts")
    WorkerShiftPage list(
            @AuthenticationPrincipal Jwt accessToken,
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size) {
        return workerShiftService.listOpen(accountId(accessToken), page, size);
    }

    @GetMapping("/shifts/{shiftId}")
    WorkerShiftResponse get(@AuthenticationPrincipal Jwt accessToken, @PathVariable UUID shiftId) {
        return workerShiftService.get(accountId(accessToken), shiftId);
    }

    @PostMapping("/shifts/{shiftId}/claim")
    @ResponseStatus(HttpStatus.CREATED)
    WorkerShiftResponse claim(@AuthenticationPrincipal Jwt accessToken, @PathVariable UUID shiftId) {
        return workerShiftService.claim(accountId(accessToken), shiftId);
    }

    @PostMapping("/shifts/{shiftId}/cancel")
    WorkerShiftResponse cancel(@AuthenticationPrincipal Jwt accessToken, @PathVariable UUID shiftId) {
        return workerShiftService.cancel(accountId(accessToken), shiftId);
    }

    @PostMapping("/shifts/{shiftId}/check-in")
    WorkerShiftResponse checkIn(@AuthenticationPrincipal Jwt accessToken, @PathVariable UUID shiftId) {
        return workerShiftService.checkIn(accountId(accessToken), shiftId);
    }

    @PostMapping("/shifts/{shiftId}/check-out")
    WorkerShiftResponse checkOut(@AuthenticationPrincipal Jwt accessToken, @PathVariable UUID shiftId) {
        return workerShiftService.checkOut(accountId(accessToken), shiftId);
    }

    @GetMapping("/my-shifts")
    WorkerShiftPage listClaimed(
            @AuthenticationPrincipal Jwt accessToken,
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size) {
        return workerShiftService.listClaimed(accountId(accessToken), page, size);
    }

    private static UUID accountId(Jwt accessToken) {
        return UUID.fromString(accessToken.getSubject());
    }

    record ClientSummary(UUID id, String name) {
    }

    record Contact(String name, @JsonInclude(JsonInclude.Include.NON_NULL) String phone) {
    }

    /**
     * @param cancellableUntil until when the worker can drop out in the app; only while pending or confirmed
     * @param cancelledBy      who cancelled; only when cancelled
     * @param checkInFrom      from when the worker can check in; only when the agency uses check-in
     *                         and the spot is confirmed or completed
     * @param hoursApproved    the agency approved the hours, so checking out is no longer possible
     */
    record AssignmentSummary(
            UUID id,
            AssignmentStatus status,
            Instant claimedAt,
            @JsonInclude(JsonInclude.Include.NON_NULL) Instant cancellableUntil,
            @JsonInclude(JsonInclude.Include.NON_NULL) CancelledBy cancelledBy,
            @JsonInclude(JsonInclude.Include.NON_NULL) Instant checkInFrom,
            @JsonInclude(JsonInclude.Include.NON_NULL) Instant checkedInAt,
            @JsonInclude(JsonInclude.Include.NON_NULL) Instant checkedOutAt,
            boolean hoursApproved) {
    }

    /**
     * @param assignment the worker's own claim on the shift, absent if there is none
     */
    record WorkerShiftResponse(
            UUID id,
            String title,
            @JsonInclude(JsonInclude.Include.NON_NULL) String description,
            String status,
            ClientSummary client,
            LocationDetails location,
            Instant startsAt,
            Instant endsAt,
            boolean endIsEstimate,
            int hourlyRateCents,
            int slots,
            int takenSlots,
            List<QualificationSummary> qualifications,
            Contact contact,
            @JsonInclude(JsonInclude.Include.NON_NULL) AssignmentSummary assignment) {
    }

    record WorkerShiftPage(List<WorkerShiftResponse> content, int page, int size, long totalElements, int totalPages) {
    }
}
