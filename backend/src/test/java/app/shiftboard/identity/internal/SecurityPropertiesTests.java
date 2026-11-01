package app.shiftboard.identity.internal;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Duration;

import org.junit.jupiter.api.Test;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.test.context.runner.ApplicationContextRunner;
import org.springframework.context.annotation.Configuration;

class SecurityPropertiesTests {

    private final ApplicationContextRunner runner = new ApplicationContextRunner()
            .withUserConfiguration(PropertiesConfiguration.class)
            .withPropertyValues(
                    "shiftboard.security.access-token-ttl=15m",
                    "shiftboard.security.refresh-token-ttl=30d",
                    "shiftboard.security.login-rate-limit.max-attempts=5",
                    "shiftboard.security.login-rate-limit.window=15m",
                    "shiftboard.security.rate-limits.login.requests=20",
                    "shiftboard.security.rate-limits.login.per=15m",
                    "shiftboard.security.rate-limits.links.requests=30",
                    "shiftboard.security.rate-limits.links.per=15m",
                    "shiftboard.security.rate-limits.session.requests=60",
                    "shiftboard.security.rate-limits.session.per=15m",
                    "shiftboard.security.rate-limits.api.requests=300",
                    "shiftboard.security.rate-limits.api.per=1m");

    @Test
    void theApplicationDoesNotStartWithoutAJwtSecret() {
        runner.withPropertyValues("shiftboard.security.jwt-secret=")
                .run(context -> assertThat(context).hasFailed());
    }

    @Test
    void theApplicationDoesNotStartWithAJwtSecretThatIsTooShortForHs256() {
        runner.withPropertyValues("shiftboard.security.jwt-secret=" + "x".repeat(31))
                .run(context -> assertThat(context).hasFailed());
    }

    @Test
    void theApplicationDoesNotStartWithARateLimitOfZero() {
        runner.withPropertyValues(
                        "shiftboard.security.jwt-secret=" + "x".repeat(32),
                        "shiftboard.security.rate-limits.api.requests=0")
                .run(context -> assertThat(context).hasFailed());
    }

    @Test
    void bindsTheConfiguredLifetimes() {
        runner.withPropertyValues("shiftboard.security.jwt-secret=" + "x".repeat(32))
                .run(context -> {
                    var properties = context.getBean(SecurityProperties.class);
                    assertThat(properties.accessTokenTtl()).isEqualTo(Duration.ofMinutes(15));
                    assertThat(properties.refreshTokenTtl()).isEqualTo(Duration.ofDays(30));
                    assertThat(properties.loginRateLimit().maxAttempts()).isEqualTo(5);
                    assertThat(properties.rateLimits().api().requests()).isEqualTo(300);
                    assertThat(properties.rateLimits().api().per()).isEqualTo(Duration.ofMinutes(1));
                });
    }

    @Configuration(proxyBeanMethods = false)
    @EnableConfigurationProperties(SecurityProperties.class)
    static class PropertiesConfiguration {
    }
}
