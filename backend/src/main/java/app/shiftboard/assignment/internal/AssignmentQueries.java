package app.shiftboard.assignment.internal;

import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

import app.shiftboard.assignment.Assignments;
import app.shiftboard.shift.ShiftWaitlists;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
class AssignmentQueries implements Assignments, ShiftWaitlists {

    private final AssignmentRepository assignments;

    AssignmentQueries(AssignmentRepository assignments) {
        this.assignments = assignments;
    }

    @Override
    @Transactional(readOnly = true)
    public List<UUID> confirmedWorkers(UUID shiftId) {
        return assignments.findWorkerIdsByShiftIdAndStatus(shiftId, AssignmentStatus.CONFIRMED);
    }

    @Override
    @Transactional(readOnly = true)
    public Map<UUID, Integer> waitingCounts(Collection<UUID> shiftIds) {
        if (shiftIds.isEmpty()) {
            return Map.of();
        }
        return assignments.countWaiting(shiftIds, AssignmentStatus.WAITLISTED).stream()
                .collect(Collectors.toMap(
                        AssignmentRepository.WaitingPerShift::getShiftId,
                        waiting -> Math.toIntExact(waiting.getWaiting())));
    }
}
