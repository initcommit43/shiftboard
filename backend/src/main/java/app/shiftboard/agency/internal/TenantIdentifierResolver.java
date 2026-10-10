package app.shiftboard.agency.internal;

import java.util.Map;
import java.util.UUID;

import app.shiftboard.agency.TenantContext;
import org.hibernate.cfg.MultiTenancySettings;
import org.hibernate.context.spi.CurrentTenantIdentifierResolver;
import org.springframework.boot.hibernate.autoconfigure.HibernatePropertiesCustomizer;
import org.springframework.stereotype.Component;

/**
 * Hands the agency of the {@link TenantContext} to Hibernate, which applies it to every
 * {@code @TenantId} entity. Hibernate needs a value even when no agency is bound; the nil UUID
 * belongs to no agency, so such a session finds no tenant-owned rows and cannot insert any.
 */
@Component
class TenantIdentifierResolver implements CurrentTenantIdentifierResolver<UUID>, HibernatePropertiesCustomizer {

    private static final UUID NO_TENANT = new UUID(0, 0);

    @Override
    public UUID resolveCurrentTenantIdentifier() {
        return TenantContext.current().orElse(NO_TENANT);
    }

    @Override
    public boolean validateExistingCurrentSessions() {
        return false;
    }

    @Override
    public void customize(Map<String, Object> hibernateProperties) {
        hibernateProperties.put(MultiTenancySettings.MULTI_TENANT_IDENTIFIER_RESOLVER, this);
    }
}
