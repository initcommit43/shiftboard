package app.shiftboard.agency.internal;

import java.util.UUID;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import org.hibernate.annotations.TenantId;

@Entity
@Table(name = "qualification")
class Qualification {

    @Id
    private UUID id;

    @TenantId
    private UUID agencyId;

    private String name;

    protected Qualification() {
    }

    UUID getId() {
        return id;
    }

    String getName() {
        return name;
    }
}
