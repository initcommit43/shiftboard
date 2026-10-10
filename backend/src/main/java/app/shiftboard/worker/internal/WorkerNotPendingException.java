package app.shiftboard.worker.internal;

import app.shiftboard.system.ApiException;
import org.springframework.http.HttpStatus;

class WorkerNotPendingException extends ApiException {

    WorkerNotPendingException() {
        super(HttpStatus.CONFLICT, "worker_not_pending", "The signup of this worker has already been decided.");
    }
}
