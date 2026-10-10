package app.shiftboard.worker.internal;

import java.util.Optional;
import java.util.UUID;

import app.shiftboard.identity.WorkerProfile;
import app.shiftboard.identity.WorkerProfileProvider;
import org.springframework.stereotype.Component;

@Component
class WorkerProfiles implements WorkerProfileProvider {

    private final WorkerRepository workers;

    WorkerProfiles(WorkerRepository workers) {
        this.workers = workers;
    }

    @Override
    public Optional<WorkerProfile> findByAccountId(UUID accountId) {
        return workers.findByUserAccountId(accountId)
                .map(worker -> new WorkerProfile(
                        worker.getId(), worker.getFirstName(), worker.getLastName(), worker.getStatus().name()));
    }
}
