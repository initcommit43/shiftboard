package app.shiftboard.identity.internal;

import java.util.List;
import java.util.UUID;

import app.shiftboard.agency.TenantContext;
import app.shiftboard.identity.TokenPair;
import app.shiftboard.identity.internal.ClientUserService.ClientUser;
import app.shiftboard.identity.internal.ClientUserService.Invitation;
import app.shiftboard.identity.internal.ClientUserService.SetupInfo;
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
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/**
 * Client users: the agency manages them under {@code /clients/**} (dispatchers and admins), and the
 * public setup link under {@code /client-setup/**} lets them set a password.
 */
@RestController
class ClientUserController {

    private final ClientUserService clientUsers;

    ClientUserController(ClientUserService clientUsers) {
        this.clientUsers = clientUsers;
    }

    @GetMapping("/clients/{clientId}/users")
    List<ClientUser> list(@PathVariable UUID clientId) {
        return clientUsers.list(clientId);
    }

    @PostMapping("/clients/{clientId}/users")
    @ResponseStatus(HttpStatus.CREATED)
    Invitation invite(@PathVariable UUID clientId, @Valid @RequestBody ClientUserRequest request) {
        return clientUsers.invite(
                clientId, request.firstName().strip(), request.lastName().strip(), request.email().strip());
    }

    @PostMapping("/clients/{clientId}/users/{userId}/setup-link")
    Invitation renewSetupLink(@PathVariable UUID clientId, @PathVariable UUID userId) {
        return clientUsers.renewSetupCode(clientId, userId);
    }

    @PostMapping("/clients/{clientId}/users/{userId}/deactivate")
    ClientUser deactivate(@PathVariable UUID clientId, @PathVariable UUID userId) {
        return clientUsers.deactivate(clientId, userId);
    }

    @GetMapping("/client-setup/{setupCode}")
    SetupInfo setupInfo(@PathVariable String setupCode) {
        var target = clientUsers.target(setupCode);
        // The setup link is public, so the agency comes from the code, bound before the transaction.
        try (var _ = TenantContext.bind(target.agencyId())) {
            return clientUsers.info(target);
        }
    }

    @PostMapping("/client-setup/{setupCode}")
    TokenPair completeSetup(@PathVariable String setupCode, @Valid @RequestBody ClientSetupRequest request) {
        var target = clientUsers.target(setupCode);
        try (var _ = TenantContext.bind(target.agencyId())) {
            return clientUsers.completeSetup(setupCode, request.password());
        }
    }

    record ClientUserRequest(
            @NotBlank @Size(max = 100) String firstName,
            @NotBlank @Size(max = 100) String lastName,
            @NotBlank @Email @Size(max = 254) String email) {
    }

    record ClientSetupRequest(@NotNull @Size(min = 8, max = 128) String password) {
    }
}
