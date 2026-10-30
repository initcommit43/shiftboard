package app.shiftboard.messaging.internal;

import java.math.BigDecimal;
import java.text.NumberFormat;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Collection;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

import app.shiftboard.agency.TenantContext;
import app.shiftboard.assignment.Assignments;
import app.shiftboard.identity.UserAccounts;
import app.shiftboard.identity.WorkerProfileProvider;
import app.shiftboard.messaging.MessageSent;
import app.shiftboard.messaging.internal.MessagingController.BroadcastResult;
import app.shiftboard.messaging.internal.MessagingController.ConversationPage;
import app.shiftboard.messaging.internal.MessagingController.ConversationResponse;
import app.shiftboard.messaging.internal.MessagingController.ConversationWorker;
import app.shiftboard.messaging.internal.MessagingController.MessagePage;
import app.shiftboard.messaging.internal.MessagingController.MessageResponse;
import app.shiftboard.messaging.internal.MessagingController.MessageShift;
import app.shiftboard.messaging.internal.MessagingController.UnreadCount;
import app.shiftboard.agency.QualificationSummary;
import app.shiftboard.shift.ShiftChanged;
import app.shiftboard.shift.ShiftDetails;
import app.shiftboard.shift.Shifts;
import app.shiftboard.system.ApiException;
import app.shiftboard.system.InvalidFieldException;
import app.shiftboard.worker.Workers;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

/**
 * Conversations between the agency and its workers: one per worker, created with its first
 * message.
 */
@Service
class MessagingService {

    private static final Sort NEWEST_FIRST = Sort.by(Sort.Direction.DESC, "createdAt", "id");

    private static final Sort LATEST_CONVERSATION_FIRST = Sort.by(Sort.Direction.DESC, "lastMessageAt", "id");

    // The fallback text of system messages names the day the way workers in the reference region read it.
    private static final ZoneId FALLBACK_ZONE = ZoneId.of("Europe/Vienna");

    private static final DateTimeFormatter FALLBACK_DAY =
            DateTimeFormatter.ofPattern("EEE, d. MMM", Locale.GERMAN).withZone(FALLBACK_ZONE);

    private static final DateTimeFormatter FALLBACK_DAY_AND_TIME =
            DateTimeFormatter.ofPattern("EEE, d. MMM, HH:mm", Locale.GERMAN).withZone(FALLBACK_ZONE);

    private static final DateTimeFormatter FALLBACK_TIME =
            DateTimeFormatter.ofPattern("HH:mm", Locale.GERMAN).withZone(FALLBACK_ZONE);

    private final ConversationRepository conversations;

    private final MessageRepository messages;

    private final WorkerProfileProvider workerProfiles;

    private final Workers workers;

    private final Shifts shifts;

    private final UserAccounts userAccounts;

    private final Assignments assignments;

    private final ApplicationEventPublisher events;

    private final ConversationStreams streams;

    MessagingService(
            ConversationRepository conversations, MessageRepository messages, WorkerProfileProvider workerProfiles,
            Workers workers, Shifts shifts, UserAccounts userAccounts, Assignments assignments,
            ApplicationEventPublisher events, ConversationStreams streams) {
        this.conversations = conversations;
        this.messages = messages;
        this.workerProfiles = workerProfiles;
        this.workers = workers;
        this.shifts = shifts;
        this.userAccounts = userAccounts;
        this.assignments = assignments;
        this.events = events;
        this.streams = streams;
    }

    // --- the worker's side ----------------------------------------------------------------

    @Transactional(readOnly = true)
    UnreadCount workerUnread(UUID accountId) {
        var unread = conversations.findByWorkerId(activeWorker(accountId))
                .map(conversation -> messages.countByConversationIdAndFromWorkerFalseAndReadAtIsNull(
                        conversation.getId()))
                .orElse(0L);
        return new UnreadCount(unread);
    }

    /** The newest messages first; what the agency wrote counts as read from now on. */
    @Transactional
    MessagePage workerMessages(UUID accountId, int page, int size) {
        var conversation = conversations.findByWorkerId(activeWorker(accountId));
        if (conversation.isEmpty()) {
            return new MessagePage(List.of(), page, size, 0, 0);
        }
        markRead(conversation.get(), false);
        return page(conversation.get().getId(), page, size);
    }

