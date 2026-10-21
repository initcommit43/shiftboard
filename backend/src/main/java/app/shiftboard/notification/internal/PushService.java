package app.shiftboard.notification.internal;

import java.util.Collection;
import java.util.UUID;

import app.shiftboard.agency.TenantContext;
import app.shiftboard.identity.WorkerProfileProvider;
import app.shiftboard.notification.internal.PushSender.PushMessage;
import app.shiftboard.system.ApiException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * The devices of the current agency's workers, and sending to them.
 */
@Service
class PushService {

    private final PushTokenRepository tokens;

    private final PushSender sender;

    private final WorkerProfileProvider workerProfiles;

    PushService(PushTokenRepository tokens, PushSender sender, WorkerProfileProvider workerProfiles) {
        this.tokens = tokens;
        this.sender = sender;
        this.workerProfiles = workerProfiles;
    }

    /** Pending workers register too, so that the approval can reach them later. */
    @Transactional
    void register(UUID accountId, String token, String platform) {
        tokens.register(TenantContext.require(), worker(accountId), token, platform);
    }

    @Transactional
    void unregister(UUID accountId, String token) {
        tokens.deleteByTokenAndWorkerId(token, worker(accountId));
    }

    /** Sends to every device of the workers and forgets the devices the push service no longer knows. */
    @Transactional
    void send(Collection<UUID> workerIds, PushMessage message) {
        if (workerIds.isEmpty()) {
            return;
        }
        var devices = tokens.findByWorkerIdIn(workerIds).stream().map(PushToken::getToken).toList();
        if (devices.isEmpty()) {
            return;
        }
        var unknown = sender.send(devices, message);
        if (!unknown.isEmpty()) {
            tokens.deleteByTokenIn(unknown);
        }
    }

    private UUID worker(UUID accountId) {
        return workerProfiles.findByAccountId(accountId)
                .orElseThrow(() -> new ApiException(HttpStatus.FORBIDDEN, "forbidden", "Access is denied."))
                .id();
    }
}
