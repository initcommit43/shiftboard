package app.shiftboard.notification.internal;

import java.util.Collection;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;

/**
 * Takes the place of Firebase Cloud Messaging in the tests and remembers what was sent.
 */
@TestConfiguration(proxyBeanMethods = false)
public class RecordingPushSender implements PushSender {

    public record Sent(Set<String> tokens, String title, String body, java.util.Map<String, String> data) {
    }

    private final List<Sent> sent = new CopyOnWriteArrayList<>();

    private final Set<String> unknown = ConcurrentHashMap.newKeySet();

    @Bean
    @Primary
    PushSender recordingPushSender() {
        return this;
    }

    @Override
    public Set<String> send(Collection<String> tokens, PushMessage message) {
        sent.add(new Sent(Set.copyOf(tokens), message.title(), message.body(), message.data()));
        return Set.copyOf(tokens.stream().filter(unknown::contains).toList());
    }

    public List<Sent> sent() {
        return List.copyOf(sent);
    }

    /** What was sent to the device with this token. */
    public List<Sent> sentTo(String token) {
        return sent.stream().filter(push -> push.tokens().contains(token)).toList();
    }

    /** From now on, the push service answers that it does not know the token. */
    public void forget(String token) {
        unknown.add(token);
    }
}
