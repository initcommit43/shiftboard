package app.shiftboard.messaging.internal;

import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

/**
 * The worker's conversation, the agency's shared inbox and broadcasts. Who may call what is
 * enforced by the security configuration: {@code /worker/**} for workers, the rest for
 * dispatchers and admins.
 */
@RestController
class MessagingController {

    private final MessagingService messaging;

    MessagingController(MessagingService messaging) {
        this.messaging = messaging;
    }

    @GetMapping("/worker/conversation")
    UnreadCount myConversation(@AuthenticationPrincipal Jwt accessToken) {
        return messaging.workerUnread(accountId(accessToken));
    }

    /** Ends when the access token expires; the app refreshes it and reconnects. */
    @GetMapping(path = "/worker/conversation/events", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    SseEmitter myEvents(@AuthenticationPrincipal Jwt accessToken) {
        return messaging.workerStream(accountId(accessToken), lifetime(accessToken));
    }

    @GetMapping("/worker/conversation/messages")
    MessagePage myMessages(
            @AuthenticationPrincipal Jwt accessToken,
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size) {
        return messaging.workerMessages(accountId(accessToken), page, size);
    }

    @PostMapping("/worker/conversation/messages")
    @ResponseStatus(HttpStatus.CREATED)
    MessageResponse send(@AuthenticationPrincipal Jwt accessToken, @Valid @RequestBody MessageRequest request) {
        return messaging.workerSend(accountId(accessToken), request.body().strip(), request.shiftId());
    }

    @GetMapping("/conversations")
    ConversationPage inbox(
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size) {
        return messaging.inbox(page, size);
    }

    /** Ends when the access token expires; the dashboard refreshes it and reconnects. */
    @GetMapping(path = "/conversations/events", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    SseEmitter inboxEvents(@AuthenticationPrincipal Jwt accessToken) {
        return messaging.inboxStream(lifetime(accessToken));
    }

    @GetMapping("/conversations/unread-count")
    UnreadCount inboxUnread() {
        return messaging.inboxUnread();
    }

    @GetMapping("/conversations/{conversationId}/messages")
    MessagePage conversation(
            @PathVariable UUID conversationId,
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size) {
        return messaging.conversationMessages(conversationId, page, size);
    }

    @PostMapping("/conversations/{conversationId}/messages")
    @ResponseStatus(HttpStatus.CREATED)
    MessageResponse reply(
            @AuthenticationPrincipal Jwt accessToken, @PathVariable UUID conversationId,
            @Valid @RequestBody MessageRequest request) {
        return messaging.reply(conversationId, accountId(accessToken), request.body().strip(), request.shiftId());
    }

    @PostMapping("/shifts/{shiftId}/broadcast")
    @ResponseStatus(HttpStatus.CREATED)
    BroadcastResult broadcast(
            @AuthenticationPrincipal Jwt accessToken, @PathVariable UUID shiftId,
            @Valid @RequestBody BroadcastRequest request) {
        return messaging.broadcast(shiftId, accountId(accessToken), request.body().strip());
    }

    private static Duration lifetime(Jwt accessToken) {
        return Duration.between(Instant.now(), accessToken.getExpiresAt());
    }

    private static UUID accountId(Jwt accessToken) {
        return UUID.fromString(accessToken.getSubject());
    }

    record MessageRequest(@NotBlank @Size(max = Message.MAX_BODY) String body, UUID shiftId) {
    }

    record BroadcastRequest(@NotBlank @Size(max = Message.MAX_BODY) String body) {
    }

    record BroadcastResult(int recipients) {
    }

    record UnreadCount(long unreadCount) {
    }

    record MessageShift(UUID id, String title, Instant startsAt) {
    }

    record MessageResponse(
            UUID id,
            MessageType type,
            @JsonInclude(JsonInclude.Include.NON_NULL) SystemEvent event,
            String body,
            boolean fromWorker,
            @JsonInclude(JsonInclude.Include.NON_NULL) String senderName,
            @JsonInclude(JsonInclude.Include.NON_NULL) MessageShift shift,
            Instant createdAt,
            @JsonInclude(JsonInclude.Include.NON_NULL) Instant readAt) {
    }

    record MessagePage(List<MessageResponse> content, int page, int size, long totalElements, int totalPages) {
    }

    record ConversationWorker(UUID id, String firstName, String lastName) {
    }

    record ConversationResponse(UUID id, ConversationWorker worker, MessageResponse lastMessage, long unreadCount) {
    }

    record ConversationPage(
            List<ConversationResponse> content, int page, int size, long totalElements, int totalPages) {
    }
}
