package app.shiftboard.identity.internal;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.Repository;

interface RefreshTokenRepository extends Repository<RefreshToken, UUID> {

    RefreshToken save(RefreshToken token);

    Optional<RefreshToken> findByTokenHash(String tokenHash);

    /**
     * Revokes the token if it is still usable. A single statement, so of two concurrent
     * requests with the same token only one sees a row updated.
     */
    @Modifying
    @Query("""
            update RefreshToken t set t.revokedAt = :now
            where t.tokenHash = :tokenHash and t.revokedAt is null and t.expiresAt > :now
            """)
    int revokeIfActive(String tokenHash, Instant now);

    /** Ends every session of the account. */
    @Modifying
    @Query("""
            update RefreshToken t set t.revokedAt = :now
            where t.userAccountId = :userAccountId and t.revokedAt is null
            """)
    int revokeAll(UUID userAccountId, Instant now);
}
