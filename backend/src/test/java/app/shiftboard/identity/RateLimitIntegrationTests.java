package app.shiftboard.identity;

import app.shiftboard.IntegrationTest;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpHeaders;
import org.springframework.test.context.TestPropertySource;

/**
 * Runs in its own application context with a low limit on the signup and setup links. The
 * other tests share one client address, so their limits per address are set out of reach.
 */
@TestPropertySource(properties = {
    "shiftboard.security.rate-limits.links.requests=2",
    "shiftboard.security.rate-limits.links.per=15m"
})
class RateLimitIntegrationTests extends IntegrationTest {

    @Test
    void aRequestOverTheLimitIsAnsweredWithTooManyRequestsAndWhenToTryAgain() {
        var agency = data.agency("Donau Personal");
        client.get().uri("/api/v1/signup/{code}", agency.signupCode()).exchange().expectStatus().isOk();
        client.get().uri("/api/v1/client-setup/{code}", "unknown-code").exchange().expectStatus().isNotFound();

        var response = client.get().uri("/api/v1/signup/{code}", agency.signupCode()).exchange();

        // 15 minutes for two requests refill one every 7.5 minutes.
        response.expectHeader().valueEquals(HttpHeaders.RETRY_AFTER, "450");
        expectProblem(response, 429, "too_many_requests");
    }
}
