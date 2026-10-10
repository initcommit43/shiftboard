package app.shiftboard.worker.internal;

import java.util.List;
import java.util.UUID;
import java.util.function.BiFunction;
import java.util.function.Consumer;

import app.shiftboard.agency.Agencies;
import app.shiftboard.agency.TenantContext;
import app.shiftboard.identity.UserAccounts;
import app.shiftboard.system.ApiException;
import app.shiftboard.worker.WorkerApproved;
import app.shiftboard.worker.WorkerRejected;
import app.shiftboard.worker.internal.WorkerController.WorkerPage;
import app.shiftboard.worker.internal.WorkerController.WorkerResponse;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
class WorkerService {

    private static final Sort OLDEST_SIGNUP_FIRST = Sort.by("createdAt", "id");

    private final WorkerRepository workers;
    private final Agencies agencies;
    private final UserAccounts userAccounts;
    private final ApplicationEventPublisher events;

    WorkerService(
            WorkerRepository workers, Agencies agencies, UserAccounts userAccounts, ApplicationEventPublisher events) {
        this.workers = workers;
        this.agencies = agencies;
        this.userAccounts = userAccounts;
        this.events = events;
    }

    @Transactional(readOnly = true)
    WorkerPage list(WorkerStatus status, int page, int size) {
        var pageable = PageRequest.of(page, size, OLDEST_SIGNUP_FIRST);
        var result = status == null ? workers.findAll(pageable) : workers.findByStatus(status, pageable);
        return new WorkerPage(
                responses(result.getContent()), page, size, result.getTotalElements(), result.getTotalPages());
    }

    @Transactional
    WorkerResponse approve(UUID workerId) {
        return decide(workerId, Worker::approve, WorkerApproved::new);
    }

    @Transactional
    WorkerResponse reject(UUID workerId) {
        return decide(workerId, Worker::reject, WorkerRejected::new);
    }

    private WorkerResponse decide(UUID workerId, Consumer<Worker> decision, BiFunction<UUID, UUID, Object> event) {
        var worker = workers.findByIdForUpdate(workerId)
                .orElseThrow(() -> new ApiException(
                        HttpStatus.NOT_FOUND, "worker_not_found", "The agency has no worker with this id."));
        decision.accept(worker);
        events.publishEvent(event.apply(TenantContext.require(), worker.getId()));
        return responses(List.of(worker)).getFirst();
    }

    // Emails and qualification names come from their modules in one call each, whatever the number of workers.
    private List<WorkerResponse> responses(List<Worker> page) {
        var emails = userAccounts.emails(page.stream().map(Worker::getUserAccountId).toList());
        var qualifications = agencies.qualifications();
        return page.stream()
                .map(worker -> new WorkerResponse(
                        worker.getId(),
                        worker.getFirstName(),
                        worker.getLastName(),
                        worker.getDateOfBirth(),
                        emails.get(worker.getUserAccountId()),
                        worker.getPhone(),
                        worker.getStatus(),
                        qualifications.stream()
                                .filter(qualification -> worker.getQualificationIds().contains(qualification.id()))
                                .toList(),
                        worker.getCreatedAt()))
                .toList();
    }
}
