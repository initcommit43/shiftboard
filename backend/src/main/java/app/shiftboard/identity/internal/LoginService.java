package app.shiftboard.identity.internal;

import app.shiftboard.identity.TokenPair;
import app.shiftboard.system.ApiException;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
class LoginService {

    private final UserAccountRepository accounts;
    private final PasswordEncoder passwordEncoder;
    private final LoginRateLimiter rateLimiter;
    private final SessionService sessions;
    private final String unknownAccountHash;

    LoginService(
            UserAccountRepository accounts,
            PasswordEncoder passwordEncoder,
            LoginRateLimiter rateLimiter,
            SessionService sessions) {
        this.accounts = accounts;
        this.passwordEncoder = passwordEncoder;
        this.rateLimiter = rateLimiter;
        this.sessions = sessions;
        this.unknownAccountHash = passwordEncoder.encode("no account has this password");
    }

    TokenPair login(String email, String password, ClientType client, String clientAddress) {
        var normalizedEmail = UserAccount.normalizeEmail(email);
        var limiterKey = clientAddress + '|' + normalizedEmail;
        if (!rateLimiter.tryAcquire(limiterKey)) {
            throw new ApiException(
                    HttpStatus.TOO_MANY_REQUESTS, "too_many_attempts", "Too many login attempts. Try again later.");
        }

        var account = accounts.findByEmail(normalizedEmail);
        // Verify against a hash even when the email is unknown, so that both failures
        // take the same time and look the same.
        var passwordHash = account.map(UserAccount::getPasswordHash).orElse(unknownAccountHash);
        // Invited client users have no password yet; checking against a hash keeps the timing the same.
        if (passwordHash == null) {
            passwordHash = unknownAccountHash;
        }
        if (!passwordEncoder.matches(password, passwordHash) || account.isEmpty()
                || account.get().getStatus() == AccountStatus.INVITED) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "invalid_credentials", "Email or password is wrong.");
        }
        if (!client.admits(account.get().getRole())) {
            throw new ApiException(HttpStatus.FORBIDDEN, "wrong_client", "This account cannot use this client.");
        }

        sessions.requireAdmitted(account.get());
        rateLimiter.reset(limiterKey);
        return sessions.open(account.get());
    }
}
