package app.shiftboard.seed;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import app.shiftboard.TestcontainersConfiguration;
import app.shiftboard.identity.TokenPair;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureRestTestClient;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.client.RestTestClient;

/**
 * Starts the application the way a developer machine does: local profile, empty database.
 */
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@AutoConfigureRestTestClient
@Import(TestcontainersConfiguration.class)
@ActiveProfiles("local")
class SeedDataIntegrationTests {

    @Autowired
    SeedData seedData;

    @Autowired
    JdbcClient jdbc;

    @Autowired
    RestTestClient client;

    @Value("${shiftboard.seed.password}")
    String password;

    @Test
    void seedsTheDemoAgenciesOnStartup() {
        assertThat(rowCounts()).containsExactlyInAnyOrderEntriesOf(Map.ofEntries(
                Map.entry("agency", 2),
                Map.entry("qualification", 6),
                Map.entry("user_account", 16),
                Map.entry("worker", 12),
                Map.entry("worker_qualification", 15),
                Map.entry("client", 4),
                Map.entry("location", 5),
                Map.entry("shift", 8),
                Map.entry("shift_qualification", 8),
                Map.entry("shift_template", 5),
                Map.entry("shift_template_qualification", 5),
                Map.entry("assignment", 7),
                Map.entry("conversation", 2),
                Map.entry("message", 3)));
        assertThat(workersOfDonauPersonalWith("ACTIVE")).isEqualTo(6);
        assertThat(workersOfDonauPersonalWith("PENDING")).isEqualTo(4);
        assertThat(workersOfDonauPersonalWith("INACTIVE")).isEqualTo(1);
    }

    @Test
    void seedingAgainChangesNothing() {
        var before = rowCounts();

        seedData.run(null);

        assertThat(rowCounts()).isEqualTo(before);
    }

    @Test
    void usesOnlyFictionalContactData() {
        var emails = jdbc.sql("select email from user_account").query(String.class).list();
        var phones = jdbc.sql("""
                select phone from worker union all select phone from user_account where phone is not null
                """).query(String.class).list();

        assertThat(emails).allMatch(email -> email.endsWith("@example.com"));
        assertThat(phones).doesNotHaveDuplicates().allMatch(phone -> phone.matches("\\+43 660 55501\\d\\d"));
    }

    @Test
    void theDemoSignupCodeLeadsToDonauPersonal() {
        client.get().uri("/api/v1/signup/{code}", SeedData.DONAU_SIGNUP_CODE)
                .exchange()
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.agencyName").isEqualTo("Donau Personal");
    }

    @Test
    void theSeededDispatchersSeeTheSignupsOfTheirOwnAgency() {
        client.get().uri("/api/v1/workers?status=PENDING")
                .headers(headers -> headers.setBearerAuth(login("dispatcher1.donau@example.com", "DASHBOARD")))
                .exchange()
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[*].lastName").isEqualTo(List.of("Koller", "Reiter", "Hauser", "Pichler"))
                .jsonPath("$.content[1].qualifications[*].name").isEqualTo(List.of("Lager", "Staplerschein"));

        client.get().uri("/api/v1/workers")
                .headers(headers -> headers.setBearerAuth(login("dispatcher.alpen@example.com", "DASHBOARD")))
                .exchange()
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[*].email").isEqualTo(List.of("tobias.gruber@example.com"));
    }

    @Test
    void theSeededDispatchersSeeTheUpcomingShiftsOfTheirOwnAgency() {
        client.get().uri("/api/v1/shifts")
                .headers(headers -> headers.setBearerAuth(login("dispatcher1.donau@example.com", "DASHBOARD")))
                .exchange()
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[*].title").isEqualTo(List.of(
                        "Lagerunterstützung", "Service Hochzeit", "Barkeeper:in Hochzeit", "Staplerfahrer:in",
                        "Auf- und Abbau Messe", "Service Firmenfeier"))
                .jsonPath("$.content[0].client.name").isEqualTo("Nordlicht Logistik")
                .jsonPath("$.content[0].location.name").isEqualTo("Zentrallager Linz")
                .jsonPath("$.content[0].hourlyRateCents").isEqualTo(1650)
                .jsonPath("$.content[3].qualifications[*].name").isEqualTo(List.of("Lager", "Staplerschein"))
                .jsonPath("$.content[5].status").isEqualTo("DRAFT");

        client.get().uri("/api/v1/clients")
                .headers(headers -> headers.setBearerAuth(login("dispatcher.alpen@example.com", "DASHBOARD")))
                .exchange()
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[*].name").isEqualTo(List.of("Gipfelarena"))
                .jsonPath("$.content[0].locations[*].name").isEqualTo(List.of("Haupteingang"));
    }

    @Test
    void theSeededDispatchersSeeTheTemplatesOfTheirOwnAgency() {
        client.get().uri("/api/v1/shift-templates")
                .headers(headers -> headers.setBearerAuth(login("dispatcher2.donau@example.com", "DASHBOARD")))
                .exchange()
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[*].name").isEqualTo(List.of(
                        "Bankett Abend", "Lager Frühschicht", "Messe Nachtabbau", "Stapler Wels"))
                // Runs past midnight.
                .jsonPath("$.content[2].startTime").isEqualTo("22:00")
                .jsonPath("$.content[2].durationMinutes").isEqualTo(480)
                .jsonPath("$.content[3].qualificationIds.length()").isEqualTo(2);

        client.get().uri("/api/v1/shift-templates")
                .headers(headers -> headers.setBearerAuth(login("dispatcher.alpen@example.com", "DASHBOARD")))
                .exchange()
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[*].name").isEqualTo(List.of("Einlass Konzert"));
    }

    @Test
    void theSeededAdminAndWorkersCanLogIn() {
        assertThat(login("admin.donau@example.com", "DASHBOARD")).isNotBlank();
        assertThat(login("lena.hofer@example.com", "WORKER_APP")).isNotBlank();
    }

    private String login(String email, String clientType) {
        return client.post().uri("/api/v1/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of("email", email, "password", password, "client", clientType))
                .exchange()
                .expectStatus().isOk()
                .expectBody(TokenPair.class).returnResult().getResponseBody()
                .accessToken();
    }

    private Map<String, Integer> rowCounts() {
        var counts = new LinkedHashMap<String, Integer>();
        for (var table : List.of(
                "agency", "qualification", "user_account", "worker", "worker_qualification", "client", "location",
                "shift", "shift_qualification", "shift_template", "shift_template_qualification", "assignment", "conversation", "message")) {
            counts.put(table, jdbc.sql("select count(*) from " + table).query(Integer.class).single());
        }
        return counts;
    }

    private int workersOfDonauPersonalWith(String status) {
        return jdbc.sql("""
                select count(*) from worker w join agency a on a.id = w.agency_id
                where a.signup_code = ? and w.status = ?
                """).params(SeedData.DONAU_SIGNUP_CODE, status).query(Integer.class).single();
    }
}
