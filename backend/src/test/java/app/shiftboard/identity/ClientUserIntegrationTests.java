package app.shiftboard.identity;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.Map;
import java.util.UUID;

import app.shiftboard.IntegrationTest;
import app.shiftboard.TestData;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.client.RestTestClient;

class ClientUserIntegrationTests extends IntegrationTest {

    static final String NEW_PASSWORD = "lagerhalle-2026";

    TestData.Agency agency;

    TokenPair admin;

    TokenPair dispatcher;

    UUID clientId;

    @BeforeEach
    void createAgency() {
        agency = data.agency("Donau Personal");
        admin = login(data.account(agency, Role.ADMIN), DASHBOARD);
        dispatcher = login(data.account(agency, Role.DISPATCHER), DASHBOARD);
        clientId = data.client(agency, "Nordlicht Logistik");
        switchPortal(true);
    }

    @Test
    void anInvitedClientUserSetsAPasswordAndLogsInToTheirPortal() {
        var email = TestData.email();
        var invitation = invite("Petra", "Wimmer", email);
        var user = (Map<?, ?>) invitation.get("user");
        assertThat(user.get("status")).isEqualTo("INVITED");
        assertThat(user.get("email")).isEqualTo(email);
        assertThat((String) invitation.get("expiresAt")).isNotBlank();
        var code = (String) invitation.get("setupCode");

        // Without a password, nobody can log in yet.
        expectProblem(postLogin(email, "", DASHBOARD), 400, "validation_failed");

        client.get().uri("/api/v1/client-setup/{code}", code).exchange()
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.firstName").isEqualTo("Petra")
                .jsonPath("$.email").isEqualTo(email)
                .jsonPath("$.clientName").isEqualTo("Nordlicht Logistik")
                .jsonPath("$.agencyName").isEqualTo("Donau Personal");

        expectProblem(completeSetup(code, "kurz"), 400, "validation_failed");
        var tokens = completeSetup(code, NEW_PASSWORD)
                .expectStatus().isOk()
                .expectBody(TokenPair.class).returnResult().getResponseBody();

        get("/api/v1/me", tokens).expectStatus().isOk()
                .expectBody()
                .jsonPath("$.role").isEqualTo("CLIENT")
                .jsonPath("$.client.id").isEqualTo(clientId.toString())
                .jsonPath("$.client.name").isEqualTo("Nordlicht Logistik")
                .jsonPath("$.worker").doesNotExist();

        // The code worked once.
        expectProblem(completeSetup(code, NEW_PASSWORD), 404, "setup_code_invalid");
        expectProblem(client.get().uri("/api/v1/client-setup/{code}", code).exchange(), 404, "setup_code_invalid");

        // From now on the user logs in to the dashboard, not the worker app.
        postLogin(email, NEW_PASSWORD, DASHBOARD).expectStatus().isOk();
        expectProblem(postLogin(email, NEW_PASSWORD, WORKER_APP), 403, "wrong_client");

        var users = get("/api/v1/clients/" + clientId + "/users", dispatcher)
                .expectStatus().isOk()
                .expectBody(Map[].class).returnResult().getResponseBody();
        assertThat(users).singleElement().satisfies(listed -> assertThat(listed.get("status")).isEqualTo("ACTIVE"));
    }

