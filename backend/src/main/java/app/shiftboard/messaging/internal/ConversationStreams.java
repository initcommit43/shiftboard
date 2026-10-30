package app.shiftboard.messaging.internal;

import java.io.IOException;
import java.time.Duration;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.event.ContextClosedEvent;
import org.springframework.context.event.EventListener;
import org.springframework.http.MediaType;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

/**
 * The open event streams of this instance, and the notices sent through them (ADR 0031). Staff get
 * every conversation of their agency, a worker only their own. Held in memory: with more than one
 * instance, notices have to travel through the database first.
 */
@Component
class ConversationStreams {

    private static final Logger log = LoggerFactory.getLogger(ConversationStreams.class);

    private final Map<UUID, Set<SseEmitter>> staffByAgency = new ConcurrentHashMap<>();

    private final Map<UUID, Set<SseEmitter>> byWorker = new ConcurrentHashMap<>();

    /** A stream of every conversation of the agency; it ends after {@code lifetime}. */
    SseEmitter openForStaff(UUID agencyId, Duration lifetime) {
        return open(staffByAgency, agencyId, lifetime);
    }

    /** A stream of the worker's own conversation; it ends after {@code lifetime}. */
    SseEmitter openForWorker(UUID workerId, Duration lifetime) {
        return open(byWorker, workerId, lifetime);
    }

    /**
     * Tells the worker and the agency's staff that the conversation changed, once the current
     * transaction has committed, so that a reload sees the change.
     */
    void changed(UUID agencyId, UUID workerId, UUID conversationId, Change change) {
        Runnable notify = () -> {
            var notice = new Notice(conversationId, change);
            sendAll(staffByAgency, agencyId, notice);
            sendAll(byWorker, workerId, notice);
        };
        if (TransactionSynchronizationManager.isSynchronizationActive()) {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override
                public void afterCommit() {
                    notify.run();
                }
            });
        } else {
            notify.run();
        }
    }

    /** Keeps idle connections open through proxies, and finds the ones that went away. */
    @Scheduled(fixedDelayString = "${shiftboard.messaging.heartbeat:PT25S}")
    void heartbeat() {
        heartbeat(staffByAgency);
        heartbeat(byWorker);
    }

    /** Ends every stream, so that a graceful shutdown doesn't wait for them; clients reconnect. */
    @EventListener(ContextClosedEvent.class)
    void closeAll() {
        for (var streams : List.of(staffByAgency, byWorker)) {
            streams.values().forEach(emitters -> Set.copyOf(emitters).forEach(SseEmitter::complete));
            streams.clear();
        }
    }

    private SseEmitter open(Map<UUID, Set<SseEmitter>> streams, UUID key, Duration lifetime) {
        var emitter = new SseEmitter(Math.max(lifetime.toMillis(), 1));
        streams.computeIfAbsent(key, k -> ConcurrentHashMap.newKeySet()).add(emitter);
        Runnable remove = () -> streams.computeIfPresent(key, (k, set) -> {
            set.remove(emitter);
            return set.isEmpty() ? null : set;
        });
        emitter.onCompletion(remove);
        emitter.onError(error -> remove.run());
        emitter.onTimeout(() -> {
            remove.run();
            emitter.complete();
        });
        // Commits the response right away, so clients know they are connected.
        send(streams, key, emitter, SseEmitter.event().comment("connected"));
        return emitter;
    }

    private void sendAll(Map<UUID, Set<SseEmitter>> streams, UUID key, Notice notice) {
        var emitters = streams.get(key);
        if (emitters == null) {
            return;
        }
        for (var emitter : Set.copyOf(emitters)) {
            send(streams, key, emitter,
                    SseEmitter.event().name("conversation").data(notice, MediaType.APPLICATION_JSON));
        }
    }

    private void heartbeat(Map<UUID, Set<SseEmitter>> streams) {
        streams.forEach((key, emitters) -> Set.copyOf(emitters)
                .forEach(emitter -> send(streams, key, emitter, SseEmitter.event().comment("ping"))));
    }

    private void send(
            Map<UUID, Set<SseEmitter>> streams, UUID key, SseEmitter emitter, SseEmitter.SseEventBuilder event) {
        try {
            emitter.send(event);
        } catch (IOException | IllegalStateException e) {
            // The client went away; the next reconnect opens a new stream.
            log.debug("Dropping a closed event stream: {}", e.getMessage());
            streams.computeIfPresent(key, (k, set) -> {
                set.remove(emitter);
                return set.isEmpty() ? null : set;
            });
            emitter.completeWithError(e);
        }
    }

    /** What changed in a conversation; the API's {@code ConversationChange}. */
    enum Change {
        MESSAGE,
        READ
    }

    /** The data of a {@code conversation} event; the API's {@code ConversationEvent}. */
    record Notice(UUID conversationId, Change change) {
    }
}
