package app.shiftboard.identity.internal;

import java.time.Duration;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

/**
 * @param jwtSecret signs the access tokens (HS256), so it needs at least 256 bits. There is no
 *                  default outside the local profile: the application does not start without one.
 */
@ConfigurationProperties("shiftboard.security")
@Validated
record SecurityProperties(
        @NotNull @Size(min = 32) String jwtSecret,
        @NotNull Duration accessTokenTtl,
        @NotNull Duration refreshTokenTtl,
        @NotNull @Valid LoginRateLimit loginRateLimit) {

    /**
     * @param maxAttempts login attempts allowed per email and client address within the window
     */
    record LoginRateLimit(@Min(1) int maxAttempts, @NotNull Duration window) {
    }
}