    @Test
    void aNewSetupLinkReplacesTheOldOneAndExpiredLinksStopWorking() {
        var invitation = invite("Petra", "Wimmer", TestData.email());
        var userId = ((Map<?, ?>) invitation.get("user")).get("id");
        var first = (String) invitation.get("setupCode");

        var renewed = post("/api/v1/clients/" + clientId + "/users/" + userId + "/setup-link", dispatcher)
                .expectStatus().isOk()
                .expectBody(Map.class).returnResult().getResponseBody();
        var second = (String) renewed.get("setupCode");
        assertThat(second).isNotEqualTo(first);
        expectProblem(completeSetup(first, NEW_PASSWORD), 404, "setup_code_invalid");

        jdbc.sql("update client_setup_code set expires_at = now() - interval '1 minute' where used_at is null").update();
        expectProblem(completeSetup(second, NEW_PASSWORD), 404, "setup_code_invalid");

        var third = (String) post("/api/v1/clients/" + clientId + "/users/" + userId + "/setup-link", dispatcher)
                .expectStatus().isOk()
                .expectBody(Map.class).returnResult().getResponseBody().get("setupCode");
        completeSetup(third, NEW_PASSWORD).expectStatus().isOk();

        // Once the password is set there is nothing to renew.
        expectProblem(post("/api/v1/clients/" + clientId + "/users/" + userId + "/setup-link", dispatcher),
                409, "client_user_not_invited");
    }

    @Test
    void deactivatingEndsLoginsSessionsAndOpenLinks() {
        var email = TestData.email();
        var active = invite("Petra", "Wimmer", email);
        var tokens = completeSetup((String) active.get("setupCode"), NEW_PASSWORD)
                .expectStatus().isOk()
                .expectBody(TokenPair.class).returnResult().getResponseBody();
        var invited = invite("Karl", "Huber", TestData.email());

        for (var invitation : new Map<?, ?>[] {active, invited}) {
            var userId = ((Map<?, ?>) invitation.get("user")).get("id");
            post("/api/v1/clients/" + clientId + "/users/" + userId + "/deactivate", dispatcher)
                    .expectStatus().isOk()
                    .expectBody().jsonPath("$.status").isEqualTo("DEACTIVATED");
            // Twice changes nothing.
            post("/api/v1/clients/" + clientId + "/users/" + userId + "/deactivate", dispatcher)
                    .expectStatus().isOk();
        }

        expectProblem(postLogin(email, NEW_PASSWORD, DASHBOARD), 403, "account_deactivated");
        expectProblem(postRefreshToken("/api/v1/auth/refresh", tokens.refreshToken()), 401, "invalid_refresh_token");
        expectProblem(completeSetup((String) invited.get("setupCode"), NEW_PASSWORD), 404, "setup_code_invalid");
    }

    @Test
    void theSwitchedOffPortalLetsNobodyIn() {
        var email = TestData.email();
        var invitation = invite("Petra", "Wimmer", email);
        var tokens = completeSetup((String) invitation.get("setupCode"), NEW_PASSWORD)
                .expectStatus().isOk()
                .expectBody(TokenPair.class).returnResult().getResponseBody();
        var pending = invite("Karl", "Huber", TestData.email());

        switchPortal(false);

        expectProblem(postLogin(email, NEW_PASSWORD, DASHBOARD), 403, "client_portal_off");
        expectProblem(postRefreshToken("/api/v1/auth/refresh", tokens.refreshToken()), 403, "client_portal_off");
        expectProblem(client.get().uri("/api/v1/client-setup/{code}", pending.get("setupCode")).exchange(),
                403, "client_portal_off");
        expectProblem(post("/api/v1/clients/" + clientId + "/users", dispatcher,
                Map.of("firstName", "Eva", "lastName", "Moser", "email", TestData.email())), 403, "client_portal_off");
        // The agency still sees who had access.
        get("/api/v1/clients/" + clientId + "/users", dispatcher).expectStatus().isOk();
        // Staff log in as before.
        postLogin(data.account(agency, Role.DISPATCHER), TestData.PASSWORD, DASHBOARD).expectStatus().isOk();
    }

