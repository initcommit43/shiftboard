package app.shiftboard.agency;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatIllegalStateException;

import java.util.UUID;

import org.junit.jupiter.api.Test;

class TenantContextTests {

    @Test
    void noAgencyIsBoundByDefault() {
        assertThat(TenantContext.current()).isEmpty();
        assertThatIllegalStateException().isThrownBy(TenantContext::require);
    }

    @Test
    void anAgencyIsBoundUntilTheScopeIsClosed() {
        var agencyId = UUID.randomUUID();

        try (var _ = TenantContext.bind(agencyId)) {
            assertThat(TenantContext.require()).isEqualTo(agencyId);
        }

        assertThat(TenantContext.current()).isEmpty();
    }

    @Test
    void closingANestedScopeRestoresTheOuterAgency() {
        var outer = UUID.randomUUID();
        var inner = UUID.randomUUID();

        try (var _ = TenantContext.bind(outer)) {
            try (var _ = TenantContext.bind(inner)) {
                assertThat(TenantContext.require()).isEqualTo(inner);
            }
            assertThat(TenantContext.require()).isEqualTo(outer);
        }
    }
}
