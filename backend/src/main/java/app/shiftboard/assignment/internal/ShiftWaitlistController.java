package app.shiftboard.assignment.internal;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import app.shiftboard.assignment.internal.ShiftAssignmentController.AssignedWorker;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/**
 * The waitlist of a shift as the agency sees it (ADR 0029): in line order, with nobody to promote
 * or reorder. Dispatchers and admins only, enforced by the security configuration.
 */
@RestController
@RequestMapping("/shifts/{shiftId}/waitlist")
class ShiftWaitlistController {

    private final ShiftWaitlistService service;

    ShiftWaitlistController(ShiftWaitlistService service) {
        this.service = service;
    }

    @GetMapping
    WaitlistEntryPage list(
            @PathVariable UUID shiftId,
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size) {
        return service.list(shiftId, page, size);
    }

    @DeleteMapping("/{entryId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void remove(@PathVariable UUID shiftId, @PathVariable UUID entryId) {
        service.remove(shiftId, entryId);
    }

    /**
     * @param position 1 moves up next
     * @param joinedAt when the worker joined the waitlist
     */
    record WaitlistEntryResponse(UUID id, int position, AssignedWorker worker, Instant joinedAt) {
    }

    record WaitlistEntryPage(
            List<WaitlistEntryResponse> content, int page, int size, long totalElements, int totalPages) {
    }
}
