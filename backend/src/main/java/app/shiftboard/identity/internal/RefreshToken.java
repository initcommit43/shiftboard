package app.shiftboard.identity.internal;

import java.time.Instant;
import java.util.UUID;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import org.hibernate.annotations.UuidGenerator;

/**
 * A session on one device. Found by the hash of the token before any tenant is known,
 * so like {@link UserAccount} it is not filtered by tenant.
 */
@Entity
@Table(name = "refresh_token")
class RefreshToken {

    @Id
    @UuidGenerator(style = UuidGenerator.Style.VERSION_7)
    private UUID id;

    private UUID agencyId;

    private UUID userAccountId;

    private String tokenHash;

    private Instant expiresAt;

    private Instant revokedAt;

    protected RefreshToken() {
    }

    RefreshToken(UserAccount account, String tokenHash, Instant expiresAt) {
        this.agencyId = account.getAgencyId();
        this.userAccountId = account.getId();
        this.tokenHash = tokenHash;
        this.expiresAt = expiresAt;
    }

    UUID getUserAccountId() {
        return userAccountId;
    }
}
