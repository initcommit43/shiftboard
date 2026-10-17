package app.shiftboard.worker.internal;

import java.util.UUID;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * The worker's own notification preferences. Workers only, enforced by the security
 * configuration; the worker also has to be active.
 */
@RestController
@RequestMapping("/worker/notification-settings")
class NotificationSettingsController {

    private final NotificationSettingsService service;

    NotificationSettingsController(NotificationSettingsService service) {
        this.service = service;
    }

    @GetMapping
    NotificationSettings get(@AuthenticationPrincipal Jwt accessToken) {
        return service.get(UUID.fromString(accessToken.getSubject()));
    }

    @PutMapping
    NotificationSettings change(
            @AuthenticationPrincipal Jwt accessToken, @Valid @RequestBody NotificationSettingsRequest request) {
        return service.change(UUID.fromString(accessToken.getSubject()), request.newShiftsPaused());
    }

    record NotificationSettingsRequest(@NotNull Boolean newShiftsPaused) {
    }

    record NotificationSettings(boolean newShiftsPaused) {
    }
}
