package app.shiftboard.agency.internal;

import java.util.UUID;

import app.shiftboard.agency.AgencySettings;
import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import org.hibernate.annotations.ColumnTransformer;

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

    @Convert(converter = SettingsConverter.class)
    @Column(columnDefinition = "jsonb")
    @ColumnTransformer(write = "?::jsonb")
    private AgencySettings settings;

    protected Agency() {
    }

    UUID getId() {
        return id;
    }

    String getName() {
        return name;
    }

    AgencySettings getSettings() {
        return settings;
    }

    /** Applies to claims and cancellations from now on; decisions already made stay as they are. */
    void changeSettings(AgencySettings settings) {
        this.settings = settings;
    }
}
