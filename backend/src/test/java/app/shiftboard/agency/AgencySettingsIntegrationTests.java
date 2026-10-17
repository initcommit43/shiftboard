package app.shiftboard.agency;

import java.util.HashMap;
import java.util.Map;

import app.shiftboard.IntegrationTest;
import app.shiftboard.TestData;
import app.shiftboard.identity.Role;
import app.shiftboard.identity.TokenPair;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.client.RestTestClient;

class AgencySettingsIntegrationTests extends IntegrationTest {

    TestData.Agency agency;

    TokenPair admin;

    TokenPair dispatcher;

    @BeforeEach
    void createAgencyWithAdminAndDispatcher() {
        agency = data.agency("Donau Personal");
        admin = login(data.account(agency, Role.ADMIN), DASHBOARD);
        dispatcher = login(data.account(agency, Role.DISPATCHER), DASHBOARD);
    }

    @Test
    void approvalAndTwentyFourHoursByDefault() {
        for (var tokens : new TokenPair[] {admin, dispatcher}) {
            get("/api/v1/agency/settings", tokens)
                    .expectStatus().isOk()
                    .expectBody()
                    .jsonPath("$.autoConfirm").isEqualTo(false)
                    .jsonPath("$.cancellationDeadlineHours").isEqualTo(24);
        }
    }

    @Test
    void anAdminChangesTheSettings() {
        put(Map.of("autoConfirm", true, "cancellationDeadlineHours", 48), admin)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.autoConfirm").isEqualTo(true)
                .jsonPath("$.cancellationDeadlineHours").isEqualTo(48);

        get("/api/v1/agency/settings", dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.autoConfirm").isEqualTo(true)
                .jsonPath("$.cancellationDeadlineHours").isEqualTo(48);

        // Another agency keeps its own settings.
        var other = data.agency("Alpen Events");
        get("/api/v1/agency/settings", login(data.account(other, Role.DISPATCHER), DASHBOARD))
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.autoConfirm").isEqualTo(false)
                .jsonPath("$.cancellationDeadlineHours").isEqualTo(24);
    }

    @Test
    void zeroToThreeHundredThirtySixHoursAreAllowed() {
        put(Map.of("autoConfirm", false, "cancellationDeadlineHours", 0), admin).expectStatus().isOk();
        put(Map.of("autoConfirm", false, "cancellationDeadlineHours", 336), admin).expectStatus().isOk();

        expectFieldError(put(Map.of("autoConfirm", false, "cancellationDeadlineHours", -1), admin),
                "cancellationDeadlineHours", "out_of_range");
        expectFieldError(put(Map.of("autoConfirm", false, "cancellationDeadlineHours", 337), admin),
                "cancellationDeadlineHours", "out_of_range");
        var missing = new HashMap<String, Object>();
        missing.put("cancellationDeadlineHours", 24);
        expectFieldError(put(missing, admin), "autoConfirm", "required");
    }

    @Test
    void onlyAdminsChangeTheSettings() {
        expectProblem(put(Map.of("autoConfirm", true, "cancellationDeadlineHours", 24), dispatcher), 403, "forbidden");
        var worker = signUp(agency.signupCode(), TestData.email());
        expectProblem(get("/api/v1/agency/settings", worker), 403, "forbidden");
        expectProblem(put(Map.of("autoConfirm", true, "cancellationDeadlineHours", 24), worker), 403, "forbidden");
        expectProblem(client.get().uri("/api/v1/agency/settings").exchange(), 401, "unauthenticated");

        get("/api/v1/agency/settings", admin)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.autoConfirm").isEqualTo(false);
    }

    private RestTestClient.ResponseSpec put(Map<String, Object> body, TokenPair tokens) {
        return client.put().uri("/api/v1/agency/settings")
                .headers(headers -> headers.setBearerAuth(tokens.accessToken()))
                .contentType(MediaType.APPLICATION_JSON)
                .body(body)
                .exchange();
    }

    private static void expectFieldError(RestTestClient.ResponseSpec response, String field, String code) {
        expectProblem(response, 400, "validation_failed")
                .jsonPath("$.errors.length()").isEqualTo(1)
                .jsonPath("$.errors[0].field").isEqualTo(field)
                .jsonPath("$.errors[0].code").isEqualTo(code);
    }
}
