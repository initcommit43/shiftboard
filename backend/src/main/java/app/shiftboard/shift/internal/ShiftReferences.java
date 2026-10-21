package app.shiftboard.shift.internal;

import java.util.Set;
import java.util.UUID;

import app.shiftboard.agency.Agencies;
import app.shiftboard.agency.QualificationSummary;
import app.shiftboard.client.Clients;
import app.shiftboard.system.InvalidFieldException;
import org.springframework.stereotype.Component;

/** Checks that the client, location and qualifications of a shift or template belong to the agency. */
@Component
class ShiftReferences {

    private static final String NOT_FOUND = "not_found";

    private final Clients clients;
    private final Agencies agencies;

    ShiftReferences(Clients clients, Agencies agencies) {
        this.clients = clients;
        this.agencies = agencies;
    }

    /**
     * @throws InvalidFieldException {@code not_found} on {@code clientId}, on {@code locationId} when
     *         it is not a location of that client, or on {@code qualificationIds}
     */
    void check(UUID clientId, UUID locationId, Set<UUID> qualificationIds) {
        var client = clients.find(clientId).orElseThrow(() -> new InvalidFieldException("clientId", NOT_FOUND));
        if (client.location(locationId).isEmpty()) {
            throw new InvalidFieldException("locationId", NOT_FOUND);
        }
        var known = agencies.qualifications().stream().map(QualificationSummary::id).toList();
        if (!known.containsAll(qualificationIds)) {
            throw new InvalidFieldException("qualificationIds", NOT_FOUND);
        }
    }
}
