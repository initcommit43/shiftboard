package app.shiftboard.agency;

import java.util.Optional;
import java.util.UUID;

/**
 * The agency the current thread works for. Hibernate filters every tenant-owned entity by it.
 * Without a bound agency no tenant-owned row is visible and none can be written.
 */
public final class TenantContext {

    private static final ThreadLocal<UUID> CURRENT = new ThreadLocal<>();

    private TenantContext() {
    }

    public static Optional<UUID> current() {
        return Optional.ofNullable(CURRENT.get());
    }

    public static UUID require() {
        return current().orElseThrow(() -> new IllegalStateException("No agency bound to the current thread"));
    }

    /**
     * Binds the agency until the returned scope is closed. Bind before the transaction starts:
     * a persistence context keeps the tenant it was opened with.
     */
    public static Scope bind(UUID agencyId) {
        var previous = CURRENT.get();
        CURRENT.set(agencyId);
        return () -> {
            if (previous == null) {
                CURRENT.remove();
            } else {
                CURRENT.set(previous);
            }
        };
    }

    public interface Scope extends AutoCloseable {

        @Override
        void close();
    }
}
