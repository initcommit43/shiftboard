package app.shiftboard.worker.internal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatExceptionOfType;

import java.util.UUID;

import org.junit.jupiter.api.Test;

class WorkerTests {

    @Test
    void signsUpAsPendingWithoutQualifications() {
        var worker = new Worker(UUID.randomUUID(), "Lena", "Hofer", "+43 660 5550101");

        assertThat(worker.getStatus()).isEqualTo(WorkerStatus.PENDING);
        assertThat(worker.getQualificationIds()).isEmpty();
    }

    @Test
    void approvingAPendingWorkerActivatesIt() {
        var worker = pendingWorker();

        worker.approve();

        assertThat(worker.getStatus()).isEqualTo(WorkerStatus.ACTIVE);
    }

    @Test
    void rejectingAPendingWorkerDeactivatesIt() {
        var worker = pendingWorker();

        worker.reject();

        assertThat(worker.getStatus()).isEqualTo(WorkerStatus.INACTIVE);
    }

    @Test
    void anApprovedWorkerCannotBeDecidedAgain() {
        var worker = pendingWorker();
        worker.approve();

        assertThatExceptionOfType(WorkerNotPendingException.class).isThrownBy(worker::approve);
        assertThatExceptionOfType(WorkerNotPendingException.class).isThrownBy(worker::reject);
        assertThat(worker.getStatus()).isEqualTo(WorkerStatus.ACTIVE);
    }

    @Test
    void aRejectedWorkerCannotBeDecidedAgain() {
        var worker = pendingWorker();
        worker.reject();

        assertThatExceptionOfType(WorkerNotPendingException.class).isThrownBy(worker::approve);
        assertThatExceptionOfType(WorkerNotPendingException.class).isThrownBy(worker::reject);
        assertThat(worker.getStatus()).isEqualTo(WorkerStatus.INACTIVE);
    }

    private static Worker pendingWorker() {
        return new Worker(UUID.randomUUID(), "Jakob", "Steiner", "+43 660 5550102");
    }
}
