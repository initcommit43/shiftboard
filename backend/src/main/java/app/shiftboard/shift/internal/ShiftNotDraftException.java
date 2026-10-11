package app.shiftboard.shift.internal;

import app.shiftboard.system.ApiException;
import org.springframework.http.HttpStatus;

class ShiftNotDraftException extends ApiException {

    ShiftNotDraftException() {
        super(HttpStatus.CONFLICT, "shift_not_draft", "Only a draft can be published.");
    }
}
