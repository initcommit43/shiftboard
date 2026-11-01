package app.shiftboard.identity.internal;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

import app.shiftboard.identity.internal.SecurityProperties.RateLimit;
import app.shiftboard.identity.internal.SecurityProperties.RateLimits;
import app.shiftboard.system.TooManyRequestsException;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockFilterChain;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.web.servlet.ModelAndView;

class RateLimitFilterTests {

    private static final Instant NOW = Instant.parse("2026-10-10T08:00:00Z");

    private final List<TooManyRequestsException> rejections = new ArrayList<>();
    private final RateLimitFilter filter = new RateLimitFilter(
            new RateLimits(perMinute(2), perMinute(3), perMinute(4), perMinute(5)),
            () -> NOW,
            (request, response, handler, exception) -> {
                rejections.add((TooManyRequestsException) exception);
                return new ModelAndView();
            });

    @AfterEach
    void clearSecurityContext() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void limitsLoginsPerAddressAcrossEmails() {
        assertAllowed(2, "POST", "/api/v1/auth/login", "10.0.0.1");

        assertRejected("POST", "/api/v1/auth/login", "10.0.0.1", "too_many_attempts");

        rejections.clear();
        assertAllowed(1, "POST", "/api/v1/auth/login", "10.0.0.2");
    }

    @Test
    void signupAndClientSetupShareTheirLimit() {
        assertAllowed(2, "GET", "/api/v1/signup/abc", "10.0.0.1");
        assertAllowed(1, "POST", "/api/v1/client-setup/def", "10.0.0.1");

        assertRejected("POST", "/api/v1/signup/abc", "10.0.0.1", "too_many_requests");
    }

    @Test
    void limitsRefreshAndLogoutPerAddress() {
        assertAllowed(3, "POST", "/api/v1/auth/refresh", "10.0.0.1");
        assertAllowed(1, "POST", "/api/v1/auth/logout", "10.0.0.1");

        assertRejected("POST", "/api/v1/auth/refresh", "10.0.0.1", "too_many_requests");
    }

    @Test
    void theRestOfTheApiIsLimitedPerUserFromAnyAddress() {
        authenticateAs("user-1");
        assertAllowed(3, "GET", "/api/v1/shifts", "10.0.0.1");
        assertAllowed(2, "GET", "/api/v1/me", "10.0.0.2");

        assertRejected("GET", "/api/v1/shifts", "10.0.0.3", "too_many_requests");

        rejections.clear();
        authenticateAs("user-2");
        assertAllowed(1, "GET", "/api/v1/shifts", "10.0.0.1");
    }

    @Test
    void requestsWithoutAUserCountAgainstTheirAddress() {
        assertAllowed(5, "GET", "/api/v1/shifts", "10.0.0.1");

        assertRejected("GET", "/api/v1/shifts", "10.0.0.1", "too_many_requests");

        rejections.clear();
        assertAllowed(1, "GET", "/api/v1/shifts", "10.0.0.2");
    }

    @Test
    void theStatusChecksAreNotLimited() {
        assertAllowed(10, "GET", "/api/v1/ping", "10.0.0.1");
        assertAllowed(10, "GET", "/actuator/health", "10.0.0.1");
    }

    @Test
    void aRejectionTellsWhenToTryAgain() {
        assertAllowed(2, "POST", "/api/v1/auth/login", "10.0.0.1");

        assertRejected("POST", "/api/v1/auth/login", "10.0.0.1", "too_many_attempts");

        // Two logins per minute refill one every 30 seconds.
        assertThat(rejections.getFirst().retryAfterSeconds()).isEqualTo(30);
    }

    private void assertAllowed(int times, String method, String path, String address) {
        for (int request = 0; request < times; request++) {
            var chain = send(method, path, address);
            assertThat(chain.getRequest()).as("%s %s from %s is passed on", method, path, address).isNotNull();
        }
        assertThat(rejections).isEmpty();
    }

    private void assertRejected(String method, String path, String address, String code) {
        var chain = send(method, path, address);

        assertThat(chain.getRequest()).isNull();
        assertThat(rejections).singleElement().satisfies(rejection -> assertThat(rejection.getCode()).isEqualTo(code));
    }

    private MockFilterChain send(String method, String path, String address) {
        var request = new MockHttpServletRequest(method, path);
        request.setRemoteAddr(address);
        var chain = new MockFilterChain();
        try {
            filter.doFilter(request, new MockHttpServletResponse(), chain);
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
        return chain;
    }

    private static void authenticateAs(String userId) {
        var jwt = Jwt.withTokenValue("token").header("alg", "HS256").subject(userId).build();
        SecurityContextHolder.getContext().setAuthentication(new JwtAuthenticationToken(jwt));
    }

    private static RateLimit perMinute(int requests) {
        return new RateLimit(requests, Duration.ofMinutes(1));
    }
}
