package app.shiftboard.agency;

import java.util.UUID;

/**
 * @param features the optional features the agency has switched on
 */
public record AgencySummary(UUID id, String name, AgencyFeatures features) {
}
