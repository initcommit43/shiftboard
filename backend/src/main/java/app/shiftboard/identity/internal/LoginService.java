package app.shiftboard.identity.internal;

import java.time.InstantSource;

import app.shiftboard.identity.TokenPair;
import app.shiftboard.system.ApiException;
import app.shiftboard.system.TooManyRequestsException;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
class LoginService {

    private final UserAccountRepository accounts;
    private final PasswordEncoder passwordEncoder;
    /** Failed logins per client address and email; a successful login clears them. */
    private final RateLimiter rateLimiter;
    private final SessionService sessions;
    private final String unknownAccountHash;

    LoginService(
            UserAccountRepository accounts,
            PasswordEncoder passwordEncoder,
            SecurityProperties properties,
            SessionService sessions) {
        this.accounts = accounts;
        this.passwordEncoder = passwordEncoder;
        var limit = properties.loginRateLimit();
        this.rateLimiter = new RateLimiter(limit.maxAttempts(), limit.window(), InstantSource.system());
        this.sessions = sessions;
        this.unknownAccountHash = passwordEncoder.encode("no account has this password");
    }

    TokenPair login(String email, String password, ClientType client, String clientAddress) {
        var normalizedEmail = UserAccount.normalizeEmail(email);
        var limiterKey = clientAddress + '|' + normalizedEmail;
        var decision = rateLimiter.tryAcquire(limiterKey);
        if (!decision.allowed()) {
            throw new TooManyRequestsException(
                    "too_many_attempts", "Too many login attempts. Try again later.", decision.retryAfter());
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
