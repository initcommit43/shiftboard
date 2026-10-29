package app.shiftboard;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.modulith.core.ApplicationModule;
import org.springframework.modulith.core.ApplicationModules;
import org.springframework.modulith.docs.Documenter;

class ModularityTests {

    private final ApplicationModules modules = ApplicationModules.of(ShiftboardApplication.class);

    @Test
    void modulesRespectTheirBoundaries() {
        modules.verify();
    }

    @Test
    void allModulesAreDetected() {
        assertThat(modules.stream().map(ApplicationModule::getIdentifier).map(Object::toString))
                .containsExactlyInAnyOrder(
                        "agency", "identity", "worker", "client", "shift", "assignment", "messaging",
                        "notification", "portal", "staffrequest", "seed", "system");
    }

    @Test
    void writesModuleDocumentation() {
        new Documenter(modules).writeDocumentation();
    }
}
