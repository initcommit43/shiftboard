package app.shiftboard.client.internal;

import java.util.UUID;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import org.hibernate.annotations.TenantId;

/**
 * A site of a client that shifts take place at, such as its central warehouse.
 */
@Entity
@Table(name = "location")
class Location {

    @Id
    private UUID id;

    @TenantId
    private UUID agencyId;

    private UUID clientId;

    private String name;

    private String address;

    protected Location() {
    }

    UUID getId() {
        return id;
    }

    UUID getClientId() {
        return clientId;
    }

    String getName() {
        return name;
    }

    String getAddress() {
        return address;
    }
}
