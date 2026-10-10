package app.shiftboard;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.regex.Pattern;

import app.shiftboard.identity.Role;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;

class ApplicationIntegrationTests extends IntegrationTest {

    private static final Pattern SPEC_VERSION = Pattern.compile("(?m)^  version: (\\S+)$");

    @Test
    void pingReportsTheContractVersion() throws IOException {
        client.get().uri("/api/v1/ping")
                .exchange()
                .expectStatus().isOk()
                .expectHeader().contentTypeCompatibleWith(MediaType.APPLICATION_JSON)
                .expectBody()
                .jsonPath("$.status").isEqualTo("ok")
                .jsonPath("$.version").isEqualTo(specVersion())
                .jsonPath("$.length()").isEqualTo(2);
    }

    @Test
    void unknownPathIsReportedAsProblemDetail() {
        var agency = data.agency("Donau Personal");
        var tokens = login(data.account(agency, Role.DISPATCHER), DASHBOARD);

        get("/api/v1/does-not-exist", tokens)
                .expectStatus().isNotFound()
                .expectHeader().contentTypeCompatibleWith(MediaType.APPLICATION_PROBLEM_JSON)
                .expectBody()
                .jsonPath("$.type").isEqualTo("about:blank")
                .jsonPath("$.title").isEqualTo("Not Found")
                .jsonPath("$.status").isEqualTo(404);
    }

    @Test
    void pathsNeedAuthenticationUnlessDeclaredPublic() {
        expectProblem(client.get().uri("/api/v1/does-not-exist").exchange(), 401, "unauthenticated");
    }

    @Test
    void flywayMigratesTheSchemaOnStartup() {
        var applied = jdbc.sql("select count(*) from flyway_schema_history where success").query(Integer.class).single();
        var publications = jdbc.sql("select count(*) from event_publication").query(Integer.class).single();

        assertThat(applied).isPositive();
        assertThat(publications).isZero();
    }

    @Test
    void healthIsTheOnlyExposedActuatorEndpoint() {
        var agency = data.agency("Donau Personal");
        var tokens = login(data.account(agency, Role.ADMIN), DASHBOARD);

        client.get().uri("/actuator/health")
                .exchange()
                .expectStatus().isOk()
                .expectBody().jsonPath("$.status").isEqualTo("UP");

        get("/actuator/info", tokens)
                .expectStatus().isNotFound();
    }

    private static String specVersion() throws IOException {
        var matcher = SPEC_VERSION.matcher(Files.readString(Path.of("../api/openapi.yaml")));
        assertThat(matcher.find()).as("info.version in api/openapi.yaml").isTrue();
        return matcher.group(1);
    }
}
