package app.shiftboard.identity;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Instant;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;

import app.shiftboard.IntegrationTest;
import app.shiftboard.TestData;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;

class AuthIntegrationTests extends IntegrationTest {

    @Autowired
    JwtEncoder jwtEncoder;

    @Test
    void aWorkerLogsInToTheWorkerApp() {
        var agency = data.agency("Donau Personal");
        var email = TestData.email();
        signUp(agency.signupCode(), email);

        var tokens = login(email.toUpperCase(Locale.ROOT), WORKER_APP);

        assertThat(tokens.expiresIn()).isEqualTo(900);
        get("/api/v1/me", tokens)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.id").isNotEmpty()
                .jsonPath("$.email").isEqualTo(email)
                .jsonPath("$.role").isEqualTo("WORKER")
                .jsonPath("$.agency.id").isEqualTo(agency.id().toString())
                .jsonPath("$.worker.id").isNotEmpty()
                .jsonPath("$.worker.status").isEqualTo("PENDING");
    }

    @Test
    void dispatchersAndAdminsLogInToTheDashboard() {
        var agency = data.agency("Donau Personal");

        for (var role : new Role[] {Role.DISPATCHER, Role.ADMIN}) {
            var email = data.account(agency, role);

            get("/api/v1/me", login(email, DASHBOARD))
                    .expectStatus().isOk()
                    .expectBody()
                    .jsonPath("$.email").isEqualTo(email)
                    .jsonPath("$.role").isEqualTo(role.name())
                    .jsonPath("$.agency.name").isEqualTo("Donau Personal")
                    .jsonPath("$.worker").doesNotExist();
        }
    }

    @Test
    void aWrongPasswordAndAnUnknownEmailGiveTheSameError() {
        var email = data.account(data.agency("Donau Personal"), Role.DISPATCHER);

        var wrongPassword = postLogin(email, "wrong-password", DASHBOARD);
        var unknownEmail = postLogin(TestData.email(), TestData.PASSWORD, DASHBOARD);

        var wrongPasswordBody = expectProblem(wrongPassword, 401, "invalid_credentials").returnResult().getResponseBody();
        var unknownEmailBody = expectProblem(unknownEmail, 401, "invalid_credentials").returnResult().getResponseBody();
        assertThat(new String(wrongPasswordBody)).isEqualTo(new String(unknownEmailBody));
    }

    @Test
    void aRoleOnTheWrongClientIsRejected() {
        var agency = data.agency("Donau Personal");
        var worker = TestData.email();
        signUp(agency.signupCode(), worker);

        expectProblem(postLogin(worker, TestData.PASSWORD, DASHBOARD), 403, "wrong_client");
        expectProblem(
                postLogin(data.account(agency, Role.DISPATCHER), TestData.PASSWORD, WORKER_APP), 403, "wrong_client");
        expectProblem(postLogin(data.account(agency, Role.ADMIN), TestData.PASSWORD, WORKER_APP), 403, "wrong_client");
    }

    @Test
    void theWrongClientIsOnlyRevealedToTheRightPassword() {
        var email = data.account(data.agency("Donau Personal"), Role.DISPATCHER);

        expectProblem(postLogin(email, "wrong-password", WORKER_APP), 401, "invalid_credentials");
    }

    @Test
    void anInvalidLoginRequestIsAValidationError() {
        expectProblem(postLogin("not-an-email", "", DASHBOARD), 400, "validation_failed")
                .jsonPath("$.errors.length()").isEqualTo(2)
                .jsonPath("$.errors[?(@.field == 'email')].code").isEqualTo("invalid_format")
                .jsonPath("$.errors[?(@.field == 'password')].code").isEqualTo("required");
        expectProblem(postLogin(TestData.email(), TestData.PASSWORD, "FAX"), 400, "validation_failed");
    }

    @Test
    void tooManyLoginAttemptsAreBlocked() {
        var email = data.account(data.agency("Donau Personal"), Role.DISPATCHER);
        for (int attempt = 0; attempt < 5; attempt++) {
            expectProblem(postLogin(email, "wrong-password", DASHBOARD), 401, "invalid_credentials");
        }

        expectProblem(postLogin(email, "wrong-password", DASHBOARD), 429, "too_many_attempts");
        expectProblem(postLogin(email, TestData.PASSWORD, DASHBOARD), 429, "too_many_attempts");
    }

    @Test
    void aSuccessfulLoginClearsTheFailedAttempts() {
        var email = data.account(data.agency("Donau Personal"), Role.DISPATCHER);
        for (int round = 0; round < 2; round++) {
            for (int attempt = 0; attempt < 4; attempt++) {
                expectProblem(postLogin(email, "wrong-password", DASHBOARD), 401, "invalid_credentials");
            }
            login(email, DASHBOARD);
        }
    }

    @Test
    void refreshingReplacesBothTokens() {
        var tokens = login(data.account(data.agency("Donau Personal"), Role.DISPATCHER), DASHBOARD);

        var refreshed = postRefreshToken("/api/v1/auth/refresh", tokens.refreshToken())
                .expectStatus().isOk()
                .expectBody(TokenPair.class).returnResult().getResponseBody();

        assertThat(refreshed.refreshToken()).isNotBlank().isNotEqualTo(tokens.refreshToken());
        assertThat(refreshed.expiresIn()).isEqualTo(900);
        get("/api/v1/me", refreshed).expectStatus().isOk();
    }

