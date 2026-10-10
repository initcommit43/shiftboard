package app.shiftboard.worker.internal;

import java.time.LocalDate;

import app.shiftboard.agency.Agencies;
import app.shiftboard.agency.AgencySummary;
import app.shiftboard.agency.TenantContext;
import app.shiftboard.identity.TokenPair;
import app.shiftboard.system.ApiException;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/**
 * Signup is not authenticated: the signup code in the link decides which agency the request
 * works for.
 */
@RestController
@RequestMapping("/signup/{signupCode}")
class SignupController {

    private final Agencies agencies;
    private final SignupService signupService;

    SignupController(Agencies agencies, SignupService signupService) {
        this.agencies = agencies;
        this.signupService = signupService;
    }

    @GetMapping
    SignupInfo signupInfo(@PathVariable String signupCode) {
        return new SignupInfo(agencyOf(signupCode).name());
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    TokenPair signUp(@PathVariable String signupCode, @Valid @RequestBody WorkerSignupRequest request) {
        var agency = agencyOf(signupCode);
        try (var _ = TenantContext.bind(agency.id())) {
            return signupService.signUp(request);
        }
    }

    private AgencySummary agencyOf(String signupCode) {
        return agencies.findBySignupCode(signupCode)
                .orElseThrow(() -> new ApiException(
                        HttpStatus.NOT_FOUND, "signup_code_unknown", "No agency has this signup code."));
    }

    record SignupInfo(String agencyName) {
    }

    record WorkerSignupRequest(
            @NotBlank @Size(max = 100) String firstName,
            @NotBlank @Size(max = 100) String lastName,
            @NotNull @DateOfBirth LocalDate dateOfBirth,
            @NotBlank @Email @Size(max = 254) String email,
            @NotNull @Size(min = 5, max = 30) String phone,
            @NotNull @Size(min = 8, max = 128) String password) {
    }
}
