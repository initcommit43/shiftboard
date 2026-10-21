package app.shiftboard.notification.internal;

import java.util.UUID;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import org.hibernate.annotations.TenantId;

/**
 * A device a worker gets push notifications on. Written with a native upsert, so the entity is
 * only read and deleted.
 */
@Entity
@Table(name = "push_token")
class PushToken {

    @Id
    private UUID id;

    @TenantId
    private UUID agencyId;

    private UUID workerId;

    private String token;

    protected PushToken() {
    }

    UUID getWorkerId() {
        return workerId;
    }

    String getToken() {
        return token;
    }
}
