package app.shiftboard.notification.internal;

import java.nio.file.Path;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestClient;

/**
 * Push goes through Firebase Cloud Messaging once a service account key is configured
 * ({@code FCM_CREDENTIALS_FILE}); until then it is only logged (ADR 0024).
 */
@Configuration(proxyBeanMethods = false)
class PushConfiguration {

    private static final Logger log = LoggerFactory.getLogger(PushConfiguration.class);

    @Bean
    PushSender pushSender(
            @Value("${shiftboard.push.fcm.credentials-file:}") String credentialsFile) {
        if (credentialsFile.isBlank()) {
            log.info("Push notifications are off: no FCM credentials configured");
            return new LoggingPushSender();
        }
        return new FcmPushSender(Path.of(credentialsFile), RestClient.builder());
    }
}
