package app.shiftboard.shift;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import app.shiftboard.agency.QualificationSummary;
import app.shiftboard.client.LocationDetails;
import app.shiftboard.identity.StaffContact;

/**
 * A shift with everything a worker gets to see of it.
 *
 * @param status          {@code PUBLISHED}, {@code COMPLETED} or {@code CANCELLED}; workers never see a draft
 * @param hourlyRateCents gross pay per hour in euro cents
 * @param contact         the dispatcher to ask about the shift
 */
public record ShiftDetails(
        UUID id,
        String title,
        String description,
        String status,
        Client client,
        LocationDetails location,
        Instant startsAt,
        Instant endsAt,
        boolean endIsEstimate,
        int hourlyRateCents,
        int slots,
        int takenSlots,
        List<QualificationSummary> qualifications,
        StaffContact contact) {

    public record Client(UUID id, String name) {
    }
}
