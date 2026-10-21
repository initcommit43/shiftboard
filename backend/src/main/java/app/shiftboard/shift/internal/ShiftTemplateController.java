package app.shiftboard.shift.internal;

import java.time.Instant;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
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
 * The agency's shift templates, shared by all its dispatchers and admins (ADR 0025). Dispatchers
 * and admins only, enforced by the security configuration.
 */
@RestController
@RequestMapping("/shift-templates")
class ShiftTemplateController {

    /** How a template's start travels: a local time of day, {@code hh:mm}. */
    static final DateTimeFormatter START_TIME = DateTimeFormatter.ofPattern("HH:mm");

    private final ShiftTemplateService templateService;

    ShiftTemplateController(ShiftTemplateService templateService) {
        this.templateService = templateService;
    }

    @GetMapping
    ShiftTemplatePage list(
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size) {
        return templateService.list(page, size);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    ShiftTemplateResponse create(@Valid @RequestBody ShiftTemplateRequest request) {
        return templateService.create(request);
    }

    @PutMapping("/{templateId}")
    ShiftTemplateResponse update(@PathVariable UUID templateId, @Valid @RequestBody ShiftTemplateRequest request) {
        return templateService.update(templateId, request);
    }

    @DeleteMapping("/{templateId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void delete(@PathVariable UUID templateId) {
        templateService.delete(templateId);
    }

    /**
     * @param startTime       local time of day, {@code hh:mm}
     * @param hourlyRateCents gross pay per hour in euro cents
     */
    record ShiftTemplateRequest(
            @NotBlank @Size(max = 80) String name,
            @NotNull UUID clientId,
            @NotNull UUID locationId,
            @NotBlank @Size(max = 120) String title,
            @Size(max = 2000) String description,
            @NotNull @Pattern(regexp = "([01][0-9]|2[0-3]):[0-5][0-9]") String startTime,
            @NotNull @Min(1) @Max(ShiftTemplate.MAX_DURATION_MINUTES) Integer durationMinutes,
            Boolean endIsEstimate,
            @NotNull @Min(1) Integer hourlyRateCents,
            @NotNull @Min(1) @Max(Shift.MAX_SLOTS) Integer slots,
            Set<UUID> qualificationIds) {
    }

    record ShiftTemplateResponse(
            UUID id,
            String name,
            UUID clientId,
            UUID locationId,
            String title,
            @JsonInclude(JsonInclude.Include.NON_NULL) String description,
            String startTime,
            int durationMinutes,
            boolean endIsEstimate,
            int hourlyRateCents,
            int slots,
            Set<UUID> qualificationIds,
            Instant createdAt) {
    }

    record ShiftTemplatePage(
            List<ShiftTemplateResponse> content, int page, int size, long totalElements, int totalPages) {
    }
}
