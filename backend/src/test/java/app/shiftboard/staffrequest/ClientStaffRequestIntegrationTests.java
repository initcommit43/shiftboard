package app.shiftboard.staffrequest;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Duration;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import app.shiftboard.IntegrationTest;
import app.shiftboard.TestData;
import app.shiftboard.identity.Role;
import app.shiftboard.identity.TokenPair;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;

@SuppressWarnings("unchecked")
class ClientStaffRequestIntegrationTests extends IntegrationTest {

    static final Instant IN_TWO_DAYS = Instant.now().plus(Duration.ofDays(2)).truncatedTo(ChronoUnit.SECONDS);

    TestData.Agency agency;

    TokenPair dispatcher;

    UUID clientId;

    UUID locationId;

    UUID otherClientId;

    UUID otherLocationId;

    TokenPair clientUser;

    @BeforeEach
    void createAgency() {
        agency = data.agency("Donau Personal");
        var admin = login(data.account(agency, Role.ADMIN), DASHBOARD);
        dispatcher = login(data.account(agency, Role.DISPATCHER), DASHBOARD);
        clientId = data.client(agency, "Nordlicht Logistik");
        locationId = data.location(agency, clientId, "Zentrallager Linz", "Hafenstraße 12, 4020 Linz");
        otherClientId = data.client(agency, "Hafen Events");
        otherLocationId = data.location(agency, otherClientId, "Messehalle", "Messeplatz 1, 4020 Linz");
        switchPortalOn(admin);
        clientUser = clientUser(dispatcher, clientId, "Petra", "Wimmer");
    }

    @Test
    void aClientSendsARequestAndSeesItAsOpen() {
        var request = request(locationId, IN_TWO_DAYS, 4);
        request.put("endIsEstimate", true);
        request.put("notes", "  Rampe 3, bitte Sicherheitsschuhe.  ");

        var created = post("/api/v1/client/staff-requests", clientUser, request)
                .expectStatus().isCreated()
                .expectBody(Map.class).returnResult().getResponseBody();

        assertThat(created.get("status")).isEqualTo("OPEN");
        assertThat(created.get("role")).isEqualTo("Lagerhelfer");
        assertThat(created.get("workerCount")).isEqualTo(4);
        assertThat(created.get("endIsEstimate")).isEqualTo(true);
        assertThat(created.get("notes")).isEqualTo("Rampe 3, bitte Sicherheitsschuhe.");
        assertThat(created.get("requestedBy")).isEqualTo("Petra Wimmer");
        assertThat(Instant.parse((String) created.get("startsAt"))).isEqualTo(IN_TWO_DAYS);
        assertThat(((Map<?, ?>) created.get("client")).get("name")).isEqualTo("Nordlicht Logistik");
        assertThat(((Map<?, ?>) created.get("location")).get("name")).isEqualTo("Zentrallager Linz");
        assertThat((Map<String, Object>) created).doesNotContainKeys("decidedAt", "declineReason", "shiftId");

        get("/api/v1/client/staff-requests", clientUser)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalElements").isEqualTo(1)
                .jsonPath("$.content[0].id").isEqualTo(created.get("id"))
                .jsonPath("$.content[0].status").isEqualTo("OPEN")
                .jsonPath("$.content[0].notes").isEqualTo("Rampe 3, bitte Sicherheitsschuhe.");
    }

    @Test
    void notesAreEmptyWhenTheClientWroteNothing() {
        var created = send(request(locationId, IN_TWO_DAYS, 1));

        assertThat(created.get("notes")).isEqualTo("");
        assertThat(created.get("endIsEstimate")).isEqualTo(false);
    }

    @Test
    void invalidRequestsNameTheField() {
        expectFieldError(request(locationId, Instant.now().minus(Duration.ofHours(1)), 2), "startsAt", "in_past");

        var endBeforeStart = request(locationId, IN_TWO_DAYS, 2);
        endBeforeStart.put("endsAt", IN_TWO_DAYS.minus(Duration.ofHours(1)).toString());
        expectFieldError(endBeforeStart, "endsAt", "before_start");

        expectFieldError(request(otherLocationId, IN_TWO_DAYS, 2), "locationId", "not_found");
        expectFieldError(request(UUID.randomUUID(), IN_TWO_DAYS, 2), "locationId", "not_found");
        expectFieldError(request(locationId, IN_TWO_DAYS, 0), "workerCount", "out_of_range");
        expectFieldError(request(locationId, IN_TWO_DAYS, 501), "workerCount", "out_of_range");

        var noRole = request(locationId, IN_TWO_DAYS, 2);
        noRole.put("role", " ");
        expectFieldError(noRole, "role", "required");
    }

    @Test
    void aClientSeesOnlyItsOwnRequestsNewestFirst() {
        var first = send(request(locationId, IN_TWO_DAYS, 1));
        var colleague = clientUser(dispatcher, clientId, "Karl", "Huber");
        var second = post("/api/v1/client/staff-requests", colleague, request(locationId, IN_TWO_DAYS, 2))
                .expectStatus().isCreated()
                .expectBody(Map.class).returnResult().getResponseBody();
        var otherUser = clientUser(dispatcher, otherClientId, "Eva", "Gruber");
        post("/api/v1/client/staff-requests", otherUser, request(otherLocationId, IN_TWO_DAYS, 5))
                .expectStatus().isCreated();

        get("/api/v1/client/staff-requests", clientUser)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalElements").isEqualTo(2)
                .jsonPath("$.content[0].id").isEqualTo(second.get("id"))
                .jsonPath("$.content[0].requestedBy").isEqualTo("Karl Huber")
                .jsonPath("$.content[1].id").isEqualTo(first.get("id"));
        get("/api/v1/client/staff-requests", otherUser)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalElements").isEqualTo(1)
                .jsonPath("$.content[0].workerCount").isEqualTo(5);
    }

