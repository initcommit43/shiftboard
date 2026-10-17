package app.shiftboard.messaging.internal;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.Repository;

interface ConversationRepository extends Repository<Conversation, UUID> {

    Optional<Conversation> findById(UUID id);

    Optional<Conversation> findByWorkerId(UUID workerId);

    List<Conversation> findByWorkerIdIn(List<UUID> workerIds);

    Page<Conversation> findAll(Pageable pageable);

    /**
     * Creates the worker's conversation unless it exists. A native statement, so that two first
     * messages at the same moment do not fail on the unique worker.
     */
    @Modifying
    @Query(nativeQuery = true, value = """
            insert into conversation (id, agency_id, worker_id, last_message_at)
            values (uuidv7(), :agencyId, :workerId, :now)
            on conflict (worker_id) do nothing
            """)
    void createIfMissing(UUID agencyId, UUID workerId, Instant now);
}
