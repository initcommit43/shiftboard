package app.shiftboard.notification.internal;

import java.util.Collection;
import java.util.Map;
import java.util.Set;

/**
 * Delivers push notifications to devices.
 */
interface PushSender {

    /**
     * Sends the message to every token. Delivery is not guaranteed; the app always loads the
     * current state from the API (ADR 0016).
     *
     * @return the tokens the push service no longer knows, to be forgotten
     */
    Set<String> send(Collection<String> tokens, PushMessage message);

    /**
     * @param data small key-value payload for the app, such as the shift to open
     */
    record PushMessage(String title, String body, Map<String, String> data) {
    }
}
