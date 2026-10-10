package app.shiftboard.worker.internal;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import app.shiftboard.agency.QualificationSummary;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * The agency's worker pool. Dispatchers and admins only, enforced by the security configuration.
 */
@RestController
@RequestMapping("/workers")
class WorkerController {

    private final WorkerService workerService;

    WorkerController(WorkerService workerService) {
        this.workerService = workerService;
    }

    @GetMapping
    WorkerPage list(
            @RequestParam(required = false) WorkerStatus status,
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size) {
        return workerService.list(status, page, size);
    }

    @PostMapping("/{workerId}/approve")
    WorkerResponse approve(@PathVariable UUID workerId) {
        return workerService.approve(workerId);
    }

    @PostMapping("/{workerId}/reject")
    WorkerResponse reject(@PathVariable UUID workerId) {
        return workerService.reject(workerId);
    }

    record WorkerResponse(
            UUID id,
            String firstName,
            String lastName,
            String email,
            String phone,
            WorkerStatus status,
            List<QualificationSummary> qualifications,
            Instant createdAt) {
    }

    record WorkerPage(List<WorkerResponse> content, int page, int size, long totalElements, int totalPages) {
    }
}
