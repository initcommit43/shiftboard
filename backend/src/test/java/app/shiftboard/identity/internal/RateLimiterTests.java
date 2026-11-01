package app.shiftboard.identity.internal;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Duration;
import java.time.Instant;
import java.util.concurrent.atomic.AtomicReference;

import org.junit.jupiter.api.Test;

class RateLimiterTests {

    private static final Duration PER = Duration.ofMinutes(15);

    private final AtomicReference<Instant> now = new AtomicReference<>(Instant.parse("2026-10-10T08:00:00Z"));
    private final RateLimiter limiter = new RateLimiter(3, PER, now::get);

    @Test
    void allowsTheConfiguredNumberOfRequestsAtOnce() {
        assertThat(limiter.tryAcquire("key").allowed()).isTrue();
        assertThat(limiter.tryAcquire("key").allowed()).isTrue();
        assertThat(limiter.tryAcquire("key").allowed()).isTrue();
        assertThat(limiter.tryAcquire("key").allowed()).isFalse();
        assertThat(limiter.tryAcquire("key").allowed()).isFalse();
    }

    @Test
    void countsEveryKeyOnItsOwn() {
        exhaust("key");

        assertThat(limiter.tryAcquire("other key").allowed()).isTrue();
    }

    @Test
    void tellsHowLongUntilTheNextRequestIsAllowed() {
        exhaust("key");

        // Three requests per 15 minutes refill one every 5 minutes.
        assertThat(limiter.tryAcquire("key").retryAfter()).isEqualTo(Duration.ofMinutes(5));

        now.updateAndGet(instant -> instant.plusSeconds(60));
        assertThat(limiter.tryAcquire("key").retryAfter()).isEqualTo(Duration.ofMinutes(4));
    }

    @Test
    void refillsEvenlyOverThePeriod() {
        exhaust("key");

        now.updateAndGet(instant -> instant.plus(Duration.ofMinutes(5)).minusSeconds(1));
        assertThat(limiter.tryAcquire("key").allowed()).isFalse();

        now.updateAndGet(instant -> instant.plusSeconds(1));
        assertThat(limiter.tryAcquire("key").allowed()).isTrue();
        assertThat(limiter.tryAcquire("key").allowed()).isFalse();

        now.updateAndGet(instant -> instant.plus(PER));
        exhaust("key");
    }

    @Test
    void anAllowedRequestHasNothingToWaitFor() {
        assertThat(limiter.tryAcquire("key").retryAfter()).isZero();
    }

    @Test
    void resetForgetsEarlierRequests() {
        exhaust("key");

        limiter.reset("key");

        assertThat(limiter.tryAcquire("key").allowed()).isTrue();
    }

    private void exhaust(String key) {
        for (int request = 0; request < 3; request++) {
            assertThat(limiter.tryAcquire(key).allowed()).isTrue();
        }
        assertThat(limiter.tryAcquire(key).allowed()).isFalse();
    }
}
