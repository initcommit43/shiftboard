package app.shiftboard.shift.internal;

import java.time.Instant;

import app.shiftboard.agency.Agencies;
import app.shiftboard.agency.TenantContext;
import net.javacrumbs.shedlock.spring.annotation.SchedulerLock;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * Completes published shifts once they have ended, agency by agency. Safe to run any number of
 * times and on several instances: ShedLock lets one instance run it at a time, and a shift that is
 * already completed is not looked at again.
 */
@Component
public class ShiftCompletionJob {

    /** How many shifts are completed per agency and query, so that a backlog is worked off in parts. */
    private static final int BATCH = 100;

    private final Agencies agencies;

    private final ShiftService shiftService;

    ShiftCompletionJob(Agencies agencies, ShiftService shiftService) {
        this.agencies = agencies;
        this.shiftService = shiftService;
    }

    @Scheduled(fixedDelayString = "${shiftboard.jobs.complete-shifts-every:PT1M}")
    @SchedulerLock(name = "completeShifts", lockAtMostFor = "PT10M")
    void run() {
        completeEndedShifts(Instant.now());
    }

    /** Completes what has ended by the given time, in every agency. Returns how many shifts were completed. */
    public int completeEndedShifts(Instant now) {
        var completed = 0;
        for (var agencyId : agencies.ids()) {
            try (var _ = TenantContext.bind(agencyId)) {
                int done;
                do {
                    done = shiftService.completeEnded(now, BATCH);
                    completed += done;
                } while (done == BATCH);
            }
        }
        return completed;
    }
}
