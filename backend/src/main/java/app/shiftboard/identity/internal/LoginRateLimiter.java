package app.shiftboard.identity.internal;

import java.time.Duration;
import java.time.Instant;
import java.time.InstantSource;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * Fixed-window limit on login attempts per key. The counters live in memory, so the limit
 * holds per application instance and is forgotten on restart.
 */
@Component
class LoginRateLimiter {

    private static final int PURGE_THRESHOLD = 10_000;

    private final int maxAttempts;
    private final Duration window;
    private final InstantSource clock;
    private final ConcurrentHashMap<String, Attempts> attempts = new ConcurrentHashMap<>();

    @Autowired
    LoginRateLimiter(SecurityProperties properties) {
        this(properties.loginRateLimit().maxAttempts(), properties.loginRateLimit().window(), InstantSource.system());
    }

    LoginRateLimiter(int maxAttempts, Duration window, InstantSource clock) {
        this.maxAttempts = maxAttempts;
        this.window = window;
        this.clock = clock;
    }

    /** Counts an attempt and tells whether it is still within the limit. */
    boolean tryAcquire(String key) {
        var now = clock.instant();
        if (attempts.size() > PURGE_THRESHOLD) {
            attempts.values().removeIf(counted -> counted.hasEnded(now));
        }
        var counted = attempts.compute(key, (k, current) -> current == null || current.hasEnded(now)
                ? new Attempts(1, now.plus(window))
                : new Attempts(current.count() + 1, current.windowEnd()));
        return counted.count() <= maxAttempts;
    }

    void reset(String key) {
        attempts.remove(key);
    }

    private record Attempts(int count, Instant windowEnd) {

        boolean hasEnded(Instant now) {
            return !now.isBefore(windowEnd);
        }
    }
}
