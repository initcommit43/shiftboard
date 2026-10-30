package app.shiftboard.staffrequest.internal;

import java.time.Instant;
import java.util.UUID;

import app.shiftboard.staffrequest.internal.StaffRequestService.NewStaffRequest;
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
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/**
 * The staff requests of the logged-in user's client. Client users only, enforced by the security
 * configuration; the client comes from the access token.
 */
@RestController
@RequestMapping("/client/staff-requests")
class ClientStaffRequestController {

    // Set on the access tokens of client users (see the identity module).
    private static final String CLIENT_CLAIM = "client_id";

    private final StaffRequestService service;

    ClientStaffRequestController(StaffRequestService service) {
        this.service = service;
    }

    @GetMapping
    StaffRequestResponse.Page list(
            @AuthenticationPrincipal Jwt accessToken,
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size) {
        return service.listForClient(clientId(accessToken), page, size);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    StaffRequestResponse create(
            @AuthenticationPrincipal Jwt accessToken, @Valid @RequestBody StaffRequestRequest request) {
        return service.create(clientId(accessToken), UUID.fromString(accessToken.getSubject()), new NewStaffRequest(
                request.locationId(), request.role(), request.startsAt(), request.endsAt(),
                request.endIsEstimate(), request.workerCount(), request.notes()));
    }

    @PostMapping("/{requestId}/withdraw")
    StaffRequestResponse withdraw(@AuthenticationPrincipal Jwt accessToken, @PathVariable UUID requestId) {
        return service.withdraw(clientId(accessToken), requestId);
    }

    private static UUID clientId(Jwt accessToken) {
        return UUID.fromString(accessToken.getClaimAsString(CLIENT_CLAIM));
    }

    record StaffRequestRequest(
            @NotNull UUID locationId,
            @NotBlank @Size(max = 120) String role,
            @NotNull Instant startsAt,
            @NotNull Instant endsAt,
            Boolean endIsEstimate,
            @NotNull @Min(1) @Max(StaffRequest.MAX_WORKERS) Integer workerCount,
            @Size(max = 2000) String notes) {
    }
}
