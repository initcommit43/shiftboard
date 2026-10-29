package app.shiftboard.shift.internal;

import java.util.UUID;

import app.shiftboard.shift.internal.ShiftController.ShiftRequest;
import app.shiftboard.shift.internal.ShiftController.ShiftResponse;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/**
 * Turns a client's staff request into a shift (ADR 0032). Lives here rather than in the
 * staffrequest module because it creates and answers with a shift. Dispatchers and admins only,
 * enforced by the security configuration.
 */
@RestController
class StaffRequestShiftController {

    private final ShiftService shiftService;

    StaffRequestShiftController(ShiftService shiftService) {
        this.shiftService = shiftService;
    }

    /** The dispatcher who creates the shift becomes its contact person. */
    @PostMapping("/staff-requests/{requestId}/shift")
    @ResponseStatus(HttpStatus.CREATED)
    ShiftResponse create(
            @PathVariable UUID requestId, @Valid @RequestBody ShiftRequest request,
            @AuthenticationPrincipal Jwt accessToken) {
        return shiftService.createFromStaffRequest(requestId, request, UUID.fromString(accessToken.getSubject()));
    }
}
