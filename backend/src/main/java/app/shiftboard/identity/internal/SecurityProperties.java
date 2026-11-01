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
        @NotNull @Valid LoginRateLimit loginRateLimit,
        @NotNull @Valid RateLimits rateLimits) {

    /**
     * @param maxAttempts login attempts allowed per email and client address within the window
     */
    record LoginRateLimit(@Min(1) int maxAttempts, @NotNull Duration window) {
    }

    /**
     * Limits per client address on the endpoints that need no login, and per user on the rest of the API (ADR 0033).
     *
     * @param login   logins per client address, across all emails
     * @param links   signup and client setup requests per client address
     * @param session token refreshes and logouts per client address
     * @param api     requests per user to the rest of the API
     */
    record RateLimits(
            @NotNull @Valid RateLimit login,
            @NotNull @Valid RateLimit links,
            @NotNull @Valid RateLimit session,
            @NotNull @Valid RateLimit api) {
    }

    /**
     * @param requests requests allowed at once, refilled evenly over {@code per}
     */
    record RateLimit(@Min(1) int requests, @NotNull Duration per) {
    }
}
