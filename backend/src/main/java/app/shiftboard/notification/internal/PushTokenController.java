package app.shiftboard.notification.internal;

import java.util.UUID;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/**
 * The devices of the signed-in worker. Workers only, enforced by the security configuration.
 */
@RestController
@RequestMapping("/worker/push-tokens")
class PushTokenController {

    private final PushService push;

    PushTokenController(PushService push) {
        this.push = push;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void register(@AuthenticationPrincipal Jwt accessToken, @Valid @RequestBody PushTokenRequest request) {
        push.register(UUID.fromString(accessToken.getSubject()), request.token(), request.platform().name());
    }

    @DeleteMapping("/{token}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void unregister(@AuthenticationPrincipal Jwt accessToken, @PathVariable String token) {
        push.unregister(UUID.fromString(accessToken.getSubject()), token);
    }

    enum Platform {
        ANDROID,
        IOS
    }

    record PushTokenRequest(@NotBlank @Size(max = 4096) String token, @NotNull Platform platform) {
    }
}
