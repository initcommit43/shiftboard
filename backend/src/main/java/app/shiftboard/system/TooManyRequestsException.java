package app.shiftboard.system;

import java.time.Duration;

import org.springframework.http.HttpStatus;

/**
 * A request over a rate limit. It is answered with 429 and a {@code Retry-After} header.
 */
public class TooManyRequestsException extends ApiException {

    private final Duration retryAfter;

    public TooManyRequestsException(String code, String detail, Duration retryAfter) {
        super(HttpStatus.TOO_MANY_REQUESTS, code, detail);
        this.retryAfter = retryAfter;
    }

    /** Whole seconds until a request can succeed again, at least one. */
    public long retryAfterSeconds() {
        var seconds = retryAfter.toSeconds() + (retryAfter.toNanosPart() > 0 ? 1 : 0);
        return Math.max(1, seconds);
    }
}