    @Test
    void aClientWithdrawsAnOpenRequestOnce() {
        var created = send(request(locationId, IN_TWO_DAYS, 3));
        var id = created.get("id");

        var withdrawn = post("/api/v1/client/staff-requests/" + id + "/withdraw", clientUser)
                .expectStatus().isOk()
                .expectBody(Map.class).returnResult().getResponseBody();

        assertThat(withdrawn.get("status")).isEqualTo("WITHDRAWN");
        assertThat(withdrawn.get("decidedAt")).isNotNull();
        expectProblem(post("/api/v1/client/staff-requests/" + id + "/withdraw", clientUser), 409,
                "staff_request_not_open");
    }

    @Test
    void anotherClientCannotWithdrawTheRequest() {
        var id = send(request(locationId, IN_TWO_DAYS, 3)).get("id");
        var otherUser = clientUser(dispatcher, otherClientId, "Eva", "Gruber");

        expectProblem(post("/api/v1/client/staff-requests/" + id + "/withdraw", otherUser), 404,
                "staff_request_not_found");
        expectProblem(post("/api/v1/client/staff-requests/" + UUID.randomUUID() + "/withdraw", clientUser), 404,
                "staff_request_not_found");
        get("/api/v1/client/staff-requests", clientUser)
                .expectStatus().isOk()
                .expectBody().jsonPath("$.content[0].status").isEqualTo("OPEN");
    }

    @Test
    void aClientSeesWhyARequestWasDeclined() {
        var id = send(request(locationId, IN_TWO_DAYS, 3)).get("id");
        jdbc.sql("""
                update staff_request set status = 'DECLINED', decline_reason = 'Am Wochenende ausgebucht.',
                decided_at = now() where id = ?
                """).param(UUID.fromString((String) id)).update();

        get("/api/v1/client/staff-requests", clientUser)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[0].status").isEqualTo("DECLINED")
                .jsonPath("$.content[0].declineReason").isEqualTo("Am Wochenende ausgebucht.");
        expectProblem(post("/api/v1/client/staff-requests/" + id + "/withdraw", clientUser), 409,
                "staff_request_not_open");
    }

    @Test
    void anotherAgencysClientUserSeesNone() {
        send(request(locationId, IN_TWO_DAYS, 3));
        var otherAgency = data.agency("Inn Staffing");
        var otherAdmin = login(data.account(otherAgency, Role.ADMIN), DASHBOARD);
        switchPortalOn(otherAdmin);
        var innClient = data.client(otherAgency, "Nordlicht Logistik");
        var innUser = clientUser(otherAdmin, innClient, "Petra", "Wimmer");

        get("/api/v1/client/staff-requests", innUser)
                .expectStatus().isOk()
                .expectBody().jsonPath("$.totalElements").isEqualTo(0);
    }

    @Test
    void staffCannotUseTheClientEndpoints() {
        expectProblem(get("/api/v1/client/staff-requests", dispatcher), 403, "forbidden");
        expectProblem(post("/api/v1/client/staff-requests", dispatcher, request(locationId, IN_TWO_DAYS, 1)), 403,
                "forbidden");
    }

    // --- helpers -------------------------------------------------------------------------

    private Map<String, Object> send(Map<String, Object> request) {
        return post("/api/v1/client/staff-requests", clientUser, request)
                .expectStatus().isCreated()
                .expectBody(Map.class).returnResult().getResponseBody();
    }

    private void expectFieldError(Map<String, Object> request, String field, String code) {
        expectProblem(post("/api/v1/client/staff-requests", clientUser, request), 400, "validation_failed")
                .jsonPath("$.errors[0].field").isEqualTo(field)
                .jsonPath("$.errors[0].code").isEqualTo(code);
    }

    private static Map<String, Object> request(UUID atLocation, Instant startsAt, int workerCount) {
        var request = new HashMap<String, Object>();
        request.put("locationId", atLocation);
        request.put("role", "Lagerhelfer");
        request.put("startsAt", startsAt.toString());
        request.put("endsAt", startsAt.plus(Duration.ofHours(8)).toString());
        request.put("workerCount", workerCount);
        return request;
    }

    private void switchPortalOn(TokenPair admin) {
        client.put().uri("/api/v1/agency/features")
                .headers(headers -> headers.setBearerAuth(admin.accessToken()))
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of("contactButton", false, "clientPortal", true))
                .exchange()
                .expectStatus().isOk();
    }

    private TokenPair clientUser(TokenPair staff, UUID forClient, String firstName, String lastName) {
        var invitation = post("/api/v1/clients/" + forClient + "/users", staff,
                Map.of("firstName", firstName, "lastName", lastName, "email", TestData.email()))
                .expectStatus().isCreated()
                .expectBody(Map.class).returnResult().getResponseBody();
        return client.post().uri("/api/v1/client-setup/{code}", invitation.get("setupCode"))
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of("password", "lagerhalle-2026"))
                .exchange()
                .expectStatus().isOk()
                .expectBody(TokenPair.class).returnResult().getResponseBody();
    }
}
