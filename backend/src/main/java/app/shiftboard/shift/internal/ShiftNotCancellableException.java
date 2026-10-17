package app.shiftboard.shift.internal;

import app.shiftboard.system.ApiException;
import org.springframework.http.HttpStatus;

class ShiftNotCancellableException extends ApiException {

    ShiftNotCancellableException() {
        super(HttpStatus.CONFLICT, "shift_not_cancellable", "The shift has ended or is already cancelled.");
    }
}
