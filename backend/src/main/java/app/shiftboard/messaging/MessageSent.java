package app.shiftboard.messaging;

import java.util.UUID;

/**
 * A text message or broadcast was written into a worker's conversation. System messages do not
 * publish it: they follow events that are announced on their own.
 *
 * @param fromWorker the worker wrote it; otherwise the agency did
 * @param broadcast  the agency sent it to all confirmed workers of a shift
 * @param shiftId    the shift it is about, or null
 */
public record MessageSent(
        UUID agencyId, UUID messageId, UUID workerId, boolean fromWorker, boolean broadcast, UUID shiftId,
        String body) {
}
