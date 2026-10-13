package app.shiftboard.assignment.internal;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Duration;
import java.time.Instant;
import java.util.UUID;

import org.junit.jupiter.api.Test;

class AssignmentTests {

    private static final Instant START = Instant.parse("2026-11-02T07:00:00Z");

    @Test
    void aNewClaimIsPendingAndBooksTheTimeOfTheShift() {
        var shiftId = UUID.randomUUID();
        var workerId = UUID.randomUUID();
        var now = START.minus(Duration.ofDays(1));

        var assignment = Assignment.claim(shiftId, workerId, START, START.plus(Duration.ofHours(8)), now);

        assertThat(assignment.getStatus()).isEqualTo(AssignmentStatus.PENDING);
        assertThat(assignment.getShiftId()).isEqualTo(shiftId);
        assertThat(assignment.getWorkerId()).isEqualTo(workerId);
        assertThat(assignment.getStartsAt()).isEqualTo(START);
        assertThat(assignment.getEndsAt()).isEqualTo(START.plus(Duration.ofHours(8)));
        assertThat(assignment.getClaimedAt()).isEqualTo(now);
    }

    @Test
    void pendingAndConfirmedClaimsHoldASpot() {
        assertThat(AssignmentStatus.HOLDING)
                .containsExactlyInAnyOrder(AssignmentStatus.PENDING, AssignmentStatus.CONFIRMED);
    }
}