    @Transactional
    MessageResponse workerSend(UUID accountId, String body, UUID shiftId) {
        var workerId = activeWorker(accountId);
        requireShift(shiftId);
        var now = Instant.now();
        var conversation = conversationOf(workerId, now);
        var message = messages.saveAndFlush(Message.fromWorker(conversation.getId(), body, shiftId, now));
        messageAdded(conversation);
        events.publishEvent(new MessageSent(
                TenantContext.require(), message.getId(), workerId, true, false, shiftId, body));
        return responses(List.of(message)).getFirst();
    }

    @Transactional(readOnly = true)
    SseEmitter workerStream(UUID accountId, Duration lifetime) {
        return streams.openForWorker(activeWorker(accountId), lifetime);
    }

    // --- the agency's side ----------------------------------------------------------------

    SseEmitter inboxStream(Duration lifetime) {
        return streams.openForStaff(TenantContext.require(), lifetime);
    }

    @Transactional(readOnly = true)
    ConversationPage inbox(int page, int size) {
        var result = conversations.findAll(PageRequest.of(page, size, LATEST_CONVERSATION_FIRST));
        var ids = result.getContent().stream().map(Conversation::getId).toList();
        if (ids.isEmpty()) {
            return new ConversationPage(List.of(), page, size, result.getTotalElements(), result.getTotalPages());
        }
        var latest = messages.findLatest(ids).stream()
                .collect(Collectors.toMap(Message::getConversationId, Function.identity()));
        var latestResponses = responses(List.copyOf(latest.values())).stream()
                .collect(Collectors.toMap(MessageResponse::id, Function.identity()));
        var unread = messages.countUnreadFromWorkers(ids).stream()
                .collect(Collectors.toMap(
                        MessageRepository.UnreadPerConversation::getConversationId,
                        MessageRepository.UnreadPerConversation::getUnread));
        var contacts = workers.contacts(result.getContent().stream().map(Conversation::getWorkerId).toList());
        var content = result.getContent().stream()
                .map(conversation -> {
                    var worker = contacts.get(conversation.getWorkerId());
                    return new ConversationResponse(
                            conversation.getId(),
                            new ConversationWorker(worker.id(), worker.firstName(), worker.lastName()),
                            latestResponses.get(latest.get(conversation.getId()).getId()),
                            unread.getOrDefault(conversation.getId(), 0L));
                })
                .toList();
        return new ConversationPage(content, page, size, result.getTotalElements(), result.getTotalPages());
    }

    @Transactional(readOnly = true)
    UnreadCount inboxUnread() {
        return new UnreadCount(messages.countByFromWorkerTrueAndReadAtIsNull());
    }

    /** The newest messages first; what the worker wrote counts as read by the agency from now on. */
    @Transactional
    MessagePage conversationMessages(UUID conversationId, int page, int size) {
        var conversation = conversation(conversationId);
        markRead(conversation, true);
        return page(conversation.getId(), page, size);
    }

    @Transactional
    MessageResponse reply(UUID conversationId, UUID accountId, String body, UUID shiftId) {
        var conversation = conversation(conversationId);
        requireShift(shiftId);
        var now = Instant.now();
        var message = messages.saveAndFlush(Message.fromAgency(conversation.getId(), accountId, body, shiftId, now));
        conversation.messageAt(now);
        messageAdded(conversation);
        events.publishEvent(new MessageSent(
                TenantContext.require(), message.getId(), conversation.getWorkerId(), false, false, shiftId, body));
        return responses(List.of(message)).getFirst();
    }

    /** Writes the message into the conversation of every confirmed worker of the shift. */
    @Transactional
    BroadcastResult broadcast(UUID shiftId, UUID accountId, String body) {
        if (!shifts.exists(shiftId)) {
            throw new ApiException(HttpStatus.NOT_FOUND, "shift_not_found", "The agency has no shift with this id.");
        }
        var recipients = assignments.confirmedWorkers(shiftId);
        if (recipients.isEmpty()) {
            throw new ApiException(
                    HttpStatus.CONFLICT, "no_recipients", "Nobody is confirmed for this shift yet.");
        }
        var now = Instant.now();
        for (var workerId : recipients) {
            var conversation = conversationOf(workerId, now);
            var message = messages.saveAndFlush(
                    Message.broadcast(conversation.getId(), accountId, body, shiftId, now));
            messageAdded(conversation);
            events.publishEvent(new MessageSent(
                    TenantContext.require(), message.getId(), workerId, false, true, shiftId, body));
        }
        return new BroadcastResult(recipients.size());
    }

