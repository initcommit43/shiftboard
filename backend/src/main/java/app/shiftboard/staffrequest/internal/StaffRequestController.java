package app.shiftboard.staffrequest.internal;

import java.util.UUID;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * Clients' staff requests as dispatchers handle them. Turning one into a shift lives in the shift
 * module. Dispatchers and admins only, enforced by the security configuration.
 */
@RestController
@RequestMapping("/staff-requests")
class StaffRequestController {

    private final StaffRequestService service;

    StaffRequestController(StaffRequestService service) {
        this.service = service;
    }

    @GetMapping
    StaffRequestResponse.Page list(
            @RequestParam(defaultValue = "OPEN") StaffRequestStatus status,
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size) {
        return service.listForAgency(status, page, size);
    }

    @GetMapping("/{requestId}")
    StaffRequestResponse get(@PathVariable UUID requestId) {
        return service.get(requestId);
    }

    @PostMapping("/{requestId}/decline")
    StaffRequestResponse decline(@PathVariable UUID requestId, @Valid @RequestBody DeclineRequest request) {
        return service.decline(requestId, request.reason());
    }

    record DeclineRequest(@NotBlank @Size(max = 500) String reason) {
    }
}
