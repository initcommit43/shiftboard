package app.shiftboard.shift.internal;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

import app.shiftboard.agency.Agencies;
import app.shiftboard.client.Clients;
import app.shiftboard.identity.UserAccounts;
import app.shiftboard.agency.TenantContext;
import app.shiftboard.shift.ShiftCancelled;
import app.shiftboard.shift.ShiftCompleted;
import app.shiftboard.shift.ShiftDetails;
import app.shiftboard.shift.ShiftPublished;
import app.shiftboard.shift.Shifts;
import app.shiftboard.shift.internal.ShiftController.ClientSummary;
import app.shiftboard.shift.internal.ShiftController.ShiftPage;
import app.shiftboard.shift.internal.ShiftController.ShiftPeriod;
import app.shiftboard.shift.internal.ShiftController.ShiftRequest;
import app.shiftboard.shift.internal.ShiftController.ShiftResponse;
import app.shiftboard.system.ApiException;
import app.shiftboard.system.ConflictRetry;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.dao.OptimisticLockingFailureException;
import org.springframework.data.domain.Limit;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

@Service
class ShiftService implements Shifts {

    private static final Sort EARLIEST_START_FIRST = Sort.by("startsAt", "id");
    private static final Sort LATEST_START_FIRST = Sort.by(Sort.Direction.DESC, "startsAt", "id");
    private static final List<ShiftStatus> UPCOMING =
            List.of(ShiftStatus.DRAFT, ShiftStatus.PUBLISHED, ShiftStatus.CANCELLED);
    private static final List<ShiftStatus> PAST =
            List.of(ShiftStatus.PUBLISHED, ShiftStatus.COMPLETED, ShiftStatus.CANCELLED);
    private final ShiftRepository shifts;
    private final Clients clients;
    private final Agencies agencies;
    private final ShiftReferences references;

    private final UserAccounts userAccounts;

    private final ApplicationEventPublisher events;

    private final TransactionTemplate transactions;

    ShiftService(
            ShiftRepository shifts, Clients clients, Agencies agencies, ShiftReferences references,
            UserAccounts userAccounts, ApplicationEventPublisher events, TransactionTemplate transactions) {
        this.shifts = shifts;
        this.clients = clients;
        this.agencies = agencies;
        this.references = references;
        this.userAccounts = userAccounts;
        this.events = events;
        this.transactions = transactions;
    }

    /**
     * Upcoming: draft, published and cancelled shifts that have not ended yet, earliest start
     * first. Past: published, completed and cancelled shifts that have ended, latest start first.
     */
    @Transactional(readOnly = true)
    ShiftPage list(ShiftPeriod period, int page, int size) {
        var now = Instant.now();
        var result = period == ShiftPeriod.PAST
                ? shifts.findByStatusInAndEndsAtLessThanEqual(PAST, now, PageRequest.of(page, size, LATEST_START_FIRST))
                : shifts.findByStatusInAndEndsAtAfter(UPCOMING, now, PageRequest.of(page, size, EARLIEST_START_FIRST));
        return new ShiftPage(
                responses(result.getContent()), page, size, result.getTotalElements(), result.getTotalPages());
    }

    @Transactional(readOnly = true)
    ShiftResponse get(UUID shiftId) {
        return responses(List.of(shifts.findById(shiftId).orElseThrow(ShiftService::notFound))).getFirst();
    }

    /**
     * Calls the shift off, together with its claims: the listeners of {@link ShiftCancelled}
     * cancel them in the same transaction. Each attempt is a transaction of its own, so that a
     * concurrent claim that was faster is seen by the next one.
     */
    ShiftResponse cancel(UUID shiftId) {
        return ConflictRetry.run(() -> transactions.execute(_ -> {
            var shift = shifts.findById(shiftId).orElseThrow(ShiftService::notFound);
            shift.cancel(Instant.now());
            var cancelled = shifts.saveAndFlush(shift);
            events.publishEvent(new ShiftCancelled(TenantContext.require(), shiftId));
            return responses(List.of(cancelled)).getFirst();
        }), ConflictRetry::busy);
    }

    /**
     * Completes the published shifts of the current agency that have ended, at most
     * {@code limit} of them, each in a transaction of its own together with its claims (the
     * listeners of {@link ShiftCompleted}). Returns how many were completed.
     */
    int completeEnded(Instant now, int limit) {
        var ended = shifts.findByStatusAndEndsAtLessThanEqualOrderByEndsAt(ShiftStatus.PUBLISHED, now, Limit.of(limit));
        var completed = 0;
        for (var candidate : ended) {
            try {
                transactions.executeWithoutResult(_ -> {
                    var shift = shifts.findById(candidate.getId()).orElseThrow();
                    shift.complete(now);
                    shifts.saveAndFlush(shift);
                    events.publishEvent(new ShiftCompleted(TenantContext.require(), shift.getId()));
                });
                completed++;
            } catch (OptimisticLockingFailureException e) {
                // Changed at the same moment, for example cancelled; the next run looks at it again.
            }
        }
        return completed;
    }

