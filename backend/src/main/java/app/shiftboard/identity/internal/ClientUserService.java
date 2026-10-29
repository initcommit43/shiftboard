package app.shiftboard.identity.internal;

import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

import app.shiftboard.agency.Agencies;
import app.shiftboard.agency.TenantContext;
import app.shiftboard.client.Clients;
import app.shiftboard.identity.Role;
import app.shiftboard.identity.TokenPair;
import app.shiftboard.system.ApiException;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Portal access for the staff of the agency's clients (ADR 0032): the agency invites them, they
 * set a password with a one-time setup code, and the agency can end their access.
 */
@Service
class ClientUserService {

    static final Duration SETUP_CODE_LIFETIME = Duration.ofDays(7);

    private final UserAccountRepository accounts;

    private final ClientSetupCodeRepository setupCodes;

    private final RefreshTokenRepository refreshTokens;

    private final Clients clients;

    private final Agencies agencies;

    private final PasswordEncoder passwordEncoder;

    private final SessionService sessions;

    ClientUserService(
            UserAccountRepository accounts, ClientSetupCodeRepository setupCodes, RefreshTokenRepository refreshTokens,
            Clients clients, Agencies agencies, PasswordEncoder passwordEncoder, SessionService sessions) {
        this.accounts = accounts;
        this.setupCodes = setupCodes;
        this.refreshTokens = refreshTokens;
        this.clients = clients;
        this.agencies = agencies;
        this.passwordEncoder = passwordEncoder;
        this.sessions = sessions;
    }

    // --- the agency's side ----------------------------------------------------------------

    @Transactional(readOnly = true)
    List<ClientUser> list(UUID clientId) {
        requireClient(clientId);
        return accounts.findByClientIdOrderByLastNameAscFirstNameAsc(clientId).stream()
                .map(ClientUser::of)
                .toList();
    }

    @Transactional
    Invitation invite(UUID clientId, String firstName, String lastName, String email) {
        requirePortalOn();
        requireClient(clientId);
        if (accounts.existsByEmail(UserAccount.normalizeEmail(email))) {
            throw emailAlreadyRegistered();
        }
        UserAccount account;
        try {
            account = accounts.saveAndFlush(
                    UserAccount.invitedClientUser(TenantContext.require(), clientId, email, firstName, lastName));
        } catch (DataIntegrityViolationException e) {
            // A concurrent registration with the same email won; the unique constraint caught it.
            throw emailAlreadyRegistered();
        }
        return newCode(account);
    }

    @Transactional
    Invitation renewSetupCode(UUID clientId, UUID userId) {
        requirePortalOn();
        var account = clientUser(clientId, userId);
        if (account.getStatus() != AccountStatus.INVITED) {
            throw new ApiException(HttpStatus.CONFLICT, "client_user_not_invited",
                    "The user has already set a password or no longer has access.");
        }
        setupCodes.endOpenCodes(account.getId(), Instant.now());
        return newCode(account);
    }

    @Transactional
    ClientUser deactivate(UUID clientId, UUID userId) {
        var account = clientUser(clientId, userId);
        var now = Instant.now();
        account.deactivate();
        setupCodes.endOpenCodes(account.getId(), now);
        refreshTokens.revokeAll(account.getId(), now);
        return ClientUser.of(account);
    }

    // --- the setup link -------------------------------------------------------------------

    /** The agency and account a code belongs to, while it still works. Needs no agency bound. */
    @Transactional(readOnly = true)
    SetupTarget target(String setupCode) {
        return setupCodes.findByCodeHash(SecretTokens.hash(setupCode))
                .filter(code -> code.usableAt(Instant.now()))
                .map(code -> new SetupTarget(code.getAgencyId(), code.getUserAccountId()))
                .orElseThrow(ClientUserService::setupCodeInvalid);
    }

    /** What the set-password form shows. Runs with the target's agency bound. */
    @Transactional(readOnly = true)
    SetupInfo info(SetupTarget target) {
        requirePortalOn();
        var account = accounts.findById(target.accountId()).orElseThrow();
        var client = clients.find(account.getClientId()).orElseThrow();
        return new SetupInfo(account.getFirstName(), account.getEmail(), client.name(), agencies.current().name());
    }

    /** Uses the code up, sets the password and logs the user in. Runs with the target's agency bound. */
    @Transactional
    TokenPair completeSetup(String setupCode, String password) {
        requirePortalOn();
        var now = Instant.now();
        var codeHash = SecretTokens.hash(setupCode);
        if (setupCodes.useIfOpen(codeHash, now) == 0) {
            throw setupCodeInvalid();
        }
        var code = setupCodes.findByCodeHash(codeHash).orElseThrow();
        var account = accounts.findById(code.getUserAccountId()).orElseThrow();
        if (account.getStatus() != AccountStatus.INVITED) {
            throw setupCodeInvalid();
        }
        account.completeSetup(passwordEncoder.encode(password));
        return sessions.open(account);
    }

    // --- shared ---------------------------------------------------------------------------

    /** Throws unless the current agency has the client portal switched on. */
    void requirePortalOn() {
        if (!agencies.features().clientPortal()) {
            throw portalOff();
        }
    }

    static ApiException portalOff() {
        return new ApiException(
                HttpStatus.FORBIDDEN, "client_portal_off", "The agency has the client portal switched off.");
    }

    private Invitation newCode(UserAccount account) {
        var code = SecretTokens.newToken();
        var expiresAt = Instant.now().plus(SETUP_CODE_LIFETIME);
        setupCodes.save(new ClientSetupCode(account, SecretTokens.hash(code), expiresAt));
        return new Invitation(ClientUser.of(account), code, expiresAt);
    }

    private void requireClient(UUID clientId) {
        if (clients.find(clientId).isEmpty()) {
            throw new ApiException(HttpStatus.NOT_FOUND, "client_not_found", "The agency has no client with this id.");
        }
    }

    private UserAccount clientUser(UUID clientId, UUID userId) {
        return accounts.findById(userId)
                .filter(account -> account.getRole() == Role.CLIENT)
                .filter(account -> account.getAgencyId().equals(TenantContext.require()))
                .filter(account -> clientId.equals(account.getClientId()))
                .orElseThrow(() -> new ApiException(
                        HttpStatus.NOT_FOUND, "client_user_not_found", "The client has no user with this id."));
    }

    private static ApiException setupCodeInvalid() {
        return new ApiException(HttpStatus.NOT_FOUND, "setup_code_invalid",
                "The setup link is unknown, already used or expired. Ask the agency for a new one.");
    }

    private static ApiException emailAlreadyRegistered() {
        return new ApiException(
                HttpStatus.CONFLICT, "email_already_registered", "An account with this email already exists.");
    }

    record ClientUser(UUID id, String firstName, String lastName, String email, AccountStatus status) {

        static ClientUser of(UserAccount account) {
            return new ClientUser(account.getId(), account.getFirstName(), account.getLastName(), account.getEmail(),
                    account.getStatus());
        }
    }

    record Invitation(ClientUser user, String setupCode, Instant expiresAt) {
    }

    record SetupTarget(UUID agencyId, UUID accountId) {
    }

    record SetupInfo(String firstName, String email, String clientName, String agencyName) {
    }
}
