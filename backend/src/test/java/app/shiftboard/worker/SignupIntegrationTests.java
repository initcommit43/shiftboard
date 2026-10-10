package app.shiftboard.worker;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.LocalDate;
import java.util.Locale;
import java.util.UUID;

import app.shiftboard.IntegrationTest;
import app.shiftboard.TestData;
import app.shiftboard.identity.Role;
import app.shiftboard.identity.TokenPair;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
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
        request.remove("dateOfBirth");
        request.put("phone", "123");
        request.put("password", "short");

        expectProblem(postSignup(agency.signupCode(), request), 400, "validation_failed")
                .jsonPath("$.errors.length()").isEqualTo(6)
                .jsonPath("$.errors[?(@.field == 'firstName')].code").isEqualTo("required")
                .jsonPath("$.errors[?(@.field == 'lastName')].code").isEqualTo("invalid_length")
                .jsonPath("$.errors[?(@.field == 'dateOfBirth')].code").isEqualTo("required")
                .jsonPath("$.errors[?(@.field == 'email')].code").isEqualTo("invalid_format")
                .jsonPath("$.errors[?(@.field == 'phone')].code").isEqualTo("invalid_length")
                .jsonPath("$.errors[?(@.field == 'password')].code").isEqualTo("invalid_length");
    }

    @Test
    void theDateOfBirthIsStoredAndShownToTheAgency() {
        var agency = data.agency("Donau Personal");
        var request = signupRequest(TestData.email());
        request.put("dateOfBirth", "2001-07-23");

        postSignup(agency.signupCode(), request).expectStatus().isCreated();

        get("/api/v1/workers", login(data.account(agency, Role.DISPATCHER), DASHBOARD))
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[0].dateOfBirth").isEqualTo("2001-07-23");
    }

    @ParameterizedTest
    @ValueSource(strings = {"23.07.2001", "2001-02-30", "2001-07", "morgen"})
    void aDateOfBirthThatIsNotADateIsRejected(String dateOfBirth) {
        expectDateOfBirthRejected(dateOfBirth, "invalid_format");
    }

    @Test
    void aDateOfBirthThatIsNotInThePastIsRejected() {
        expectDateOfBirthRejected(LocalDate.now().toString(), "out_of_range");
        expectDateOfBirthRejected(LocalDate.now().plusYears(1).toString(), "out_of_range");
    }

    @Test
    void aDateOfBirthMoreThan120YearsAgoIsRejected() {
        expectDateOfBirthRejected(LocalDate.now().minusYears(120).minusDays(1).toString(), "out_of_range");
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

    private void expectDateOfBirthRejected(String dateOfBirth, String code) {
        var email = TestData.email();
        var request = signupRequest(email);
        request.put("dateOfBirth", dateOfBirth);

        expectProblem(postSignup(data.agency("Donau Personal").signupCode(), request), 400, "validation_failed")
                .jsonPath("$.errors.length()").isEqualTo(1)
                .jsonPath("$.errors[0].field").isEqualTo("dateOfBirth")
                .jsonPath("$.errors[0].code").isEqualTo(code);
        assertThat(accountsWith(email)).isZero();
    }

    private int accountsWith(String email) {
        return jdbc.sql("select count(*) from user_account where email = ?")
                .param(email).query(Integer.class).single();
    }
}
