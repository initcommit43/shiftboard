package app.shiftboard.staffrequest.internal;

import app.shiftboard.system.ApiException;
import org.springframework.http.HttpStatus;

class StaffRequestNotOpenException extends ApiException {

    StaffRequestNotOpenException() {
        super(HttpStatus.CONFLICT, "staff_request_not_open",
                "The request was already withdrawn, declined or turned into a shift.");
    }
}