    // --- the platform's side --------------------------------------------------------------

    /**
     * Writes a system message into the worker's conversation, once per {@code dedupKey}. Runs in a
     * transaction of its own, after the change it reports was committed.
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    void recordSystemMessage(UUID workerId, UUID shiftId, SystemEvent event, String dedupKey) {
        if (messages.existsByDedupKey(dedupKey)) {
            return;
        }
        var shift = shifts.find(shiftId).orElseThrow();
        var now = Instant.now();
        var conversation = conversationOf(workerId, now);
        messages.saveAndFlush(
                Message.system(conversation.getId(), event, fallbackText(event, shift), shiftId, dedupKey, now));
        messageAdded(conversation);
    }

    /**
     * A message to the worker that says what changed on the shift, with the new values (ADR 0026).
     * Its text is all clients show of it.
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    void recordShiftChange(UUID workerId, UUID shiftId, Set<ShiftChanged.Change> changes, String dedupKey) {
        if (messages.existsByDedupKey(dedupKey)) {
            return;
        }
        var shift = shifts.find(shiftId).orElseThrow();
        var now = Instant.now();
        var conversation = conversationOf(workerId, now);
        messages.saveAndFlush(Message.system(
                conversation.getId(), SystemEvent.SHIFT_CHANGED, changeText(changes, shift), shiftId, dedupKey, now));
        messageAdded(conversation);
    }

    /** Such as "Die Agentur hat „Lager“ geändert. Zeit: Do., 22. Okt., 08:00 – 16:00. Stundenlohn: 17,00 €." */
    static String changeText(Set<ShiftChanged.Change> changes, ShiftDetails shift) {
        var text = new StringBuilder("Die Agentur hat „").append(shift.title()).append("“ geändert.");
        // In the order of the shift form.
        for (var change : ShiftChanged.Change.values()) {
            if (!changes.contains(change)) {
                continue;
            }
            text.append(' ').append(switch (change) {
                case TIME -> "Zeit: " + timeText(shift) + ".";
                case CLIENT -> "Kunde: " + shift.client().name() + ".";
                case LOCATION -> "Einsatzort: " + shift.location().name() + ", " + shift.location().address() + ".";
                case TITLE -> "Neuer Titel.";
                case DESCRIPTION -> shift.description() == null
                        ? "Die Beschreibung wurde entfernt."
                        : "Beschreibung: " + shift.description();
                case PAY -> "Stundenlohn: " + euros(shift.hourlyRateCents()) + ".";
                case QUALIFICATIONS -> shift.qualifications().isEmpty()
                        ? "Keine Qualifikationen mehr nötig."
                        : "Qualifikationen: " + String.join(", ",
                                shift.qualifications().stream().map(QualificationSummary::name).toList()) + ".";
            });
        }
        return text.toString();
    }

    private static String timeText(ShiftDetails shift) {
        var sameDay = FALLBACK_DAY.format(shift.startsAt()).equals(FALLBACK_DAY.format(shift.endsAt()));
        var end = (sameDay ? FALLBACK_TIME : FALLBACK_DAY_AND_TIME).format(shift.endsAt());
        return FALLBACK_DAY_AND_TIME.format(shift.startsAt()) + " – " + (shift.endIsEstimate() ? "ca. " : "") + end;
    }

    /** Such as "17,00 €", with a plain space: the currency format puts a no-break one there. */
    private static String euros(int cents) {
        var format = NumberFormat.getNumberInstance(Locale.GERMANY);
        format.setMinimumFractionDigits(2);
        format.setMaximumFractionDigits(2);
        return format.format(BigDecimal.valueOf(cents, 2)) + " €";
    }

