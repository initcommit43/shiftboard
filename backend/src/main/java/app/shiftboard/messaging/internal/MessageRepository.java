package app.shiftboard.messaging.internal;

import java.time.Instant;
import java.util.Collection;
import java.util.List;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.Repository;

interface MessageRepository extends Repository<Message, UUID> {

    Message saveAndFlush(Message message);

    boolean existsByDedupKey(String dedupKey);

    Page<Message> findByConversationId(UUID conversationId, Pageable pageable);

    /** The newest message of each of the conversations. */
    @Query(nativeQuery = true, value = """
            select distinct on (conversation_id) * from message
            where conversation_id in (:conversationIds)
            order by conversation_id, created_at desc, id desc
            """)
    List<Message> findLatest(Collection<UUID> conversationIds);

    /** How many of the worker's messages nobody at the agency has read, per conversation. */
    @Query("""
            select m.conversationId as conversationId, count(m) as unread from Message m
            where m.conversationId in :conversationIds and m.fromWorker = true and m.readAt is null
            group by m.conversationId
            """)
    List<UnreadPerConversation> countUnreadFromWorkers(Collection<UUID> conversationIds);

    long countByFromWorkerTrueAndReadAtIsNull();

    long countByConversationIdAndFromWorkerFalseAndReadAtIsNull(UUID conversationId);

    /** Marks what one side wrote into the conversation as read by the other. */
    @Modifying
    @Query("""
            update Message m set m.readAt = :now
            where m.conversationId = :conversationId and m.fromWorker = :fromWorker and m.readAt is null
            """)
    int markRead(UUID conversationId, boolean fromWorker, Instant now);

    interface UnreadPerConversation {

        UUID getConversationId();

        long getUnread();
    }
}
