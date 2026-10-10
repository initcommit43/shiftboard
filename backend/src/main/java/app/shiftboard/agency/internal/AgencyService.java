package app.shiftboard.agency.internal;

import java.util.List;
import java.util.Optional;

import app.shiftboard.agency.Agencies;
import app.shiftboard.agency.AgencySummary;
import app.shiftboard.agency.QualificationSummary;
import app.shiftboard.agency.TenantContext;
import org.springframework.stereotype.Service;

@Service
class AgencyService implements Agencies {

    private final AgencyRepository agencies;
    private final QualificationRepository qualifications;

    AgencyService(AgencyRepository agencies, QualificationRepository qualifications) {
        this.agencies = agencies;
        this.qualifications = qualifications;
    }

    @Override
    public Optional<AgencySummary> findBySignupCode(String signupCode) {
        return agencies.findBySignupCode(signupCode).map(AgencyService::summary);
    }

    @Override
    public AgencySummary current() {
        return agencies.findById(TenantContext.require()).map(AgencyService::summary).orElseThrow();
    }

    @Override
    public List<QualificationSummary> qualifications() {
        return qualifications.findAllByOrderByName().stream()
                .map(qualification -> new QualificationSummary(qualification.getId(), qualification.getName()))
                .toList();
    }

    private static AgencySummary summary(Agency agency) {
        return new AgencySummary(agency.getId(), agency.getName());
    }
}
