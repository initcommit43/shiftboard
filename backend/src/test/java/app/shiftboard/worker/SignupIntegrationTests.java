package app.shiftboard.worker;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.Locale;
import java.util.UUID;

import app.shiftboard.IntegrationTest;
import app.shiftboard.TestData;
import app.shiftboard.identity.TokenPair;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;

class SignupIntegrationTests extends IntegrationTest {

    @Test
    void signupInfoShowsTheAgency() {
        var agency = data.agency("Donau Personal");

        client.get().uri("/api/v1/signup/{code}", agency.signupCode())
                .exchange()
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.agencyName").isEqualTo("Donau Personal");
    }

    @Test
    void signupInfoForAnUnknownCodeIsNotFound() {
        expectProblem(client.get().uri("/api/v1/signup/no-such-code").exchange(), 404, "signup_code_unknown");
    }

    @Test
    void signingUpCreatesAPendingWorkerAndLogsIn() {
        var agency = data.agency("Donau Personal");
        var email = TestData.email();

        var tokens = postSignup(agency.signupCode(), signupRequest(email))
                .expectStatus().isCreated()
                .expectBody(TokenPair.class).returnResult().getResponseBody();

        assertThat(tokens.accessToken()).isNotBlank();
        assertThat(tokens.refreshToken()).isNotBlank();
        assertThat(tokens.expiresIn()).isEqualTo(900);
        get("/api/v1/me", tokens)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.email").isEqualTo(email)
                .jsonPath("$.role").isEqualTo("WORKER")
                .jsonPath("$.agency.id").isEqualTo(agency.id().toString())
                .jsonPath("$.agency.name").isEqualTo("Donau Personal")
                .jsonPath("$.worker.firstName").isEqualTo("Lena")
                .jsonPath("$.worker.lastName").isEqualTo("Hofer")
                .jsonPath("$.worker.status").isEqualTo("PENDING");
        assertThat(events.all()).contains(new WorkerSignedUp(agency.id(), workerId(tokens)));
    }

    @Test
    void thePasswordIsStoredOnlyAsAHash() {
        var agency = data.agency("Donau Personal");
        var email = TestData.email();

        signUp(agency.signupCode(), email);

        var stored = jdbc.sql("select password_hash from user_account where email = ?")
                .param(email).query(String.class).single();
        assertThat(stored).startsWith("{argon2}").doesNotContain(TestData.PASSWORD);
    }

    @Test
    void signingUpWithAnUnknownCodeIsNotFound() {
        var email = TestData.email();

        expectProblem(postSignup("no-such-code", signupRequest(email)), 404, "signup_code_unknown");

        assertThat(accountsWith(email)).isZero();
    }

    @Test
    void anAlreadyRegisteredEmailIsRejected() {
        var agency = data.agency("Donau Personal");
        var email = TestData.email();
        signUp(agency.signupCode(), email);

        expectProblem(postSignup(agency.signupCode(), signupRequest(email)), 409, "email_already_registered");
        expectProblem(
                postSignup(agency.signupCode(), signupRequest(email.toUpperCase(Locale.ROOT))),
                409, "email_already_registered");
    }

    @Test
    void anEmailCanBeRegisteredAtOneAgencyOnly() {
        var email = TestData.email();
        signUp(data.agency("Donau Personal").signupCode(), email);

        expectProblem(
                postSignup(data.agency("Alpen Events").signupCode(), signupRequest(email)),
                409, "email_already_registered");
    }

    @Test
    void invalidFieldsAreReportedOneByOne() {
        var agency = data.agency("Donau Personal");
        var request = signupRequest("not-an-email");
        request.put("firstName", " ");
        request.put("lastName", "x".repeat(101));
        request.put("phone", "123");
        request.put("password", "short");

        expectProblem(postSignup(agency.signupCode(), request), 400, "validation_failed")
                .jsonPath("$.errors.length()").isEqualTo(5)
                .jsonPath("$.errors[?(@.field == 'firstName')].code").isEqualTo("required")
                .jsonPath("$.errors[?(@.field == 'lastName')].code").isEqualTo("invalid_length")
                .jsonPath("$.errors[?(@.field == 'email')].code").isEqualTo("invalid_format")
                .jsonPath("$.errors[?(@.field == 'phone')].code").isEqualTo("invalid_length")
                .jsonPath("$.errors[?(@.field == 'password')].code").isEqualTo("invalid_length");
    }

    @Test
    void aBodyThatCannotBeReadIsAValidationError() {
        var agency = data.agency("Donau Personal");

        expectProblem(
                client.post().uri("/api/v1/signup/{code}", agency.signupCode())
                        .contentType(MediaType.APPLICATION_JSON)
                        .body("{")
                        .exchange(),
                400, "validation_failed");
    }

    @Test
    void workersOfOneAgencyCarryItsAgencyId() {
        var agency = data.agency("Donau Personal");
        var workerId = workerId(signUp(agency.signupCode(), TestData.email()));

        var agencyId = jdbc.sql("select agency_id from worker where id = ?")
                .param(workerId).query(UUID.class).single();
        assertThat(agencyId).isEqualTo(agency.id());
    }

    private int accountsWith(String email) {
        return jdbc.sql("select count(*) from user_account where email = ?")
                .param(email).query(Integer.class).single();
    }
}
