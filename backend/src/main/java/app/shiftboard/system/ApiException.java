package app.shiftboard.system;

import org.springframework.http.HttpStatus;

/**
 * An error the API reports to the client as a problem detail with a machine-readable code.
 * The message becomes the problem's detail, so it must not contain internals or personal data.
 */
public class ApiException extends RuntimeException {

    private final HttpStatus status;
    private final String code;

    public ApiException(HttpStatus status, String code, String detail) {
        super(detail);
        this.status = status;
        this.code = code;
    }

    public HttpStatus getStatus() {
        return status;
    }

    public String getCode() {
        return code;
    }
}