    private static String fallbackText(SystemEvent event, ShiftDetails shift) {
        var shiftName = "„" + shift.title() + "“ am " + FALLBACK_DAY.format(shift.startsAt());
        return switch (event) {
            case CLAIM_CONFIRMED -> "Deine Schicht " + shiftName + " ist bestätigt.";
            case CLAIM_REJECTED -> "Deine Anfrage für " + shiftName + " wurde abgelehnt.";
            case CLAIM_CANCELLED_BY_WORKER -> "Du hast " + shiftName + " abgesagt.";
            case REMOVED_BY_AGENCY -> "Die Agentur hat dich aus " + shiftName + " genommen.";
            case SHIFT_CANCELLED -> "Die Schicht " + shiftName + " wurde abgesagt.";
            case WAITLIST_MOVED_UP -> "Du bist von der Warteliste für " + shiftName
                    + " nachgerückt. Deine Anfrage wartet auf die Bestätigung der Agentur.";
            case WAITLIST_MOVED_UP_CONFIRMED -> "Du bist von der Warteliste für " + shiftName
                    + " nachgerückt. Deine Schicht ist bestätigt.";
            case WAITLIST_REMOVED_BY_AGENCY -> "Die Agentur hat dich von der Warteliste für " + shiftName
                    + " genommen.";
            case WAITLIST_SKIPPED -> "Für " + shiftName + " ist ein Platz frei geworden, aber du hast zur selben"
                    + " Zeit schon eine Schicht. Du bist nicht mehr auf der Warteliste.";
            case SHIFT_CHANGED -> throw new IllegalArgumentException("A shift change brings its own text");
        };
    }

    // --- shared ---------------------------------------------------------------------------

    /** Marks the other side's messages as read and tells the open streams, if any were unread. */
    private void markRead(Conversation conversation, boolean fromWorker) {
        if (messages.markRead(conversation.getId(), fromWorker, Instant.now()) > 0) {
            streams.changed(conversation.getAgencyId(), conversation.getWorkerId(), conversation.getId(),
                    ConversationStreams.Change.READ);
        }
    }

    private void messageAdded(Conversation conversation) {
        streams.changed(conversation.getAgencyId(), conversation.getWorkerId(), conversation.getId(),
                ConversationStreams.Change.MESSAGE);
    }

    private Conversation conversationOf(UUID workerId, Instant now) {
        conversations.createIfMissing(TenantContext.require(), workerId, now);
        var conversation = conversations.findByWorkerId(workerId).orElseThrow();
        conversation.messageAt(now);
        return conversation;
    }

    private Conversation conversation(UUID conversationId) {
        return conversations.findById(conversationId)
                .orElseThrow(() -> new ApiException(
                        HttpStatus.NOT_FOUND, "conversation_not_found", "The agency has no conversation with this id."));
    }

    private MessagePage page(UUID conversationId, int page, int size) {
        Page<Message> result = messages.findByConversationId(conversationId, PageRequest.of(page, size, NEWEST_FIRST));
        return new MessagePage(
                responses(result.getContent()), page, size, result.getTotalElements(), result.getTotalPages());
    }

    private void requireShift(UUID shiftId) {
        if (shiftId != null && shifts.find(shiftId).isEmpty()) {
            throw new InvalidFieldException("shiftId", "not_found");
        }
    }

    private UUID activeWorker(UUID accountId) {
        return workerProfiles.findByAccountId(accountId)
                .filter(worker -> "ACTIVE".equals(worker.status()))
                .orElseThrow(() -> new ApiException(
                        HttpStatus.FORBIDDEN, "worker_not_active",
                        "Messages are open to workers the agency has approved."))
                .id();
    }

    // Shifts and sender names come from their modules in one call each, whatever the number of messages.
    private List<MessageResponse> responses(Collection<Message> page) {
        var shiftsById = shifts.findAll(
                page.stream().map(Message::getShiftId).filter(Objects::nonNull).distinct().toList());
        Map<UUID, String> senders = userAccounts.staffContacts(
                        page.stream().map(Message::getSenderUserId).filter(Objects::nonNull).distinct().toList())
                .entrySet().stream()
                .collect(Collectors.toMap(Map.Entry::getKey, entry -> entry.getValue().name()));
        return page.stream()
                .map(message -> {
                    var shift = message.getShiftId() == null ? null : shiftsById.get(message.getShiftId());
                    return new MessageResponse(
                            message.getId(),
                            message.getType(),
                            message.getEvent(),
                            message.getBody(),
                            message.isFromWorker(),
                            message.getSenderUserId() == null ? null : senders.get(message.getSenderUserId()),
                            shift == null ? null : new MessageShift(shift.id(), shift.title(), shift.startsAt()),
                            message.getCreatedAt(),
                            message.getReadAt());
                })
                .toList();
    }
}
