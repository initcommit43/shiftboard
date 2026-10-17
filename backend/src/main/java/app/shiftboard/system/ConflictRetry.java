package app.shiftboard.system;

import java.util.function.Supplier;

import org.springframework.dao.OptimisticLockingFailureException;
import org.springframework.http.HttpStatus;

/**
 * Repeats a change that lost against a concurrent change of the same row. Each attempt has to
 * run in a transaction of its own and read what it changes anew, so that it decides on the
 * current state.
 */
public final class ConflictRetry {

    /** Enough for the contention of a few people working on one shift at the same moment. */
    public static final int ATTEMPTS = 3;

    private ConflictRetry() {
    }

    /**
     * @param exhausted what to throw when every attempt lost
     */
    public static <T> T run(Supplier<T> attempt, Supplier<? extends RuntimeException> exhausted) {
        for (var i = 1; ; i++) {
            try {
                return attempt.get();
            } catch (OptimisticLockingFailureException e) {
                if (i == ATTEMPTS) {
                    var failure = exhausted.get();
                    failure.addSuppressed(e);
                    throw failure;
                }
            }
        }
    }

    /** The answer when a change kept losing against concurrent changes of the same shift. */
    public static ApiException busy() {
        return new ApiException(
                HttpStatus.CONFLICT, "concurrent_change",
                "The shift was changed at the same moment. Please try again.");
    }
}
