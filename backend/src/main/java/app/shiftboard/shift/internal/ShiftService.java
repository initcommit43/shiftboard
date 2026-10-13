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
import app.shiftboard.agency.QualificationSummary;
import app.shiftboard.client.Clients;
import app.shiftboard.identity.UserAccounts;
import app.shiftboard.shift.ShiftDetails;
import app.shiftboard.shift.Shifts;
import app.shiftboard.shift.internal.ShiftController.ClientSummary;
import app.shiftboard.shift.internal.ShiftController.ShiftPage;
import app.shiftboard.shift.internal.ShiftController.ShiftRequest;
import app.shiftboard.shift.internal.ShiftController.ShiftResponse;
import app.shiftboard.system.ApiException;
import app.shiftboard.system.InvalidFieldException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
class ShiftService implements Shifts {

    private static final Sort EARLIEST_START_FIRST = Sort.by("startsAt", "id");
    private static final List<ShiftStatus> UPCOMING = List.of(ShiftStatus.DRAFT, ShiftStatus.PUBLISHED);
    private static final String NOT_FOUND = "not_found";

    private final ShiftRepository shifts;
    private final Clients clients;
    private final Agencies agencies;

    private final UserAccounts userAccounts;

    ShiftService(ShiftRepository shifts, Clients clients, Agencies agencies, UserAccounts userAccounts) {
        this.shifts = shifts;
        this.clients = clients;
        this.agencies = agencies;
        this.userAccounts = userAccounts;
    }

    /** Draft and published shifts that have not ended yet. */
    @Transactional(readOnly = true)
    ShiftPage listUpcoming(int page, int size) {
        var result = shifts.findByStatusInAndEndsAtAfter(
                UPCOMING, Instant.now(), PageRequest.of(page, size, EARLIEST_START_FIRST));
        return new ShiftPage(
                responses(result.getContent()), page, size, result.getTotalElements(), result.getTotalPages());
    }

    @Transactional
    ShiftResponse create(ShiftRequest request, UUID contactUserId) {
        var client = clients.find(request.clientId())
                .orElseThrow(() -> new InvalidFieldException("clientId", NOT_FOUND));
        if (client.location(request.locationId()).isEmpty()) {
            throw new InvalidFieldException("locationId", NOT_FOUND);
        }
        var qualificationIds = request.qualificationIds() == null ? Set.<UUID>of() : request.qualificationIds();
        var known = agencies.qualifications().stream().map(QualificationSummary::id).toList();
        if (!known.containsAll(qualificationIds)) {
            throw new InvalidFieldException("qualificationIds", NOT_FOUND);
        }

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
        return responses(List.of(shifts.saveAndFlush(shift))).getFirst();
    }

    @Transactional
    ShiftResponse publish(UUID shiftId) {
        var shift = shifts.findById(shiftId).orElseThrow(ShiftService::notFound);
        shift.publish();
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
