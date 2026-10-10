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
                    "shiftboard.security.login-rate-limit.window=15m");

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
    void bindsTheConfiguredLifetimes() {
        runner.withPropertyValues("shiftboard.security.jwt-secret=" + "x".repeat(32))
                .run(context -> {
                    var properties = context.getBean(SecurityProperties.class);
                    assertThat(properties.accessTokenTtl()).isEqualTo(Duration.ofMinutes(15));
                    assertThat(properties.refreshTokenTtl()).isEqualTo(Duration.ofDays(30));
                    assertThat(properties.loginRateLimit().maxAttempts()).isEqualTo(5);
                });
    }

    @Configuration(proxyBeanMethods = false)
    @EnableConfigurationProperties(SecurityProperties.class)
    static class PropertiesConfiguration {
    }
}
