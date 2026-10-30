package app.shiftboard.seed;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Duration;
import java.time.Instant;
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
                Map.entry("user_account", 18),
                Map.entry("worker", 12),
                Map.entry("worker_qualification", 15),
                Map.entry("client", 4),
                Map.entry("location", 5),
                Map.entry("shift", 11),
                Map.entry("shift_qualification", 10),
                Map.entry("shift_template", 5),
                Map.entry("shift_template_qualification", 5),
                Map.entry("assignment", 15),
                Map.entry("conversation", 2),
                Map.entry("message", 3),
                Map.entry("staff_request", 5)));
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
                        "Service Tagung", "Lagerunterstützung", "Service Hochzeit", "Barkeeper:in Hochzeit",
                        "Staplerfahrer:in", "Wareneingang", "Auf- und Abbau Messe", "Service Firmenfeier"))
                .jsonPath("$.content[1].client.name").isEqualTo("Nordlicht Logistik")
                .jsonPath("$.content[1].location.name").isEqualTo("Zentrallager Linz")
                .jsonPath("$.content[1].hourlyRateCents").isEqualTo(1650)
                .jsonPath("$.content[4].qualifications[*].name").isEqualTo(List.of("Lager", "Staplerschein"))
                .jsonPath("$.content[5].status").isEqualTo("CANCELLED")
                .jsonPath("$.content[7].status").isEqualTo("DRAFT");

        client.get().uri("/api/v1/clients")
                .headers(headers -> headers.setBearerAuth(login("dispatcher.alpen@example.com", "DASHBOARD")))
                .exchange()
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[*].name").isEqualTo(List.of("Gipfelarena"))
                .jsonPath("$.content[0].locations[*].name").isEqualTo(List.of("Haupteingang"));
    }

    @Test
    void theSeededHoursAreReadyToApproveAndExport() {
        var from = Instant.now().minus(Duration.ofDays(40));
        var to = Instant.now().plus(Duration.ofDays(1));
        client.get().uri("/api/v1/hours?from={from}&to={to}", from, to)
                .headers(headers -> headers.setBearerAuth(login("dispatcher1.donau@example.com", "DASHBOARD")))
                .exchange()
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalElements").isEqualTo(4)
                .jsonPath("$.content[*].shift.title").isEqualTo(List.of(
                        "Auf- und Abbau Messe", "Auf- und Abbau Messe", "Inventur", "Inventur"))
                .jsonPath("$.content[*].status").isEqualTo(List.of("APPROVED", "APPROVED", "APPROVED", "OPEN"))
                .jsonPath("$.content[2].worker.firstName").isEqualTo("Jakob")
                .jsonPath("$.content[2].checkedInAt").isNotEmpty()
                .jsonPath("$.content[2].hours.workedMinutes").isEqualTo(450)
                .jsonPath("$.content[3].worker.firstName").isEqualTo("Paul")
                .jsonPath("$.content[3].checkedOutAt").isNotEmpty()
                .jsonPath("$.content[3].hours").doesNotExist();

        // Lena can check in at the conference that starts shortly after seeding.
        var lena = login("lena.hofer@example.com", "WORKER_APP");
        client.get().uri("/api/v1/me")
                .headers(headers -> headers.setBearerAuth(lena))
                .exchange()
                .expectBody().jsonPath("$.agency.features.checkIn").isEqualTo(true);
        client.get().uri("/api/v1/worker/my-shifts")
                .headers(headers -> headers.setBearerAuth(lena))
                .exchange()
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[0].title").isEqualTo("Service Tagung")
                .jsonPath("$.content[0].assignment.status").isEqualTo("CONFIRMED")
                .jsonPath("$.content[0].assignment.checkInFrom").isNotEmpty();
    }

    @Test
    void theFullForkliftShiftHasAWaitlistWithTheDemoWorkerFirst() {
        var dispatcher = login("dispatcher1.donau@example.com", "DASHBOARD");
        client.get().uri("/api/v1/agency/settings")
                .headers(headers -> headers.setBearerAuth(dispatcher))
                .exchange()
                .expectStatus().isOk()
                .expectBody().jsonPath("$.waitlist").isEqualTo(true);
        client.get().uri("/api/v1/shifts")
                .headers(headers -> headers.setBearerAuth(dispatcher))
                .exchange()
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[4].title").isEqualTo("Staplerfahrer:in")
                .jsonPath("$.content[4].takenSlots").isEqualTo(2)
                .jsonPath("$.content[4].slots").isEqualTo(2)
                .jsonPath("$.content[4].waitingCount").isEqualTo(3);
        var forklift = jdbc.sql("select id from shift where title = 'Staplerfahrer:in'").query(String.class).single();
        client.get().uri("/api/v1/shifts/{id}/waitlist", forklift)
                .headers(headers -> headers.setBearerAuth(dispatcher))
                .exchange()
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[*].worker.firstName").isEqualTo(List.of("Lena", "Mira", "Sophie"))
                .jsonPath("$.content[*].position").isEqualTo(List.of(1, 2, 3));

        // Jakob can still drop out: the shift is more than the deadline of 24 hours away.
        var jakob = login("jakob.steiner@example.com", "WORKER_APP");
        client.get().uri("/api/v1/worker/shifts/{id}", forklift)
                .headers(headers -> headers.setBearerAuth(jakob))
                .exchange()
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.assignment.status").isEqualTo("CONFIRMED")
                .jsonPath("$.assignment.cancellableUntil").value(until ->
                        assertThat(Instant.parse((String) until)).isAfter(Instant.now()));
        var lena = login("lena.hofer@example.com", "WORKER_APP");
        client.get().uri("/api/v1/worker/my-shifts?includeWaitlist=true")
                .headers(headers -> headers.setBearerAuth(lena))
                .exchange()
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[?(@.title == 'Staplerfahrer:in')].waitlist.position").isEqualTo(List.of(1));
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

    @Test
    void theSeededClientUserSeesTheShiftsOfNordlichtLogistik() {
        var token = login("kunde.nordlicht@example.com", "DASHBOARD");
        client.get().uri("/api/v1/client/shifts")
                .headers(headers -> headers.setBearerAuth(token))
                .exchange()
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[*].title").isEqualTo(List.of("Lagerunterstützung", "Staplerfahrer:in", "Wareneingang"))
                .jsonPath("$.content[0].confirmedCount").isEqualTo(1)
                .jsonPath("$.content[1].confirmedCount").isEqualTo(2)
                .jsonPath("$.content[2].status").isEqualTo("CANCELLED");
        client.get().uri("/api/v1/client/shifts?period=PAST")
                .headers(headers -> headers.setBearerAuth(token))
                .exchange()
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[*].title").isEqualTo(List.of("Inventur"));
    }

    @Test
    void theSeededStaffRequestsShowEveryOutcome() {
        var clientToken = login("kunde.nordlicht@example.com", "DASHBOARD");
        client.get().uri("/api/v1/client/staff-requests")
                .headers(headers -> headers.setBearerAuth(clientToken))
                .exchange()
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[*].status").isEqualTo(List.of("OPEN", "OPEN", "DECLINED", "ACCEPTED", "WITHDRAWN"))
                .jsonPath("$.content[2].declineReason").isEqualTo("An diesem Wochenende sind wir leider ausgebucht.")
                .jsonPath("$.content[3].shiftId").isNotEmpty()
                .jsonPath("$.content[0].requestedBy").isEqualTo("Petra Wimmer");
        client.get().uri("/api/v1/staff-requests")
                .headers(headers -> headers.setBearerAuth(login("dispatcher1.donau@example.com", "DASHBOARD")))
                .exchange()
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalElements").isEqualTo(2)
                .jsonPath("$.content[*].role").isEqualTo(List.of("Kommissionierung", "Staplerfahrer:in"));
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
                "shift", "shift_qualification", "shift_template", "shift_template_qualification", "assignment", "conversation", "message",
                "staff_request")) {
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
