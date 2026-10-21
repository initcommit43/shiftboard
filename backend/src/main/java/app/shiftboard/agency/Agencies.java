package app.shiftboard.agency;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface Agencies {

    Optional<AgencySummary> findBySignupCode(String signupCode);

    /** The agency bound to the {@link TenantContext}. */
    AgencySummary current();

    /** The qualifications of the current agency, sorted by name. */
    List<QualificationSummary> qualifications();

    /** The optional features of the current agency. */
    AgencyFeatures features();

    /** The workflow settings of the current agency. */
    AgencySettings settings();

    /** The ids of all agencies, for work that runs for each of them outside a request. */
    List<UUID> ids();
}
