package app.shiftboard.identity.internal;

import java.io.IOException;
import java.time.InstantSource;
import java.util.List;

import app.shiftboard.identity.internal.SecurityProperties.RateLimit;
import app.shiftboard.identity.internal.SecurityProperties.RateLimits;
import app.shiftboard.system.TooManyRequestsException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpMethod;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.security.web.servlet.util.matcher.PathPatternRequestMatcher;
import org.springframework.security.web.util.matcher.OrRequestMatcher;
import org.springframework.security.web.util.matcher.RequestMatcher;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.web.servlet.HandlerExceptionResolver;

/**
 * Rate limits every API request (ADR 0033). The endpoints that need no login are limited per
 * client address, the rest of the API per user. Runs after the access token is read, so it
 * knows the user.
 */
class RateLimitFilter extends OncePerRequestFilter {

    private static final String TOO_MANY_REQUESTS = "too_many_requests";
    private static final String TRY_AGAIN_LATER = "Too many requests. Try again later.";

    private static final PathPatternRequestMatcher.Builder PATHS = PathPatternRequestMatcher.withDefaults();
    private static final RequestMatcher API = PATHS.matcher("/api/v1/**");
    private static final RequestMatcher UNLIMITED = PATHS.matcher("/api/v1/ping");

    private final List<Rule> addressRules;
    private final RateLimiter perUser;
    private final HandlerExceptionResolver exceptionResolver;

    RateLimitFilter(RateLimits limits, InstantSource clock, HandlerExceptionResolver exceptionResolver) {
        this.addressRules = List.of(
                // The same code as the per-account limit in LoginService, so clients show one message.
                new Rule(PATHS.matcher(HttpMethod.POST, "/api/v1/auth/login"), limiter(limits.login(), clock),
                        "too_many_attempts", "Too many login attempts. Try again later."),
                new Rule(PATHS.matcher("/api/v1/auth/**"), limiter(limits.session(), clock),
                        TOO_MANY_REQUESTS, TRY_AGAIN_LATER),
                new Rule(
                        new OrRequestMatcher(PATHS.matcher("/api/v1/signup/**"), PATHS.matcher("/api/v1/client-setup/**")),
                        limiter(limits.links(), clock), TOO_MANY_REQUESTS, TRY_AGAIN_LATER));
        this.perUser = limiter(limits.api(), clock);
        this.exceptionResolver = exceptionResolver;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        return !API.matches(request) || UNLIMITED.matches(request);
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        var rule = addressRules.stream().filter(candidate -> candidate.matcher().matches(request)).findFirst();
        var decision = rule.isPresent()
                ? rule.get().limiter().tryAcquire(request.getRemoteAddr())
                : perUser.tryAcquire(callerOf(request));
        if (decision.allowed()) {
            chain.doFilter(request, response);
            return;
        }
        var exception = new TooManyRequestsException(
                rule.map(Rule::code).orElse(TOO_MANY_REQUESTS),
                rule.map(Rule::detail).orElse(TRY_AGAIN_LATER),
                decision.retryAfter());
        exceptionResolver.resolveException(request, response, null, exception);
    }

    // Requests without a valid token are rejected later; until then they count against their address.
    private static String callerOf(HttpServletRequest request) {
        return SecurityContextHolder.getContext().getAuthentication() instanceof JwtAuthenticationToken authentication
                ? "user:" + authentication.getToken().getSubject()
                : "address:" + request.getRemoteAddr();
    }

    private static RateLimiter limiter(RateLimit limit, InstantSource clock) {
        return new RateLimiter(limit.requests(), limit.per(), clock);
    }

    private record Rule(RequestMatcher matcher, RateLimiter limiter, String code, String detail) {
    }
}
