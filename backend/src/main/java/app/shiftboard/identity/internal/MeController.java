package app.shiftboard.identity.internal;

import java.util.UUID;

import app.shiftboard.agency.Agencies;
import app.shiftboard.agency.AgencySummary;
import app.shiftboard.identity.Role;
import app.shiftboard.identity.WorkerProfile;
import app.shiftboard.identity.WorkerProfileProvider;
import com.fasterxml.jackson.annotation.JsonInclude;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
class MeController {

    private final UserAccountRepository accounts;
    private final Agencies agencies;
    private final WorkerProfileProvider workerProfiles;

    MeController(UserAccountRepository accounts, Agencies agencies, WorkerProfileProvider workerProfiles) {
        this.accounts = accounts;
        this.agencies = agencies;
        this.workerProfiles = workerProfiles;
    }

    @GetMapping("/me")
    CurrentUser me(@AuthenticationPrincipal Jwt accessToken) {
        var account = accounts.findById(UUID.fromString(accessToken.getSubject())).orElseThrow();
        var worker = account.getRole() == Role.WORKER
                ? workerProfiles.findByAccountId(account.getId()).orElseThrow()
                : null;
        return new CurrentUser(account.getId(), account.getEmail(), account.getRole(), agencies.current(), worker);
    }

    record CurrentUser(
            UUID id,
            String email,
            Role role,
            AgencySummary agency,
            @JsonInclude(JsonInclude.Include.NON_NULL) WorkerProfile worker) {
    }
}
