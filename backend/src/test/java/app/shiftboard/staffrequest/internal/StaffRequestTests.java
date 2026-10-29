package app.shiftboard.staffrequest.internal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatExceptionOfType;

import java.time.Duration;
import java.time.Instant;
import java.util.UUID;

import app.shiftboard.system.InvalidFieldException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

class StaffRequestTests {

    static final Instant NOW = Instant.parse("2026-11-02T08:00:00Z");

    static final Instant TOMORROW = NOW.plus(Duration.ofDays(1));

    @Test
    void startsOpen() {
        var request = request(TOMORROW, TOMORROW.plus(Duration.ofHours(8)), 3);

        assertThat(request.getStatus()).isEqualTo(StaffRequestStatus.OPEN);
        assertThat(request.getDecidedAt()).isNull();
        assertThat(request.getShiftId()).isNull();
    }

    @Test
    void rejectsAStartInThePast() {
        assertThatExceptionOfType(InvalidFieldException.class)
                .isThrownBy(() -> request(NOW.minusSeconds(60), NOW.plus(Duration.ofHours(8)), 1))
                .satisfies(e -> {
                    assertThat(e.getField()).isEqualTo("startsAt");
                    assertThat(e.getCode()).isEqualTo("in_past");
                });
    }

    @Test
    void rejectsAnEndThatIsNotAfterTheStart() {
        assertThatExceptionOfType(InvalidFieldException.class)
                .isThrownBy(() -> request(TOMORROW, TOMORROW, 1))
                .satisfies(e -> {
                    assertThat(e.getField()).isEqualTo("endsAt");
                    assertThat(e.getCode()).isEqualTo("before_start");
                });
    }

    @ParameterizedTest
    @ValueSource(ints = {0, -1, 501})
    void rejectsAWorkerCountOutOfRange(int workerCount) {
        assertThatExceptionOfType(InvalidFieldException.class)
                .isThrownBy(() -> request(TOMORROW, TOMORROW.plus(Duration.ofHours(8)), workerCount))
                .satisfies(e -> assertThat(e.getCode()).isEqualTo("out_of_range"));
    }

    @Test
    void anAcceptedRequestKeepsItsShift() {
        var request = open();
        var shiftId = UUID.randomUUID();

        request.accept(shiftId, NOW);

        assertThat(request.getStatus()).isEqualTo(StaffRequestStatus.ACCEPTED);
        assertThat(request.getShiftId()).isEqualTo(shiftId);
        assertThat(request.getDecidedAt()).isEqualTo(NOW);
    }

    @Test
    void aDeclinedRequestKeepsItsReason() {
        var request = open();

        request.decline("Am Wochenende ausgebucht.", NOW);

        assertThat(request.getStatus()).isEqualTo(StaffRequestStatus.DECLINED);
        assertThat(request.getDeclineReason()).isEqualTo("Am Wochenende ausgebucht.");
        assertThat(request.getDecidedAt()).isEqualTo(NOW);
    }

    @Test
    void onlyAnOpenRequestChanges() {
        var withdrawn = open();
        withdrawn.withdraw(NOW);

        assertThat(withdrawn.getStatus()).isEqualTo(StaffRequestStatus.WITHDRAWN);
        assertThatExceptionOfType(StaffRequestNotOpenException.class).isThrownBy(() -> withdrawn.withdraw(NOW));
        assertThatExceptionOfType(StaffRequestNotOpenException.class)
                .isThrownBy(() -> withdrawn.accept(UUID.randomUUID(), NOW));
        assertThatExceptionOfType(StaffRequestNotOpenException.class)
                .isThrownBy(() -> withdrawn.decline("Zu spät.", NOW));

        var accepted = open();
        accepted.accept(UUID.randomUUID(), NOW);
        assertThatExceptionOfType(StaffRequestNotOpenException.class).isThrownBy(() -> accepted.withdraw(NOW));
    }

    private static StaffRequest open() {
        return request(TOMORROW, TOMORROW.plus(Duration.ofHours(8)), 3);
    }

    private static StaffRequest request(Instant startsAt, Instant endsAt, int workerCount) {
        return new StaffRequest(
                UUID.randomUUID(), UUID.randomUUID(), UUID.randomUUID(), "Lagerhelfer", startsAt, endsAt, false,
                workerCount, null, NOW);
    }
}
