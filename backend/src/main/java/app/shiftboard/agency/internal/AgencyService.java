package app.shiftboard.agency.internal;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import app.shiftboard.agency.Agencies;
import app.shiftboard.agency.AgencyFeatures;
import app.shiftboard.agency.AgencySettings;
import app.shiftboard.agency.AgencySummary;
import app.shiftboard.agency.QualificationSummary;
import app.shiftboard.agency.TenantContext;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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

    @Override
    @Transactional(readOnly = true)
    public AgencyFeatures features() {
        return currentAgency().getFeatures();
    }

    /** Switches the features; one passed as {@code null} stays as it is. */
    @Transactional
    AgencyFeatures changeFeatures(boolean contactButton, Boolean checkIn) {
        var agency = currentAgency();
        var current = agency.getFeatures();
        agency.changeFeatures(new AgencyFeatures(contactButton, checkIn == null ? current.checkIn() : checkIn));
        return agency.getFeatures();
    }

    @Override
    @Transactional(readOnly = true)
    public AgencySettings settings() {
        return currentAgency().getSettings();
    }

    @Override
    @Transactional(readOnly = true)
    public List<UUID> ids() {
        return agencies.findAllIds();
    }

    @Transactional
    AgencySettings changeSettings(AgencySettings settings) {
        var agency = currentAgency();
        agency.changeSettings(settings);
        return agency.getSettings();
    }

    private Agency currentAgency() {
        return agencies.findById(TenantContext.require()).orElseThrow();
    }

    private static AgencySummary summary(Agency agency) {
        return new AgencySummary(agency.getId(), agency.getName(), agency.getFeatures());
    }
}
