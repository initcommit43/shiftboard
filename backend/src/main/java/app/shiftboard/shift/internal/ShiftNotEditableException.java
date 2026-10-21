package app.shiftboard.shift.internal;

import app.shiftboard.system.ApiException;
import org.springframework.http.HttpStatus;

class ShiftNotEditableException extends ApiException {

    ShiftNotEditableException() {
        super(HttpStatus.CONFLICT, "shift_not_editable", "The shift has started, ended, or is cancelled or completed.");
    }
}
