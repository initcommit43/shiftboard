package app.shiftboard.system;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatIllegalStateException;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.springframework.boot.test.context.runner.ApplicationContextRunner;

class LocalProfileGuardTests {

    private final ApplicationContextRunner runner = new ApplicationContextRunner()
            .withUserConfiguration(LocalProfileGuard.class);

    @Test
    void theApplicationDoesNotStartWithTheLocalProfileAgainstAnotherMachine() {
        runner.withPropertyValues(
                        "spring.profiles.active=local",
                        "spring.datasource.url=jdbc:postgresql://db.example.com:5432/shiftboard")
                .run(context -> assertThat(context).getFailure()
                        .hasMessageContaining("local profile")
                        .hasMessageContaining("db.example.com"));
    }

    @Test
    void theApplicationStartsWithTheLocalProfileAgainstThisMachine() {
        runner.withPropertyValues(
                        "spring.profiles.active=local",
                        "spring.datasource.url=jdbc:postgresql://localhost:5432/shiftboard")
                .run(context -> assertThat(context).hasNotFailed());
    }

    @Test
    void otherProfilesAreNotChecked() {
        runner.withPropertyValues("spring.datasource.url=jdbc:postgresql://db.example.com:5432/shiftboard")
                .run(context -> assertThat(context).hasNotFailed().doesNotHaveBean(LocalProfileGuard.class));
    }

    @ParameterizedTest
    @ValueSource(strings = {
            "jdbc:postgresql://localhost:5432/shiftboard",
            "jdbc:postgresql://LOCALHOST/shiftboard",
            "jdbc:postgresql://127.0.0.1:5432/shiftboard",
            "jdbc:postgresql://127.0.0.53:32768/test?loggerLevel=OFF",
            "jdbc:postgresql://[::1]:5432/shiftboard",
            "jdbc:postgresql://host.docker.internal:5432/shiftboard",
            // The service name in docker-compose.yml.
            "jdbc:postgresql://db:5432/shiftboard",
    })
    void acceptsADatabaseOnTheDeveloperMachine(String jdbcUrl) {
        assertThatCode(() -> LocalProfileGuard.check(jdbcUrl)).doesNotThrowAnyException();
    }

    @ParameterizedTest
    @ValueSource(strings = {
            "jdbc:postgresql://db.example.com:5432/shiftboard",
            "jdbc:postgresql://shiftboard.internal/shiftboard",
            "jdbc:postgresql://203.0.113.7:5432/shiftboard",
            "jdbc:postgresql://10.0.0.5:5432/shiftboard",
            "jdbc:postgresql://[2001:db8::1]:5432/shiftboard",
            "jdbc:postgresql://localhost.example.com/shiftboard",
            // Several hosts cannot be told apart, and neither can a URL without one.
            "jdbc:postgresql://localhost:5432,db.example.com:5432/shiftboard",
            "jdbc:postgresql:shiftboard",
            "not a url",
    })
    void refusesADatabaseSomewhereElse(String jdbcUrl) {
        assertThatIllegalStateException()
                .isThrownBy(() -> LocalProfileGuard.check(jdbcUrl))
                .withMessageContaining("local profile");
    }
}
