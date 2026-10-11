package app.shiftboard.system;

import java.net.URI;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.TypeMismatchException;
import org.springframework.context.MessageSourceResolvable;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ProblemDetail;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.method.annotation.HandlerMethodValidationException;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;
import tools.jackson.databind.exc.MismatchedInputException;

/**
 * Renders errors as RFC 9457 problem details with the machine-readable {@code code} of the API contract.
 */
@RestControllerAdvice
class ProblemDetailsHandler extends ResponseEntityExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(ProblemDetailsHandler.class);
    private static final URI BLANK_TYPE = URI.create("about:blank");
    private static final String VALIDATION_FAILED = "validation_failed";
    private static final String INVALID_REQUEST = "The request is not valid.";
    private static final String INVALID_FORMAT = "invalid_format";

    @ExceptionHandler(ApiException.class)
    ResponseEntity<Object> handleApiException(ApiException ex, WebRequest request) {
        return respond(ex, problem(ex.getStatus(), ex.getCode(), ex.getMessage()), request);
    }

    @ExceptionHandler(InvalidFieldException.class)
    ResponseEntity<Object> handleInvalidField(InvalidFieldException ex, WebRequest request) {
        return validationFailed(ex, List.of(new FieldError(ex.getField(), ex.getCode())), request);
    }

    @ExceptionHandler(AuthenticationException.class)
    ResponseEntity<Object> handleAuthentication(AuthenticationException ex, WebRequest request) {
        return respond(ex, problem(HttpStatus.UNAUTHORIZED, "unauthenticated", "Authentication is required."), request);
    }

    @ExceptionHandler(AccessDeniedException.class)
    ResponseEntity<Object> handleAccessDenied(AccessDeniedException ex, WebRequest request) {
        return respond(ex, problem(HttpStatus.FORBIDDEN, "forbidden", "Access is denied."), request);
    }

    @ExceptionHandler(Exception.class)
    ResponseEntity<Object> handleUnexpected(Exception ex, WebRequest request) {
        log.error("Unhandled exception", ex);
        var problem = problem(HttpStatus.INTERNAL_SERVER_ERROR, "internal_error", "An unexpected error occurred.");
        return respond(ex, problem, request);
    }

    @Override
    protected ResponseEntity<Object> handleMethodArgumentNotValid(
            MethodArgumentNotValidException ex, HttpHeaders headers, HttpStatusCode status, WebRequest request) {
        var errors = ex.getBindingResult().getFieldErrors().stream()
                .map(error -> new FieldError(error.getField(), fieldCode(error)))
                .toList();
        return validationFailed(ex, errors, request);
    }

    @Override
    protected ResponseEntity<Object> handleHandlerMethodValidationException(
            HandlerMethodValidationException ex, HttpHeaders headers, HttpStatusCode status, WebRequest request) {
        var errors = ex.getParameterValidationResults().stream()
                .flatMap(result -> result.getResolvableErrors().stream()
                        .map(error -> new FieldError(result.getMethodParameter().getParameterName(), fieldCode(error))))
                .toList();
        return validationFailed(ex, errors, request);
    }

    @Override
    protected ResponseEntity<Object> handleTypeMismatch(
            TypeMismatchException ex, HttpHeaders headers, HttpStatusCode status, WebRequest request) {
        var errors = ex instanceof MethodArgumentTypeMismatchException mismatch
                ? List.of(new FieldError(mismatch.getName(), INVALID_FORMAT))
                : List.<FieldError>of();
        return validationFailed(ex, errors, request);
    }

    @Override
    protected ResponseEntity<Object> handleHttpMessageNotReadable(
            HttpMessageNotReadableException ex, HttpHeaders headers, HttpStatusCode status, WebRequest request) {
        // A value that cannot be read as the type of its field, such as a date that does not exist.
        var errors = ex.getCause() instanceof MismatchedInputException mismatch && !mismatch.getPath().isEmpty()
                ? List.of(new FieldError(mismatch.getPath().getLast().getPropertyName(), INVALID_FORMAT))
                : List.<FieldError>of();
        return validationFailed(ex, errors, request);
    }

    // Spring leaves the default type out of the body, the API contract requires it.
    @Override
    protected ResponseEntity<Object> createResponseEntity(
            Object body, HttpHeaders headers, HttpStatusCode statusCode, WebRequest request) {
        if (body instanceof ProblemDetail problem && problem.getType() == null) {
            problem.setType(BLANK_TYPE);
        }
        return super.createResponseEntity(body, headers, statusCode, request);
    }

    private ResponseEntity<Object> validationFailed(Exception ex, List<FieldError> errors, WebRequest request) {
        var problem = problem(HttpStatus.BAD_REQUEST, VALIDATION_FAILED, INVALID_REQUEST);
        problem.setProperty("errors", errors);
        return respond(ex, problem, request);
    }

    private ResponseEntity<Object> respond(Exception ex, ProblemDetail problem, WebRequest request) {
        return handleExceptionInternal(
                ex, problem, new HttpHeaders(), HttpStatusCode.valueOf(problem.getStatus()), request);
    }

    private static ProblemDetail problem(HttpStatus status, String code, String detail) {
        var problem = ProblemDetail.forStatusAndDetail(status, detail);
        problem.setProperty("code", code);
        return problem;
    }

    private static String fieldCode(MessageSourceResolvable error) {
        var codes = error.getCodes();
        var constraint = codes == null || codes.length == 0 ? "" : codes[codes.length - 1];
        return switch (constraint) {
            case "NotNull", "NotBlank", "NotEmpty" -> "required";
            case "Size" -> "invalid_length";
            case "Min", "Max", "DateOfBirth" -> "out_of_range";
            case "Email" -> INVALID_FORMAT;
            default -> "invalid";
        };
    }

    private record FieldError(String field, String code) {
    }
}
