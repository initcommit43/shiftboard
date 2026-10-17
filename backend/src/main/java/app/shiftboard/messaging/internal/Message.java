package app.shiftboard.messaging.internal;

import java.time.Instant;
import java.util.UUID;

import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import org.hibernate.annotations.TenantId;
import org.hibernate.annotations.UuidGenerator;

/**
 * One message of a conversation: text from the worker or a dispatcher, a broadcast of the agency,
 * or a system message the platform wrote when a claim or shift changed.
 */
@Entity
@Table(name = "message")
class Message {

    static final int MAX_BODY = 2000;

    @Id
    @UuidGenerator(style = UuidGenerator.Style.VERSION_7)
    private UUID id;

    @TenantId
    private UUID agencyId;

    private UUID conversationId;

    private UUID shiftId;

    /** The dispatcher who wrote it; null for the worker's own and for system messages. */
    private UUID senderUserId;

    private boolean fromWorker;

    @Enumerated(EnumType.STRING)
    private MessageType type;

    @Enumerated(EnumType.STRING)
    private SystemEvent event;

    private String body;

    private String dedupKey;

    private Instant createdAt;

    private Instant readAt;

    protected Message() {
    }

    private Message(
            UUID conversationId, UUID shiftId, UUID senderUserId, boolean fromWorker, MessageType type,
            SystemEvent event, String body, String dedupKey, Instant createdAt) {
        this.conversationId = conversationId;
        this.shiftId = shiftId;
        this.senderUserId = senderUserId;
        this.fromWorker = fromWorker;
        this.type = type;
        this.event = event;
        this.body = body;
        this.dedupKey = dedupKey;
        this.createdAt = createdAt;
    }

    static Message fromWorker(UUID conversationId, String body, UUID shiftId, Instant now) {
        return new Message(conversationId, shiftId, null, true, MessageType.TEXT, null, body, null, now);
    }

    static Message fromAgency(UUID conversationId, UUID senderUserId, String body, UUID shiftId, Instant now) {
        return new Message(conversationId, shiftId, senderUserId, false, MessageType.TEXT, null, body, null, now);
    }

    static Message broadcast(UUID conversationId, UUID senderUserId, String body, UUID shiftId, Instant now) {
        return new Message(
                conversationId, shiftId, senderUserId, false, MessageType.BROADCAST, null, body, null, now);
    }

    /**
     * @param dedupKey the same key for the same occurrence, so that it is written once
     */
    static Message system(
            UUID conversationId, SystemEvent event, String body, UUID shiftId, String dedupKey, Instant now) {
        return new Message(conversationId, shiftId, null, false, MessageType.SYSTEM, event, body, dedupKey, now);
    }

    UUID getId() {
        return id;
    }

    UUID getConversationId() {
        return conversationId;
    }

    UUID getShiftId() {
        return shiftId;
    }

    UUID getSenderUserId() {
        return senderUserId;
    }

    boolean isFromWorker() {
        return fromWorker;
    }

    MessageType getType() {
        return type;
    }

    SystemEvent getEvent() {
        return event;
    }

    String getBody() {
        return body;
    }

    Instant getCreatedAt() {
        return createdAt;
    }

    Instant getReadAt() {
        return readAt;
    }
}
