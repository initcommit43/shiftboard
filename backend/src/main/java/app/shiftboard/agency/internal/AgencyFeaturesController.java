package app.shiftboard.agency.internal;

import app.shiftboard.agency.AgencyFeatures;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Dispatchers and admins read the features, only admins switch them; enforced by the security
 * configuration.
 */
@RestController
@RequestMapping("/agency/features")
class AgencyFeaturesController {

    private final AgencyService agencyService;

    AgencyFeaturesController(AgencyService agencyService) {
        this.agencyService = agencyService;
    }

    @GetMapping
    AgencyFeatures get() {
        return agencyService.features();
    }

    @PutMapping
    AgencyFeatures change(@Valid @RequestBody FeaturesRequest request) {
        return agencyService.changeFeatures(request.contactButton(), request.checkIn(), request.clientPortal());
    }

    /**
     * @param checkIn      optional, so that dashboards from before it existed keep working
     * @param clientPortal optional for the same reason
     */
    record FeaturesRequest(@NotNull Boolean contactButton, Boolean checkIn, Boolean clientPortal) {
    }
}