    @Test
    void aRefreshTokenWorksOnlyOnce() {
        var tokens = login(data.account(data.agency("Donau Personal"), Role.DISPATCHER), DASHBOARD);
        var refreshed = postRefreshToken("/api/v1/auth/refresh", tokens.refreshToken())
                .expectStatus().isOk()
                .expectBody(TokenPair.class).returnResult().getResponseBody();

        expectProblem(
                postRefreshToken("/api/v1/auth/refresh", tokens.refreshToken()), 401, "invalid_refresh_token");

        postRefreshToken("/api/v1/auth/refresh", refreshed.refreshToken()).expectStatus().isOk();
    }

    @Test
    void anExpiredRefreshTokenIsRejected() {
        var email = data.account(data.agency("Donau Personal"), Role.DISPATCHER);
        var tokens = login(email, DASHBOARD);
        jdbc.sql("""
                update refresh_token set expires_at = now() - interval '1 second'
                where user_account_id = (select id from user_account where email = ?)
                """).param(email).update();

        expectProblem(
                postRefreshToken("/api/v1/auth/refresh", tokens.refreshToken()), 401, "invalid_refresh_token");
    }

    @Test
    void anUnknownRefreshTokenIsRejected() {
        expectProblem(postRefreshToken("/api/v1/auth/refresh", "no-such-token"), 401, "invalid_refresh_token");
        expectProblem(postRefreshToken("/api/v1/auth/refresh", ""), 400, "validation_failed");
    }

    @Test
    void aRefreshTokenLastsThirtyDaysAndIsStoredOnlyAsAHash() {
        var email = data.account(data.agency("Donau Personal"), Role.DISPATCHER);
        var tokens = login(email, DASHBOARD);

        var stored = jdbc.sql("""
                select token_hash, extract(epoch from expires_at - created_at) as lifetime from refresh_token
                where user_account_id = (select id from user_account where email = ?)
                """).param(email).query().singleRow();

        assertThat((String) stored.get("token_hash")).hasSize(64).isNotEqualTo(tokens.refreshToken());
        assertThat(((Number) stored.get("lifetime")).doubleValue()).isBetween(30 * 86_400 - 60.0, 30 * 86_400 + 60.0);
    }

    @Test
    void loggingOutEndsTheSessionOnThatDeviceOnly() {
        var email = data.account(data.agency("Donau Personal"), Role.DISPATCHER);
        var phone = login(email, DASHBOARD);
        var laptop = login(email, DASHBOARD);

        postRefreshToken("/api/v1/auth/logout", phone.refreshToken())
                .expectStatus().isNoContent()
                .expectBody().isEmpty();

        expectProblem(postRefreshToken("/api/v1/auth/refresh", phone.refreshToken()), 401, "invalid_refresh_token");
        postRefreshToken("/api/v1/auth/refresh", laptop.refreshToken()).expectStatus().isOk();
    }

    @Test
    void loggingOutAlwaysSucceeds() {
        var tokens = login(data.account(data.agency("Donau Personal"), Role.DISPATCHER), DASHBOARD);

        postRefreshToken("/api/v1/auth/logout", tokens.refreshToken()).expectStatus().isNoContent();
        postRefreshToken("/api/v1/auth/logout", tokens.refreshToken()).expectStatus().isNoContent();
        postRefreshToken("/api/v1/auth/logout", "no-such-token").expectStatus().isNoContent();
    }

    @Test
    void theCurrentUserNeedsAnAccessToken() {
        expectProblem(client.get().uri("/api/v1/me").exchange(), 401, "unauthenticated");
        client.get().uri("/api/v1/me").exchange()
                .expectHeader().valueEquals(HttpHeaders.WWW_AUTHENTICATE, "Bearer");
    }

    @Test
    void aForgedOrExpiredAccessTokenIsRejected() {
        var agency = data.agency("Donau Personal");
        var tokens = login(data.account(agency, Role.DISPATCHER), DASHBOARD);
        var forged = new TokenPair(tokens.accessToken() + "x", "", 0);
        var expired = new TokenPair(accessToken(agency.id(), Instant.now().minusSeconds(3600)), "", 0);

        expectProblem(get("/api/v1/me", forged), 401, "unauthenticated");
        expectProblem(get("/api/v1/me", expired), 401, "unauthenticated");
    }

    @Test
    void errorsDoNotExposeInternals() {
        var body = client.post().uri("/api/v1/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of("email", TestData.email(), "password", TestData.PASSWORD, "client", "FAX"))
                .exchange()
                .expectBody(String.class).returnResult().getResponseBody();

        assertThat(body).doesNotContain("ClientType", "app.shiftboard", "Exception");
    }

    private String accessToken(UUID agencyId, Instant issuedAt) {
        var claims = JwtClaimsSet.builder()
                .subject(UUID.randomUUID().toString())
                .issuedAt(issuedAt)
                .expiresAt(issuedAt.plusSeconds(900))
                .claim("agency_id", agencyId.toString())
                .claim("role", Role.DISPATCHER.name())
                .build();
        return jwtEncoder.encode(JwtEncoderParameters.from(JwsHeader.with(MacAlgorithm.HS256).build(), claims))
                .getTokenValue();
    }
}
