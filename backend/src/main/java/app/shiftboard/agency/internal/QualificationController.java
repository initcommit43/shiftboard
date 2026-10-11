package app.shiftboard.agency.internal;

import java.util.List;

import app.shiftboard.agency.QualificationSummary;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * The qualifications a shift can require. Dispatchers and admins only, enforced by the security
 * configuration.
 */
@RestController
@RequestMapping("/qualifications")
class QualificationController {

    private static final Sort BY_NAME = Sort.by("name", "id");

    private final QualificationRepository qualifications;

    QualificationController(QualificationRepository qualifications) {
        this.qualifications = qualifications;
    }

    @GetMapping
    QualificationPage list(
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size) {
        var result = qualifications.findAll(PageRequest.of(page, size, BY_NAME));
        var content = result.getContent().stream()
                .map(qualification -> new QualificationSummary(qualification.getId(), qualification.getName()))
                .toList();
        return new QualificationPage(content, page, size, result.getTotalElements(), result.getTotalPages());
    }

    record QualificationPage(
            List<QualificationSummary> content, int page, int size, long totalElements, int totalPages) {
    }
}
