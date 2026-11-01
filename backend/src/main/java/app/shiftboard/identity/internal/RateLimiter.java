package app.shiftboard.identity.internal;

import java.time.Duration;
import java.time.Instant;
import java.time.InstantSource;
import java.time.temporal.ChronoUnit;

import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;
import io.github.bucket4j.Bandwidth;
import io.github.bucket4j.Bucket;
import io.github.bucket4j.TimeMeter;

/**
 * A token bucket per key: up to {@code requests} at once, refilled evenly over {@code per}.
 * The buckets live in memory, so a limit holds per application instance and is forgotten on
 * restart (ADR 0033). A bucket nobody used for {@code per} is full again and gets dropped.
 */
final class RateLimiter {

    private static final long MAX_KEYS = 100_000;

    private final Bandwidth limit;
    private final TimeMeter timeMeter;
    private final Cache<String, Bucket> buckets;

    RateLimiter(int requests, Duration per, InstantSource clock) {
        this.limit = Bandwidth.builder().capacity(requests).refillGreedy(requests, per).build();
        this.timeMeter = new ClockTimeMeter(clock);
        this.buckets = Caffeine.newBuilder()
                .maximumSize(MAX_KEYS)
                .expireAfterAccess(per)
                .ticker(timeMeter::currentTimeNanos)
                .build();
    }

    /** Counts a request against the key's limit. */
    Decision tryAcquire(String key) {
        var bucket = buckets.get(key, k -> Bucket.builder().addLimit(limit).withCustomTimePrecision(timeMeter).build());
        var probe = bucket.tryConsumeAndReturnRemaining(1);
        return probe.isConsumed()
                ? Decision.ALLOWED
                : new Decision(false, Duration.ofNanos(probe.getNanosToWaitForRefill()));
    }

    /** Forgets the requests counted for the key. */
    void reset(String key) {
        buckets.invalidate(key);
    }

    /**
     * @param retryAfter how long until the next request with the same key is allowed; zero if this one was
     */
    record Decision(boolean allowed, Duration retryAfter) {

        static final Decision ALLOWED = new Decision(true, Duration.ZERO);
    }

    private record ClockTimeMeter(InstantSource clock) implements TimeMeter {

        @Override
        public long currentTimeNanos() {
            return ChronoUnit.NANOS.between(Instant.EPOCH, clock.instant());
        }

        @Override
        public boolean isWallClockBased() {
            return true;
        }
    }
}
