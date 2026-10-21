package app.shiftboard.notification.internal;

import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.auth.oauth2.ServiceAccountCredentials;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestClientResponseException;

/**
 * Sends through the Firebase Cloud Messaging HTTP v1 API with a service account. One request per
 * device, so that one unknown token does not fail the others.
 */
class FcmPushSender implements PushSender {

    private static final Logger log = LoggerFactory.getLogger(FcmPushSender.class);

    private static final List<String> SCOPES = List.of("https://www.googleapis.com/auth/firebase.messaging");

    private final GoogleCredentials credentials;

    private final RestClient client;

    FcmPushSender(Path credentialsFile, RestClient.Builder builder) {
        try (InputStream in = Files.newInputStream(credentialsFile)) {
            credentials = GoogleCredentials.fromStream(in).createScoped(SCOPES);
        } catch (IOException e) {
            throw new UncheckedIOException("FCM credentials cannot be read from " + credentialsFile, e);
        }
        if (!(credentials instanceof ServiceAccountCredentials serviceAccount)) {
            throw new IllegalStateException("FCM credentials must be a service account key");
        }
        client = builder
                .baseUrl("https://fcm.googleapis.com/v1/projects/" + serviceAccount.getProjectId())
                .build();
    }

    @Override
    public Set<String> send(Collection<String> tokens, PushMessage message) {
        var unknown = new HashSet<String>();
        if (tokens.isEmpty()) {
            return unknown;
        }
        String accessToken;
        try {
            credentials.refreshIfExpired();
            accessToken = credentials.getAccessToken().getTokenValue();
        } catch (IOException e) {
            log.warn("FCM access token could not be obtained; {} push(es) dropped", tokens.size(), e);
            return unknown;
        }
        for (var token : tokens) {
            try {
                client.post()
                        .uri("/messages:send")
                        .headers(headers -> headers.setBearerAuth(accessToken))
                        .contentType(MediaType.APPLICATION_JSON)
                        .body(body(token, message))
                        .retrieve()
                        .toBodilessEntity();
            } catch (RestClientResponseException e) {
                if (e.getStatusCode().isSameCodeAs(HttpStatus.NOT_FOUND)
                        || e.getResponseBodyAsString().contains("UNREGISTERED")) {
                    unknown.add(token);
                } else {
                    log.warn("FCM rejected a push with {}", e.getStatusCode());
                }
            } catch (RestClientException e) {
                log.warn("FCM could not be reached", e);
            }
        }
        return unknown;
    }

    private static Map<String, Object> body(String token, PushMessage message) {
        return Map.of("message", Map.of(
                "token", token,
                "notification", Map.of("title", message.title(), "body", message.body()),
                "data", message.data(),
                "android", Map.of("priority", "high")));
    }
}
