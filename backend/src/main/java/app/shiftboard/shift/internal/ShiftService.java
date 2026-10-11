package app.shiftboard.shift.internal;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import app.shiftboard.agency.Agencies;
import app.shiftboard.agency.QualificationSummary;
import app.shiftboard.client.Clients;
import app.shiftboard.shift.internal.ShiftController.ClientSummary;
import app.shiftboard.shift.internal.ShiftController.ShiftPage;
import app.shiftboard.shift.internal.ShiftController.ShiftRequest;
import app.shiftboard.shift.internal.ShiftController.ShiftResponse;
import app.shiftboard.system.ApiException;
import app.shiftboard.system.InvalidFieldException;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
class ShiftService {

    private static final Sort EARLIEST_START_FIRST = Sort.by("startsAt", "id");
    private static final List<ShiftStatus> UPCOMING = List.of(ShiftStatus.DRAFT, ShiftStatus.PUBLISHED);
    private static final String NOT_FOUND = "not_found";

    private final ShiftRepository shifts;
    private final Clients clients;
    private final Agencies agencies;

    ShiftService(ShiftRepository shifts, Clients clients, Agencies agencies) {
        this.shifts = shifts;
        this.clients = clients;
        this.agencies = agencies;
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
        var shift = shifts.findById(shiftId)
                .orElseThrow(() -> new ApiException(
                        HttpStatus.NOT_FOUND, "shift_not_found", "The agency has no shift with this id."));
        shift.publish();
        return responses(List.of(shift)).getFirst();
    }

    // Clients, locations and qualification names come from their modules in one call each,
    // whatever the number of shifts.
    private List<ShiftResponse> responses(List<Shift> page) {
        var clientsById = clients.findAll(page.stream().map(Shift::getClientId).distinct().toList());
        var qualifications = agencies.qualifications();
        return page.stream()
                .map(shift -> {
                    var client = clientsById.get(shift.getClientId());
                    return new ShiftResponse(
                            shift.getId(),
                            shift.getTitle(),
                            shift.getDescription(),
                            shift.getStatus(),
                            new ClientSummary(client.id(), client.name()),
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
                            shift.getCreatedAt());
                })
                .toList();
    }
}
