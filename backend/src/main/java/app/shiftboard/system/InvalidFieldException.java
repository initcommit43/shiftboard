package app.shiftboard.system;

import org.springframework.http.HttpStatus;

/**
 * A request field that is well-formed but breaks a rule only the application can check.
 * Reported like a bean validation error.
 */
public class InvalidFieldException extends ApiException {

    private final String field;
    private final String fieldCode;

    public InvalidFieldException(String field, String fieldCode) {
        super(HttpStatus.BAD_REQUEST, ProblemDetailsHandler.VALIDATION_FAILED, ProblemDetailsHandler.INVALID_REQUEST);
        this.field = field;
        this.fieldCode = fieldCode;
    }

    public String getField() {
        return field;
    }

    public String getFieldCode() {
        return fieldCode;
    }
}
