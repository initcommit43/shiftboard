package app.shiftboard.identity.internal;

import java.time.Instant;
import java.util.UUID;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import org.hibernate.annotations.UuidGenerator;

/** The one-time code of a client user's setup link; only its hash is stored (ADR 0032). */
@Entity
@Table(name = "client_setup_code")
class ClientSetupCode {

    @Id
    @UuidGenerator(style = UuidGenerator.Style.VERSION_7)
    private UUID id;

    private UUID agencyId;

    private UUID userAccountId;

    private String codeHash;

    private Instant expiresAt;

    private Instant usedAt;

    protected ClientSetupCode() {
    }

    ClientSetupCode(UserAccount account, String codeHash, Instant expiresAt) {
        this.agencyId = account.getAgencyId();
        this.userAccountId = account.getId();
        this.codeHash = codeHash;
        this.expiresAt = expiresAt;
    }

    boolean usableAt(Instant now) {
        return usedAt == null && now.isBefore(expiresAt);
    }

    void use(Instant now) {
        usedAt = now;
    }

    UUID getAgencyId() {
        return agencyId;
    }

    UUID getUserAccountId() {
        return userAccountId;
    }

    Instant getExpiresAt() {
        return expiresAt;
    }
}
