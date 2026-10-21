package app.shiftboard.worker.internal;

import java.util.UUID;

import app.shiftboard.system.ApiException;
import app.shiftboard.worker.internal.NotificationSettingsController.NotificationSettings;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
class NotificationSettingsService {

    private final WorkerRepository workers;

    NotificationSettingsService(WorkerRepository workers) {
        this.workers = workers;
    }

    @Transactional(readOnly = true)
    NotificationSettings get(UUID accountId) {
        return new NotificationSettings(activeWorker(accountId).isNotificationsPaused());
    }

    @Transactional
    NotificationSettings change(UUID accountId, boolean newShiftsPaused) {
        var worker = activeWorker(accountId);
        worker.pauseNewShiftNotifications(newShiftsPaused);
        return new NotificationSettings(worker.isNotificationsPaused());
    }

    private Worker activeWorker(UUID accountId) {
        return workers.findByUserAccountId(accountId)
                .filter(worker -> worker.getStatus() == WorkerStatus.ACTIVE)
                .orElseThrow(() -> new ApiException(
                        HttpStatus.FORBIDDEN, "worker_not_active",
                        "Notifications are open to workers the agency has approved."));
    }
}
