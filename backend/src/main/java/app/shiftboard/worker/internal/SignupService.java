package app.shiftboard.worker.internal;

import app.shiftboard.agency.TenantContext;
import app.shiftboard.identity.Role;
import app.shiftboard.identity.Sessions;
import app.shiftboard.identity.TokenPair;
import app.shiftboard.identity.UserAccounts;
import app.shiftboard.worker.WorkerSignedUp;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
class SignupService {

    private final WorkerRepository workers;
    private final UserAccounts userAccounts;
    private final Sessions sessions;
    private final ApplicationEventPublisher events;

    SignupService(
            WorkerRepository workers,
            UserAccounts userAccounts,
            Sessions sessions,
            ApplicationEventPublisher events) {
        this.workers = workers;
        this.userAccounts = userAccounts;
        this.sessions = sessions;
        this.events = events;
    }

    /**
     * Creates the account and the pending worker in the current agency and logs the worker in.
     */
    @Transactional
    TokenPair signUp(SignupController.WorkerSignupRequest request) {
        var accountId = userAccounts.register(request.email(), request.password(), Role.WORKER);
        var worker = workers.save(new Worker(
                accountId,
                request.firstName().strip(),
                request.lastName().strip(),
                request.dateOfBirth(),
                request.phone().strip()));
        events.publishEvent(new WorkerSignedUp(TenantContext.require(), worker.getId()));
        return sessions.open(accountId);
    }
}
