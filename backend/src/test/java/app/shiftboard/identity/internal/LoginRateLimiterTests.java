package app.shiftboard.identity.internal;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Duration;
import java.time.Instant;
import java.util.concurrent.atomic.AtomicReference;

import org.junit.jupiter.api.Test;

class LoginRateLimiterTests {

    private static final Duration WINDOW = Duration.ofMinutes(15);

    private final AtomicReference<Instant> now = new AtomicReference<>(Instant.parse("2026-10-10T08:00:00Z"));
    private final LoginRateLimiter limiter = new LoginRateLimiter(3, WINDOW, now::get);

    @Test
    void allowsTheConfiguredNumberOfAttemptsPerWindow() {
        assertThat(limiter.tryAcquire("key")).isTrue();
        assertThat(limiter.tryAcquire("key")).isTrue();
        assertThat(limiter.tryAcquire("key")).isTrue();
        assertThat(limiter.tryAcquire("key")).isFalse();
        assertThat(limiter.tryAcquire("key")).isFalse();
    }

    @Test
    void countsEveryKeyOnItsOwn() {
        exhaust("key");

        assertThat(limiter.tryAcquire("other key")).isTrue();
    }

    @Test
    void allowsAttemptsAgainOnceTheWindowHasEnded() {
        exhaust("key");

        now.updateAndGet(instant -> instant.plus(WINDOW).minusSeconds(1));
        assertThat(limiter.tryAcquire("key")).isFalse();

        now.updateAndGet(instant -> instant.plusSeconds(1));
        assertThat(limiter.tryAcquire("key")).isTrue();
    }

    @Test
    void resetForgetsEarlierAttempts() {
        exhaust("key");

        limiter.reset("key");

        assertThat(limiter.tryAcquire("key")).isTrue();
    }

    private void exhaust(String key) {
        for (int attempt = 0; attempt < 3; attempt++) {
            limiter.tryAcquire(key);
        }
        assertThat(limiter.tryAcquire(key)).isFalse();
    }
}
