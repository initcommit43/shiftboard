package app.shiftboard.notification.internal;

import java.util.Collection;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Stands in for Firebase Cloud Messaging while no credentials are configured: logs what would
 * have been sent, without the tokens or the message text.
 */
class LoggingPushSender implements PushSender {

    private static final Logger log = LoggerFactory.getLogger(LoggingPushSender.class);

    @Override
    public Set<String> send(Collection<String> tokens, PushMessage message) {
        log.info("Push not configured; would have sent \"{}\" to {} device(s)", message.title(), tokens.size());
        return Set.of();
    }
}
