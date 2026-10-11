package app.shiftboard.client.internal;

import java.util.UUID;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import org.hibernate.annotations.TenantId;

/**
 * A customer of the agency. Read only so far: clients come from seed data until the dashboard
 * can manage them.
 */
@Entity
@Table(name = "client")
class Client {

    @Id
    private UUID id;

    @TenantId
    private UUID agencyId;

    private String name;

    protected Client() {
    }

    UUID getId() {
        return id;
    }

    String getName() {
        return name;
    }
}
