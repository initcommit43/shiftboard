package app.shiftboard.shift.internal;

import app.shiftboard.system.ApiException;
import org.springframework.http.HttpStatus;

class ShiftNotClaimableException extends ApiException {

    private ShiftNotClaimableException(String code, String detail) {
        super(HttpStatus.CONFLICT, code, detail);
    }

    static ShiftNotClaimableException notOpen() {
        return new ShiftNotClaimableException("shift_not_open", "The shift is not open for claims.");
    }

    static ShiftNotClaimableException started() {
        return new ShiftNotClaimableException("shift_started", "The shift has already started.");
    }

    static ShiftNotClaimableException full() {
        return new ShiftNotClaimableException("shift_full", "The shift has no free slot left.");
    }
}
