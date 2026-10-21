package app.shiftboard.worker.internal;

import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

import app.shiftboard.identity.WorkerProfile;
import app.shiftboard.identity.WorkerProfileProvider;
import app.shiftboard.worker.WorkerContact;
import app.shiftboard.worker.Workers;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
class WorkerProfiles implements WorkerProfileProvider, Workers {

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

    @Override
    @Transactional(readOnly = true)
    public List<UUID> reachableForNewShifts() {
        return workers.findIdsByStatusAndNotificationsPausedFalse(WorkerStatus.ACTIVE);
    }

    @Override
    @Transactional(readOnly = true)
    public Map<UUID, WorkerContact> contacts(Collection<UUID> workerIds) {
        return workers.findAllById(workerIds).stream()
                .collect(Collectors.toMap(Worker::getId, worker -> new WorkerContact(
                        worker.getId(), worker.getFirstName(), worker.getLastName(), worker.getPhone())));
    }
}
