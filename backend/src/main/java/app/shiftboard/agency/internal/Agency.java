package app.shiftboard.agency.internal;

import java.util.UUID;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/**
 * The tenant itself, so the only entity that is not filtered by tenant.
 */
@Entity
@Table(name = "agency")
class Agency {

    @Id
    private UUID id;

    private String name;

    private String signupCode;

    protected Agency() {
    }

    UUID getId() {
        return id;
    }

    String getName() {
        return name;
    }
}
