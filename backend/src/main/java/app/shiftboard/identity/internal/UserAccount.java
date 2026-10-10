package app.shiftboard.identity.internal;

import java.util.Locale;
import java.util.UUID;

import app.shiftboard.identity.Role;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import org.hibernate.annotations.UuidGenerator;

/**
 * A login. Accounts are found by their globally unique email before any tenant is known, so
 * unlike the other entities they are not filtered by tenant: they are what a request's tenant
 * is derived from. The agency is a plain column.
 */
@Entity
@Table(name = "user_account")
class UserAccount {

    @Id
    @UuidGenerator(style = UuidGenerator.Style.VERSION_7)
    private UUID id;

    private UUID agencyId;

    private String email;

    private String passwordHash;

    @Enumerated(EnumType.STRING)
    private Role role;

    protected UserAccount() {
    }

    UserAccount(UUID agencyId, String email, String passwordHash, Role role) {
        this.agencyId = agencyId;
        this.email = normalizeEmail(email);
        this.passwordHash = passwordHash;
        this.role = role;
    }

    /** Emails are compared and stored in lower case. */
    static String normalizeEmail(String email) {
        return email.strip().toLowerCase(Locale.ROOT);
    }

    UUID getId() {
        return id;
    }

    UUID getAgencyId() {
        return agencyId;
    }

    String getEmail() {
        return email;
    }

    String getPasswordHash() {
        return passwordHash;
    }

    Role getRole() {
        return role;
    }
}
