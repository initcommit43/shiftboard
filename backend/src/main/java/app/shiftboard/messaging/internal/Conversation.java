package app.shiftboard.messaging.internal;

import java.time.Instant;
import java.util.UUID;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import org.hibernate.annotations.TenantId;

/**
 * The one conversation between a worker and their agency. Created by a native insert, so that
 * two first messages at the same moment end up in the same conversation.
 */
@Entity
@Table(name = "conversation")
class Conversation {

    @Id
    private UUID id;

    @TenantId
    private UUID agencyId;

    private UUID workerId;

    private Instant lastMessageAt;

    protected Conversation() {
    }

    void messageAt(Instant time) {
        if (lastMessageAt == null || time.isAfter(lastMessageAt)) {
            lastMessageAt = time;
        }
    }

    UUID getId() {
        return id;
    }

    UUID getWorkerId() {
        return workerId;
    }

    Instant getLastMessageAt() {
        return lastMessageAt;
    }
}
