package app.shiftboard.identity.internal;

import app.shiftboard.identity.TokenPair;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auth")
class AuthController {

    private final LoginService loginService;
    private final SessionService sessions;

    AuthController(LoginService loginService, SessionService sessions) {
        this.loginService = loginService;
        this.sessions = sessions;
    }

    @PostMapping("/login")
    TokenPair login(@Valid @RequestBody LoginRequest request, HttpServletRequest servletRequest) {
        return loginService.login(
                request.email(), request.password(), request.client(), servletRequest.getRemoteAddr());
    }

    @PostMapping("/refresh")
    TokenPair refresh(@Valid @RequestBody RefreshTokenRequest request) {
        return sessions.refresh(request.refreshToken());
    }

    @PostMapping("/logout")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void logout(@Valid @RequestBody RefreshTokenRequest request) {
        sessions.close(request.refreshToken());
    }

    record LoginRequest(
            @NotBlank @Email @Size(max = 254) String email,
            @NotEmpty @Size(max = 128) String password,
            @NotNull ClientType client) {
    }

    record RefreshTokenRequest(@NotEmpty String refreshToken) {
    }
}
