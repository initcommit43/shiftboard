package app.shiftboard.agency.internal;

import app.shiftboard.agency.AgencySettings;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Dispatchers and admins read the settings, only admins change them; enforced by the security
 * configuration.
 */
@RestController
@RequestMapping("/agency/settings")
class AgencySettingsController {

    private final AgencyService agencyService;

    AgencySettingsController(AgencyService agencyService) {
        this.agencyService = agencyService;
    }

    @GetMapping
    AgencySettings get() {
        return agencyService.settings();
    }

    @PutMapping
    AgencySettings change(@Valid @RequestBody SettingsRequest request) {
        return agencyService.changeSettings(
                request.autoConfirm(), request.cancellationDeadlineHours(), request.waitlist());
    }

    /**
     * @param waitlist absent keeps the current value, so that a client that knows no waitlist
     *                 does not switch it off
     */
    record SettingsRequest(
            @NotNull Boolean autoConfirm,
            @NotNull @Min(0) @Max(AgencySettings.MAX_CANCELLATION_DEADLINE_HOURS) Integer cancellationDeadlineHours,
            Boolean waitlist) {
    }
}
