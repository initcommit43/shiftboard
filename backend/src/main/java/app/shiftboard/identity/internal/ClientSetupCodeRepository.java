package app.shiftboard.identity.internal;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.Repository;

interface ClientSetupCodeRepository extends Repository<ClientSetupCode, UUID> {

    ClientSetupCode save(ClientSetupCode code);

    Optional<ClientSetupCode> findByCodeHash(String codeHash);

    /**
     * Uses the code up if it still works. A single statement, so of two concurrent requests with
     * the same code only one sees a row updated.
     */
    @Modifying
    @Query("""
            update ClientSetupCode c set c.usedAt = :now
            where c.codeHash = :codeHash and c.usedAt is null and c.expiresAt > :now
            """)
    int useIfOpen(String codeHash, Instant now);

    /** Ends every code of the account that is still open, so that only the newest one works. */
    @Modifying
    @Query("""
            update ClientSetupCode c set c.usedAt = :now
            where c.userAccountId = :userAccountId and c.usedAt is null
            """)
    int endOpenCodes(UUID userAccountId, Instant now);
}
