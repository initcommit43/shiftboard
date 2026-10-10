package app.shiftboard.identity.internal;

import java.util.Collection;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

import app.shiftboard.agency.TenantContext;
import app.shiftboard.identity.Role;
import app.shiftboard.identity.UserAccounts;
import app.shiftboard.system.ApiException;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
class AccountService implements UserAccounts {

    private final UserAccountRepository accounts;
    private final PasswordEncoder passwordEncoder;

    AccountService(UserAccountRepository accounts, PasswordEncoder passwordEncoder) {
        this.accounts = accounts;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    @Transactional
    public UUID register(String email, String password, Role role) {
        if (accounts.existsByEmail(UserAccount.normalizeEmail(email))) {
            throw emailAlreadyRegistered();
        }
        var account = new UserAccount(TenantContext.require(), email, passwordEncoder.encode(password), role);
        try {
            return accounts.saveAndFlush(account).getId();
        } catch (DataIntegrityViolationException e) {
            // A concurrent registration with the same email won; the unique constraint caught it.
            throw emailAlreadyRegistered();
        }
    }

    @Override
    @Transactional(readOnly = true)
    public Map<UUID, String> emails(Collection<UUID> accountIds) {
        return accounts.findAllById(accountIds).stream()
                .collect(Collectors.toMap(UserAccount::getId, UserAccount::getEmail));
    }

    private static ApiException emailAlreadyRegistered() {
        return new ApiException(
                HttpStatus.CONFLICT, "email_already_registered", "An account with this email already exists.");
    }
}
