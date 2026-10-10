package app.shiftboard.seed;

import java.util.Locale;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * Two fictional agencies with their qualifications, dashboard users and workers. The rows are
 * written with plain SQL, like a migration would, because nothing in the application creates
 * agencies or dashboard users yet. Runs once: a database that has the demo agency is left alone.
 */
@Component
@Profile("local")
class SeedData implements ApplicationRunner {

    static final String DONAU_SIGNUP_CODE = "donau-demo";
    static final String ALPEN_SIGNUP_CODE = "alpen-demo";

    private static final Logger log = LoggerFactory.getLogger(SeedData.class);

    private final JdbcClient jdbc;
    private final String passwordHash;

    SeedData(JdbcClient jdbc, PasswordEncoder passwordEncoder, @Value("${shiftboard.seed.password}") String password) {
        this.jdbc = jdbc;
        this.passwordHash = passwordEncoder.encode(password);
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        var seeded = jdbc.sql("select exists (select 1 from agency where signup_code = ?)")
                .param(DONAU_SIGNUP_CODE).query(Boolean.class).single();
        if (seeded) {
            return;
        }
        seedDonauPersonal();
        seedAlpenEvents();
        log.info("Seeded the demo agencies");
    }

    private void seedDonauPersonal() {
        var agency = agency("Donau Personal", DONAU_SIGNUP_CODE);
        var service = qualification(agency, "Service");
        var bar = qualification(agency, "Bar");
        var lager = qualification(agency, "Lager");
        var staplerschein = qualification(agency, "Staplerschein");

        account(agency, "admin.donau@example.com", "ADMIN");
        account(agency, "dispatcher1.donau@example.com", "DISPATCHER");
        account(agency, "dispatcher2.donau@example.com", "DISPATCHER");

        worker(agency, 1, "Lena", "Hofer", "ACTIVE", 60, service, bar);
        worker(agency, 2, "Jakob", "Steiner", "ACTIVE", 52, lager, staplerschein);
        worker(agency, 3, "Mira", "Aigner", "ACTIVE", 45, service);
        worker(agency, 4, "Felix", "Brandner", "ACTIVE", 31, bar);
        worker(agency, 5, "Sophie", "Lechner", "ACTIVE", 24, service, bar);
        worker(agency, 6, "Paul", "Winkler", "ACTIVE", 17, lager);
        worker(agency, 7, "Simon", "Egger", "INACTIVE", 12, service);
        worker(agency, 8, "Emma", "Koller", "PENDING", 3, service);
        worker(agency, 9, "Lukas", "Reiter", "PENDING", 2, lager, staplerschein);
        worker(agency, 10, "Nina", "Hauser", "PENDING", 1);
        worker(agency, 11, "David", "Pichler", "PENDING", 0, bar);
    }

    private void seedAlpenEvents() {
        var agency = agency("Alpen Events", ALPEN_SIGNUP_CODE);
        var service = qualification(agency, "Service");
        qualification(agency, "Security");

        account(agency, "dispatcher.alpen@example.com", "DISPATCHER");

        worker(agency, 12, "Tobias", "Gruber", "ACTIVE", 20, service);
    }

    private UUID agency(String name, String signupCode) {
        return jdbc.sql("insert into agency (id, name, signup_code) values (uuidv7(), ?, ?) returning id")
                .params(name, signupCode).query(UUID.class).single();
    }

    private UUID qualification(UUID agencyId, String name) {
        return jdbc.sql("insert into qualification (id, agency_id, name) values (uuidv7(), ?, ?) returning id")
                .params(agencyId, name).query(UUID.class).single();
    }

    private UUID account(UUID agencyId, String email, String role) {
        return jdbc.sql("""
                insert into user_account (id, agency_id, email, password_hash, role)
                values (uuidv7(), ?, ?, ?, ?) returning id
                """).params(agencyId, email, passwordHash, role).query(UUID.class).single();
    }

    private void worker(
            UUID agencyId, int number, String firstName, String lastName, String status, int signedUpDaysAgo,
            UUID... qualificationIds) {
        var email = (firstName + "." + lastName + "@example.com").toLowerCase(Locale.ROOT);
        var phone = "+43 660 55501%02d".formatted(number);
        var accountId = account(agencyId, email, "WORKER");
        var workerId = jdbc.sql("""
                insert into worker (id, agency_id, user_account_id, first_name, last_name, phone, status, created_at)
                values (uuidv7(), ?, ?, ?, ?, ?, ?, now() - make_interval(days => ?)) returning id
                """)
                .params(agencyId, accountId, firstName, lastName, phone, status, signedUpDaysAgo)
                .query(UUID.class).single();
        for (var qualificationId : qualificationIds) {
            jdbc.sql("insert into worker_qualification (worker_id, qualification_id) values (?, ?)")
                    .params(workerId, qualificationId).update();
        }
    }
}
