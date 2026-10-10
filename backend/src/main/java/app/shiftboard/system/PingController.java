package app.shiftboard.system;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
class PingController {

    private final Ping ping;

    PingController(@Value("${shiftboard.api.version}") String apiVersion) {
        this.ping = new Ping("ok", apiVersion);
    }

    @GetMapping("/ping")
    Ping ping() {
        return ping;
    }

    record Ping(String status, String version) {
    }
}
