package app.shiftboard.assignment.internal;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import com.fasterxml.jackson.annotation.JsonInclude;
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
 * The claims on a shift and the agency's decisions on them. Dispatchers and admins only,
 * enforced by the security configuration.
 */
@RestController
@RequestMapping("/shifts/{shiftId}/assignments")
class ShiftAssignmentController {

    private final ShiftAssignmentService service;

    ShiftAssignmentController(ShiftAssignmentService service) {
        this.service = service;
    }

    @GetMapping
    ShiftAssignmentPage list(
            @PathVariable UUID shiftId,
            @RequestParam(required = false) AssignmentStatus status,
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size) {
        return service.list(shiftId, status, page, size);
    }

    @PostMapping("/{assignmentId}/approve")
    ShiftAssignmentResponse approve(@PathVariable UUID shiftId, @PathVariable UUID assignmentId) {
        return service.approve(shiftId, assignmentId);
    }

    @PostMapping("/{assignmentId}/reject")
    ShiftAssignmentResponse reject(@PathVariable UUID shiftId, @PathVariable UUID assignmentId) {
        return service.reject(shiftId, assignmentId);
    }

    @PostMapping("/{assignmentId}/remove")
    ShiftAssignmentResponse remove(
            @PathVariable UUID shiftId, @PathVariable UUID assignmentId,
            @Valid @RequestBody RemoveRequest request) {
        return service.remove(shiftId, assignmentId, request.reason().strip());
    }

    @PostMapping("/{assignmentId}/no-show")
    ShiftAssignmentResponse markNoShow(@PathVariable UUID shiftId, @PathVariable UUID assignmentId) {
        return service.markNoShow(shiftId, assignmentId);
    }

    record RemoveRequest(@NotBlank @Size(max = 500) String reason) {
    }

    record AssignedWorker(UUID id, String firstName, String lastName, String phone) {
    }

    record ShiftAssignmentResponse(
            UUID id,
            AssignmentStatus status,
            AssignedWorker worker,
            Instant claimedAt,
            @JsonInclude(JsonInclude.Include.NON_NULL) Instant decidedAt,
            @JsonInclude(JsonInclude.Include.NON_NULL) CancelledBy cancelledBy,
            @JsonInclude(JsonInclude.Include.NON_NULL) String reason) {
    }

    record ShiftAssignmentPage(
            List<ShiftAssignmentResponse> content, int page, int size, long totalElements, int totalPages) {
    }
}
