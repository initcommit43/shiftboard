package app.shiftboard.system;

/**
 * A request field that a rule beyond the declared constraints rejects, such as an end before the
 * start or the id of something the agency does not have. The API reports it like any other
 * validation error: {@code validation_failed} with the field and a machine-readable code.
 */
public class InvalidFieldException extends RuntimeException {

    private final String field;
    private final String code;

    public InvalidFieldException(String field, String code) {
        super("The field " + field + " is not valid: " + code);
        this.field = field;
        this.code = code;
    }

    public String getField() {
        return field;
    }

    public String getCode() {
        return code;
    }
}
