package app.shiftboard.worker.internal;

import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

import app.shiftboard.agency.Agencies;
import app.shiftboard.agency.QualificationSummary;
import app.shiftboard.agency.TenantContext;
import app.shiftboard.identity.Role;
import app.shiftboard.identity.Sessions;
import app.shiftboard.identity.TokenPair;
import app.shiftboard.identity.UserAccounts;
import app.shiftboard.system.InvalidFieldException;
import app.shiftboard.worker.WorkerSignedUp;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
class SignupService {

    private final WorkerRepository workers;
    private final Agencies agencies;
    private final UserAccounts userAccounts;
    private final Sessions sessions;
    private final ApplicationEventPublisher events;

    SignupService(
            WorkerRepository workers,
            Agencies agencies,
            UserAccounts userAccounts,
            Sessions sessions,
            ApplicationEventPublisher events) {
        this.workers = workers;
        this.agencies = agencies;
        this.userAccounts = userAccounts;
        this.sessions = sessions;
        this.events = events;
    }

    /**
     * Creates the account and the pending worker in the current agency and logs the worker in.
     */
    @Transactional
    TokenPair signUp(SignupController.WorkerSignupRequest request) {
        requireQualificationsOfAgency(request.qualificationIds());

        var accountId = userAccounts.register(request.email(), request.password(), Role.WORKER);
        var worker = workers.save(new Worker(
                accountId,
                request.firstName().strip(),
                request.lastName().strip(),
                request.phone().strip(),
                request.qualificationIds()));
        events.publishEvent(new WorkerSignedUp(TenantContext.require(), worker.getId()));
        return sessions.open(accountId);
    }

    private void requireQualificationsOfAgency(Set<UUID> qualificationIds) {
        var known = agencies.qualifications().stream().map(QualificationSummary::id).collect(Collectors.toSet());
        if (!known.containsAll(qualificationIds)) {
            throw new InvalidFieldException("qualificationIds", "unknown");
        }
    }
}
