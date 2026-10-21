package app.shiftboard.assignment.internal;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import app.shiftboard.assignment.internal.ShiftAssignmentController.AssignedWorker;
import app.shiftboard.assignment.internal.ShiftAssignmentController.HoursResponse;
import app.shiftboard.client.LocationDetails;
import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * The hours of a period, the source of the payroll export the dashboard builds (ADR 0028).
 * Dispatchers and admins only, enforced by the security configuration.
 */
@RestController
@RequestMapping("/hours")
class HoursController {

    private final HoursService service;

    HoursController(HoursService service) {
        this.service = service;
    }

    @GetMapping
    HoursEntryPage list(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant from,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant to,
            @RequestParam(required = false) HoursStatus status,
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size) {
        return service.list(from, to, status, page, size);
    }

    enum HoursStatus {
        OPEN,
        APPROVED
    }

    record HoursShift(
            UUID id, String title, Instant startsAt, Instant endsAt, int hourlyRateCents, Client client,
            LocationDetails location) {
    }

    record Client(UUID id, String name) {
    }

    record HoursEntry(
            UUID assignmentId,
            HoursStatus status,
            HoursShift shift,
            AssignedWorker worker,
            @JsonInclude(JsonInclude.Include.NON_NULL) Instant checkedInAt,
            @JsonInclude(JsonInclude.Include.NON_NULL) Instant checkedOutAt,
            @JsonInclude(JsonInclude.Include.NON_NULL) HoursResponse hours) {
    }

    record HoursEntryPage(List<HoursEntry> content, int page, int size, long totalElements, int totalPages) {
    }
}
