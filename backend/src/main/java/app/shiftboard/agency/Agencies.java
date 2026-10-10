package app.shiftboard.agency;

import java.util.List;
import java.util.Optional;

public interface Agencies {

    Optional<AgencySummary> findBySignupCode(String signupCode);

    /** The agency bound to the {@link TenantContext}. */
    AgencySummary current();

    /** The qualifications of the current agency, sorted by name. */
    List<QualificationSummary> qualifications();
}
