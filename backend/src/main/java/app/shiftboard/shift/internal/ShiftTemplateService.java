package app.shiftboard.shift.internal;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.Set;
import java.util.UUID;

import app.shiftboard.shift.internal.ShiftTemplateController.ShiftTemplatePage;
import app.shiftboard.shift.internal.ShiftTemplateController.ShiftTemplateRequest;
import app.shiftboard.shift.internal.ShiftTemplateController.ShiftTemplateResponse;
import app.shiftboard.system.ApiException;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
class ShiftTemplateService {

    private static final Sort BY_NAME = Sort.by(Sort.Order.asc("name").ignoreCase(), Sort.Order.asc("id"));

    private final ShiftTemplateRepository templates;
    private final ShiftReferences references;

    ShiftTemplateService(ShiftTemplateRepository templates, ShiftReferences references) {
        this.templates = templates;
        this.references = references;
    }

    @Transactional(readOnly = true)
    ShiftTemplatePage list(int page, int size) {
        var result = templates.findAll(PageRequest.of(page, size, BY_NAME));
        return new ShiftTemplatePage(
                result.getContent().stream().map(ShiftTemplateService::response).toList(),
                page, size, result.getTotalElements(), result.getTotalPages());
    }

    @Transactional
    ShiftTemplateResponse create(ShiftTemplateRequest request) {
        var qualificationIds = request.qualificationIds() == null ? Set.<UUID>of() : request.qualificationIds();
        references.check(request.clientId(), request.locationId(), qualificationIds);
        var name = request.name().strip();
        if (templates.existsByNameIgnoreCase(name)) {
            throw nameTaken();
        }

        var template = new ShiftTemplate(
                name,
                request.clientId(),
                request.locationId(),
                request.title().strip(),
                request.description() == null || request.description().isBlank() ? null : request.description().strip(),
                LocalTime.parse(request.startTime()),
                request.durationMinutes(),
                Boolean.TRUE.equals(request.endIsEstimate()),
                BigDecimal.valueOf(request.hourlyRateCents(), 2),
                request.slots(),
                qualificationIds);
        try {
            return response(templates.saveAndFlush(template));
        } catch (DataIntegrityViolationException e) {
            // A colleague saved a template with the same name at the same moment.
            throw nameTaken();
        }
    }

    private static ShiftTemplateResponse response(ShiftTemplate template) {
        return new ShiftTemplateResponse(
                template.getId(),
                template.getName(),
                template.getClientId(),
                template.getLocationId(),
                template.getTitle(),
                template.getDescription(),
                template.getStartTime().format(ShiftTemplateController.START_TIME),
                template.getDurationMinutes(),
                template.isEndIsEstimate(),
                template.getHourlyRate().movePointRight(2).intValueExact(),
                template.getSlots(),
                Set.copyOf(template.getQualificationIds()),
                template.getCreatedAt());
    }

    private static ApiException nameTaken() {
        return new ApiException(
                HttpStatus.CONFLICT, "template_name_taken", "The agency has a template with this name already.");
    }
}