    @Transactional
    ShiftResponse create(ShiftRequest request, UUID contactUserId) {
        var qualificationIds = request.qualificationIds() == null ? Set.<UUID>of() : request.qualificationIds();
        references.check(request.clientId(), request.locationId(), qualificationIds);

        var shift = new Shift(
                request.clientId(),
                request.locationId(),
                contactUserId,
                request.title().strip(),
                request.description() == null || request.description().isBlank() ? null : request.description().strip(),
                request.startsAt(),
                request.endsAt(),
                Boolean.TRUE.equals(request.endIsEstimate()),
                BigDecimal.valueOf(request.hourlyRateCents(), 2),
                request.slots(),
                qualificationIds);
        if (Boolean.TRUE.equals(request.publish())) {
            shift.publish();
        }
        var created = shifts.saveAndFlush(shift);
        if (created.getStatus() == ShiftStatus.PUBLISHED) {
            events.publishEvent(new ShiftPublished(TenantContext.require(), created.getId()));
        }
        return responses(List.of(created)).getFirst();
    }

    @Transactional
    ShiftResponse publish(UUID shiftId) {
        var shift = shifts.findById(shiftId).orElseThrow(ShiftService::notFound);
        shift.publish();
        events.publishEvent(new ShiftPublished(TenantContext.require(), shift.getId()));
        return responses(List.of(shift)).getFirst();
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ShiftDetails> listOpen(int page, int size) {
        var pageable = PageRequest.of(page, size, EARLIEST_START_FIRST);
        var result = shifts.findByStatusAndStartsAtAfter(ShiftStatus.PUBLISHED, Instant.now(), pageable);
        return new PageImpl<>(details(result.getContent()), pageable, result.getTotalElements());
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<ShiftDetails> find(UUID shiftId) {
        return shifts.findById(shiftId)
                .filter(ShiftService::visibleToWorkers)
                .map(shift -> details(List.of(shift)).getFirst());
    }

    @Override
    @Transactional(readOnly = true)
    public Map<UUID, ShiftDetails> findAll(Collection<UUID> shiftIds) {
        var visible = shifts.findAllById(shiftIds).stream().filter(ShiftService::visibleToWorkers).toList();
        return details(visible).stream().collect(Collectors.toMap(ShiftDetails::id, shift -> shift));
    }

    @Override
    @Transactional
    public ShiftDetails claim(UUID shiftId) {
        var shift = shifts.findById(shiftId)
                .filter(ShiftService::visibleToWorkers)
                .orElseThrow(ShiftService::notFound);
        shift.claim(Instant.now());
        // Written right away: this is where a concurrent claim that was faster makes the version check fail.
        return details(List.of(shifts.saveAndFlush(shift))).getFirst();
    }

    @Override
    @Transactional
    public void release(UUID shiftId) {
        var shift = shifts.findById(shiftId).orElseThrow(ShiftService::notFound);
        shift.release();
        // Written right away, so that a concurrent change of the shift fails this one here.
        shifts.saveAndFlush(shift);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean exists(UUID shiftId) {
        return shifts.existsById(shiftId);
    }

    private static boolean visibleToWorkers(Shift shift) {
        return shift.getStatus() != ShiftStatus.DRAFT;
    }

    private static ApiException notFound() {
        return new ApiException(HttpStatus.NOT_FOUND, "shift_not_found", "The agency has no shift with this id.");
    }

    private List<ShiftResponse> responses(List<Shift> page) {
        var createdAt = page.stream().collect(Collectors.toMap(Shift::getId, Shift::getCreatedAt));
        return details(page).stream()
                .map(shift -> new ShiftResponse(
                        shift.id(),
                        shift.title(),
                        shift.description(),
                        ShiftStatus.valueOf(shift.status()),
                        new ClientSummary(shift.client().id(), shift.client().name()),
                        shift.location(),
                        shift.startsAt(),
                        shift.endsAt(),
                        shift.endIsEstimate(),
                        shift.hourlyRateCents(),
                        shift.slots(),
                        shift.takenSlots(),
                        shift.qualifications(),
                        createdAt.get(shift.id())))
                .toList();
    }

    // Clients, locations, qualification names and contacts come from their modules in one call
    // each, whatever the number of shifts.
    private List<ShiftDetails> details(List<Shift> page) {
        var clientsById = clients.findAll(page.stream().map(Shift::getClientId).distinct().toList());
        var contacts = userAccounts.staffContacts(page.stream().map(Shift::getContactUserId).distinct().toList());
        var qualifications = agencies.qualifications();
        return page.stream()
                .map(shift -> {
                    var client = clientsById.get(shift.getClientId());
                    return new ShiftDetails(
                            shift.getId(),
                            shift.getTitle(),
                            shift.getDescription(),
                            shift.getStatus().name(),
                            new ShiftDetails.Client(client.id(), client.name()),
                            client.location(shift.getLocationId()).orElseThrow(),
                            shift.getStartsAt(),
                            shift.getEndsAt(),
                            shift.isEndIsEstimate(),
                            shift.getHourlyRate().movePointRight(2).intValueExact(),
                            shift.getSlots(),
                            shift.getTakenSlots(),
                            qualifications.stream()
                                    .filter(qualification -> shift.getQualificationIds().contains(qualification.id()))
                                    .toList(),
                            contacts.get(shift.getContactUserId()));
                })
                .toList();
    }
}
