package app.shiftboard.notification.internal;

import java.util.Collection;
import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.Repository;

interface PushTokenRepository extends Repository<PushToken, UUID> {

    List<PushToken> findByWorkerIdIn(Collection<UUID> workerIds);

    /**
     * Stores the token for the worker, or moves it to them when another account registered it on
     * the same device before. Native, because the token may belong to another agency.
     */
    @Modifying
    @Query(nativeQuery = true, value = """
            insert into push_token (id, agency_id, worker_id, token, platform)
            values (uuidv7(), :agencyId, :workerId, :token, :platform)
            on conflict (token) do update
            set agency_id = excluded.agency_id, worker_id = excluded.worker_id, platform = excluded.platform,
                updated_at = now()
            """)
    void register(UUID agencyId, UUID workerId, String token, String platform);

    @Modifying
    @Query("delete from PushToken t where t.token = :token and t.workerId = :workerId")
    int deleteByTokenAndWorkerId(String token, UUID workerId);

    @Modifying
    @Query("delete from PushToken t where t.token in :tokens")
    int deleteByTokenIn(Collection<String> tokens);
}