    @Test
    void invitationsAreCheckedAndStayWithinTheAgency() {
        var email = TestData.email();
        invite("Petra", "Wimmer", email);
        expectProblem(post("/api/v1/clients/" + clientId + "/users", dispatcher,
                Map.of("firstName", "Petra", "lastName", "Wimmer", "email", email.toUpperCase())),
                409, "email_already_registered");
        expectProblem(post("/api/v1/clients/" + clientId + "/users", dispatcher,
                Map.of("firstName", " ", "lastName", "Wimmer", "email", "keine-adresse")), 400, "validation_failed");
        expectProblem(post("/api/v1/clients/" + UUID.randomUUID() + "/users", dispatcher,
                Map.of("firstName", "Eva", "lastName", "Moser", "email", TestData.email())), 404, "client_not_found");

        var other = data.agency("Inn Staffing");
        var otherDispatcher = login(data.account(other, Role.DISPATCHER), DASHBOARD);
        var invitation = invite("Karl", "Huber", TestData.email());
        var userId = ((Map<?, ?>) invitation.get("user")).get("id");
        expectProblem(get("/api/v1/clients/" + clientId + "/users", otherDispatcher), 404, "client_not_found");
        expectProblem(post("/api/v1/clients/" + clientId + "/users/" + userId + "/deactivate", otherDispatcher),
                404, "client_user_not_found");
        // A client id that isn't the user's doesn't find them either.
        var otherClient = data.client(agency, "Hafen Events");
        expectProblem(post("/api/v1/clients/" + otherClient + "/users/" + userId + "/deactivate", dispatcher),
                404, "client_user_not_found");
    }

    @Test
    void clientUsersReachNothingOfTheAgencyOrItsWorkers() {
        var invitation = invite("Petra", "Wimmer", TestData.email());
        var tokens = completeSetup((String) invitation.get("setupCode"), NEW_PASSWORD)
                .expectStatus().isOk()
                .expectBody(TokenPair.class).returnResult().getResponseBody();

        for (var uri : new String[] {
                "/api/v1/shifts", "/api/v1/clients", "/api/v1/workers", "/api/v1/conversations",
                "/api/v1/hours", "/api/v1/agency/features", "/api/v1/agency/settings", "/api/v1/worker/shifts",
                "/api/v1/worker/conversation", "/api/v1/clients/" + clientId + "/users"}) {
            expectProblem(get(uri, tokens), 403, "forbidden");
        }
        var worker = signUp(agency.signupCode(), TestData.email());
        expectProblem(get("/api/v1/client/shifts", worker), 403, "forbidden");
        expectProblem(get("/api/v1/client/shifts", dispatcher), 403, "forbidden");
    }

    @Test
    void onlyAdminsSwitchThePortal() {
        expectProblem(put("/api/v1/agency/features", dispatcher, Map.of("contactButton", false, "clientPortal", false)),
                403, "forbidden");
        // Absent from a request, the portal stays as it is.
        put("/api/v1/agency/features", admin, Map.of("contactButton", true))
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.contactButton").isEqualTo(true)
                .jsonPath("$.clientPortal").isEqualTo(true);
        get("/api/v1/agency/features", dispatcher).expectStatus().isOk()
                .expectBody().jsonPath("$.clientPortal").isEqualTo(true);
    }

    // --- helpers -------------------------------------------------------------------------

    private void switchPortal(boolean on) {
        put("/api/v1/agency/features", admin, Map.of("contactButton", false, "clientPortal", on))
                .expectStatus().isOk()
                .expectBody().jsonPath("$.clientPortal").isEqualTo(on);
    }

    private Map<?, ?> invite(String firstName, String lastName, String email) {
        return post("/api/v1/clients/" + clientId + "/users", dispatcher,
                Map.of("firstName", firstName, "lastName", lastName, "email", email))
                .expectStatus().isCreated()
                .expectBody(Map.class).returnResult().getResponseBody();
    }

    private RestTestClient.ResponseSpec completeSetup(String code, String password) {
        return client.post().uri("/api/v1/client-setup/{code}", code)
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of("password", password))
                .exchange();
    }

    private RestTestClient.ResponseSpec put(String uri, TokenPair tokens, Map<String, Object> body) {
        return client.put().uri(uri)
                .headers(headers -> headers.setBearerAuth(tokens.accessToken()))
                .contentType(MediaType.APPLICATION_JSON)
                .body(body)
                .exchange();
    }
}
