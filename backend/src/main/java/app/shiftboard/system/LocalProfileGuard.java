package app.shiftboard.system;

import java.net.InetAddress;
import java.net.URI;
import java.net.UnknownHostException;
import java.util.regex.Pattern;

import org.springframework.beans.factory.config.BeanFactoryPostProcessor;
import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.context.EnvironmentAware;
import org.springframework.context.annotation.Profile;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

/**
 * Stops the application when the {@code local} profile is active against a database that is not
 * on the developer machine. The profile brings a published JWT secret and demo accounts with a
 * published password, so on a deployed instance it would open the API to everyone.
 *
 * <p>A bean factory post processor runs before any other bean is created, so the application
 * stops before it connects to that database: nothing is migrated and nothing is seeded.
 */
@Component
@Profile("local")
class LocalProfileGuard implements BeanFactoryPostProcessor, EnvironmentAware {

    private static final Pattern IP_LITERAL = Pattern.compile("[0-9.]+|[0-9a-fA-F:.]*:[0-9a-fA-F:.]*");

    private Environment environment;

    @Override
    public void setEnvironment(Environment environment) {
        this.environment = environment;
    }

    @Override
    public void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) {
        check(environment.getRequiredProperty("spring.datasource.url"));
    }

    static void check(String jdbcUrl) {
        var host = host(jdbcUrl);
        if (host == null || !isLocal(host)) {
            throw new IllegalStateException(
                    "The local profile is for development machines only, but the database is at "
                            + (host == null ? jdbcUrl : host)
                            + ". Start without SPRING_PROFILES_ACTIVE=local and set JWT_SECRET.");
        }
    }

    /**
     * A database on this machine: localhost, a loopback address, or a name without a dot, which
     * is how docker compose services reach each other. Anything else, such as a hosted database
     * or an address in a private network, is somewhere else.
     */
    static boolean isLocal(String host) {
        if (host.equalsIgnoreCase("localhost") || host.equalsIgnoreCase("host.docker.internal")) {
            return true;
        }
        if (IP_LITERAL.matcher(host).matches()) {
            try {
                // No name lookup happens for an address literal.
                return InetAddress.getByName(host).isLoopbackAddress();
            } catch (UnknownHostException invalid) {
                return false;
            }
        }
        return !host.contains(".");
    }

    private static String host(String jdbcUrl) {
        try {
            var host = URI.create(jdbcUrl.substring("jdbc:".length())).getHost();
            return host == null ? null : host.replaceAll("^\\[|]$", "");
        } catch (RuntimeException unparsable) {
            return null;
        }
    }
}
