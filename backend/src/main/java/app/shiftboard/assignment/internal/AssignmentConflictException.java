package app.shiftboard.assignment.internal;

import app.shiftboard.system.ApiException;
import org.springframework.http.HttpStatus;

/**
 * A change the assignment does not allow in its current status or at this time.
 */
class AssignmentConflictException extends ApiException {

    private AssignmentConflictException(String code, String detail) {
        super(HttpStatus.CONFLICT, code, detail);
    }

    static AssignmentConflictException notPending() {
        return new AssignmentConflictException("assignment_not_pending", "The claim has already been decided on.");
    }

    static AssignmentConflictException notActive() {
        return new AssignmentConflictException(
                "assignment_not_active", "The claim is neither pending nor confirmed.");
    }

    static AssignmentConflictException notCompleted() {
        return new AssignmentConflictException(
                "assignment_not_completed", "Only a completed assignment can be marked as a no-show.");
    }

    static AssignmentConflictException deadlinePassed() {
        return new AssignmentConflictException(
                "cancellation_deadline_passed", "The deadline for dropping out in the app has passed.");
    }
}
