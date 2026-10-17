package app.shiftboard.assignment.internal;

import java.util.List;
import java.util.UUID;

import app.shiftboard.assignment.Assignments;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
class AssignmentQueries implements Assignments {

    private final AssignmentRepository assignments;

    AssignmentQueries(AssignmentRepository assignments) {
        this.assignments = assignments;
    }

    @Override
    @Transactional(readOnly = true)
    public List<UUID> confirmedWorkers(UUID shiftId) {
        return assignments.findWorkerIdsByShiftIdAndStatus(shiftId, AssignmentStatus.CONFIRMED);
    }
}
