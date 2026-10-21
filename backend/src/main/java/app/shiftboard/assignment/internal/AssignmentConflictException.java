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

    static AssignmentConflictException workerAttended() {
        return new AssignmentConflictException(
                "worker_attended", "The worker checked in or has approved hours, so they turned up.");
    }

    static AssignmentConflictException notConfirmed() {
        return new AssignmentConflictException(
                "assignment_not_confirmed", "Only a worker with a confirmed spot checks in and out.");
    }

    static AssignmentConflictException alreadyCheckedIn() {
        return new AssignmentConflictException("already_checked_in", "The worker has already checked in.");
    }

    static AssignmentConflictException checkInNotOpen() {
        return new AssignmentConflictException(
                "check_in_not_open", "Check-in opens shortly before the start and closes at the end.");
    }

    static AssignmentConflictException notCheckedIn() {
        return new AssignmentConflictException("not_checked_in", "The worker has not checked in.");
    }

    static AssignmentConflictException alreadyCheckedOut() {
        return new AssignmentConflictException("already_checked_out", "The worker has already checked out.");
    }

    static AssignmentConflictException hoursApproved() {
        return new AssignmentConflictException(
                "hours_approved", "The agency has approved the hours; it changes them if needed.");
    }

    static AssignmentConflictException notWorked() {
        return new AssignmentConflictException(
                "assignment_not_worked", "Only a worker who held a confirmed spot has hours.");
    }

    static AssignmentConflictException shiftNotStarted() {
        return new AssignmentConflictException(
                "shift_not_started", "Hours can be approved once the shift has started.");
    }
}
