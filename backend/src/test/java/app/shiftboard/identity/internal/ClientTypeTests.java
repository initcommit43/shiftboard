package app.shiftboard.identity.internal;

import static org.assertj.core.api.Assertions.assertThat;

import app.shiftboard.identity.Role;
import org.junit.jupiter.api.Test;

class ClientTypeTests {

    @Test
    void theWorkerAppAdmitsOnlyWorkers() {
        assertThat(ClientType.WORKER_APP.admits(Role.WORKER)).isTrue();
        assertThat(ClientType.WORKER_APP.admits(Role.DISPATCHER)).isFalse();
        assertThat(ClientType.WORKER_APP.admits(Role.ADMIN)).isFalse();
    }

    @Test
    void theDashboardAdmitsDispatchersAndAdmins() {
        assertThat(ClientType.DASHBOARD.admits(Role.DISPATCHER)).isTrue();
        assertThat(ClientType.DASHBOARD.admits(Role.ADMIN)).isTrue();
        assertThat(ClientType.DASHBOARD.admits(Role.WORKER)).isFalse();
    }
}
