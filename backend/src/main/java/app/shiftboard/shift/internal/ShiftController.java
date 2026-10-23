package app.shiftboard.shift.internal;

import java.time.Instant;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import app.shiftboard.agency.QualificationSummary;
import app.shiftboard.client.LocationDetails;
import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/**
 * The agency's shifts as the dashboard works with them. Dispatchers and admins only, enforced
 * by the security configuration.
 */
@RestController
@RequestMapping("/shifts")
class ShiftController {

    private final ShiftService shiftService;

    ShiftController(ShiftService shiftService) {
        this.shiftService = shiftService;
    }

    @GetMapping
    ShiftPage list(
            @RequestParam(defaultValue = "UPCOMING") ShiftPeriod period,
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size) {
        return shiftService.list(period, page, size);
    }

    @GetMapping("/{shiftId}")
    ShiftResponse get(@PathVariable UUID shiftId) {
        return shiftService.get(shiftId);
    }

    /** The dispatcher who creates the shift becomes its contact person. */
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    ShiftResponse create(@Valid @RequestBody ShiftRequest request, @AuthenticationPrincipal Jwt accessToken) {
        return shiftService.create(request, UUID.fromString(accessToken.getSubject()));
    }

    @PutMapping("/{shiftId}")
    ShiftResponse update(@PathVariable UUID shiftId, @Valid @RequestBody ShiftChangeRequest request) {
        return shiftService.update(shiftId, request);
    }

    @PostMapping("/{shiftId}/publish")
    ShiftResponse publish(@PathVariable UUID shiftId) {
        return shiftService.publish(shiftId);
    }

    @PostMapping("/{shiftId}/cancel")
    ShiftResponse cancel(@PathVariable UUID shiftId) {
        return shiftService.cancel(shiftId);
    }

    enum ShiftPeriod {
        UPCOMING,
        PAST
    }

    /**
     * @param hourlyRateCents gross pay per hour in euro cents, so that no client handles money as a float
     */
    record ShiftRequest(
            @NotNull UUID clientId,
            @NotNull UUID locationId,
            @NotBlank @Size(max = 120) String title,
            @Size(max = 2000) String description,
            @NotNull Instant startsAt,
            @NotNull Instant endsAt,
            Boolean endIsEstimate,
            @NotNull @Min(1) Integer hourlyRateCents,
            @NotNull @Min(1) @Max(Shift.MAX_SLOTS) Integer slots,
            Set<UUID> qualificationIds,
            Boolean publish) {
    }

    /** Every field of a shift, as when creating one; the status does not change. */
    record ShiftChangeRequest(
            @NotNull UUID clientId,
            @NotNull UUID locationId,
            @NotBlank @Size(max = 120) String title,
            @Size(max = 2000) String description,
            @NotNull Instant startsAt,
            @NotNull Instant endsAt,
            Boolean endIsEstimate,
            @NotNull @Min(1) Integer hourlyRateCents,
            @NotNull @Min(1) @Max(Shift.MAX_SLOTS) Integer slots,
            Set<UUID> qualificationIds) {
    }

    record ClientSummary(UUID id, String name) {
    }

    record ShiftResponse(
            UUID id,
            String title,
            @JsonInclude(JsonInclude.Include.NON_NULL) String description,
            ShiftStatus status,
            ClientSummary client,
            LocationDetails location,
            Instant startsAt,
            Instant endsAt,
            boolean endIsEstimate,
            int hourlyRateCents,
            int slots,
            int takenSlots,
            int waitingCount,
            List<QualificationSummary> qualifications,
            Instant createdAt) {
    }

    record ShiftPage(List<ShiftResponse> content, int page, int size, long totalElements, int totalPages) {
    }
}
