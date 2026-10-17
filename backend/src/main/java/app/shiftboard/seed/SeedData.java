package app.shiftboard.seed;

import java.math.BigDecimal;
import java.time.LocalDate;
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
 * Two fictional agencies with their qualifications, settings, dashboard users, workers, clients,
 * locations, shifts and a few claims. The rows are written with plain SQL, like a migration would, because nothing in the
 * application creates agencies, dashboard users or clients yet. Runs once: a database that has
 * the demo agency is left alone.
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

        staff(agency, "admin.donau@example.com", "ADMIN", "Martina", "Leitner", null);
        var dispatcher = staff(
                agency, "dispatcher1.donau@example.com", "DISPATCHER", "Anna", "Berger", "+43 660 5550191");
        staff(agency, "dispatcher2.donau@example.com", "DISPATCHER", "Markus", "Huber", null);

        var logistics = client(agency, "Nordlicht Logistik");
        var warehouse = location(agency, logistics, "Zentrallager Linz", "Hafenstraße 12, 4020 Linz");
        var depot = location(agency, logistics, "Umschlagplatz Wels", "Terminalstraße 5, 4600 Wels");
        var hotel = client(agency, "Hotel Lindenhof");
        var ballroom = location(agency, hotel, "Bankettsaal", "Lindenallee 3, 4040 Linz");
        var catering = client(agency, "Genusswerk Catering");
        var hall = location(agency, catering, "Messehalle Wels", "Messeplatz 1, 4600 Wels");

        var warehouseHelp = shift(agency, logistics, warehouse, dispatcher, "Lagerunterstützung",
                "Sicherheitsschuhe mitbringen. Treffpunkt beim Tor 3.", 1, 6, 8, false, "16.50", 5, "PUBLISHED",
                lager);
        var weddingService = shift(agency, hotel, ballroom, dispatcher, "Service Hochzeit",
                "Schwarze Hose, weißes Hemd. Treffpunkt an der Rezeption.", 2, 16, 8, true, "15.00", 6, "PUBLISHED",
                service);
        var weddingBar = shift(agency, hotel, ballroom, dispatcher, "Barkeeper:in Hochzeit", null, 2, 17, 7, true,
                "17.50", 2, "PUBLISHED", bar);
        shift(agency, logistics, depot, dispatcher, "Staplerfahrer:in", "Staplerschein nicht vergessen.", 3, 7, 8,
                false, "19.00", 2, "PUBLISHED", lager, staplerschein);
        shift(agency, catering, hall, dispatcher, "Auf- und Abbau Messe", null, 5, 8, 6, true, "14.50", 8,
                "PUBLISHED");
        shift(agency, catering, hall, dispatcher, "Service Firmenfeier", null, 9, 17, 6, true, "15.50", 10, "DRAFT",
                service);
        // Took place three days ago, so that no-shows can be marked.
        var inventory = shift(agency, logistics, warehouse, dispatcher, "Inventur", null, -3, 7, 8, false, "16.50", 3,
                "COMPLETED", lager);

        var lena = worker(agency, 1, "Lena", "Hofer", "1996-03-14", "ACTIVE", 60, service, bar);
        var jakob = worker(agency, 2, "Jakob", "Steiner", "1988-11-02", "ACTIVE", 52, lager, staplerschein);
        worker(agency, 3, "Mira", "Aigner", "2001-07-23", "ACTIVE", 45, service);
        var felix = worker(agency, 4, "Felix", "Brandner", "1993-01-30", "ACTIVE", 31, bar);
        var sophie = worker(agency, 5, "Sophie", "Lechner", "1999-09-08", "ACTIVE", 24, service, bar);
        var paul = worker(agency, 6, "Paul", "Winkler", "1985-05-19", "ACTIVE", 17, lager);
        worker(agency, 7, "Simon", "Egger", "1979-12-11", "INACTIVE", 12, service);
        worker(agency, 8, "Emma", "Koller", "2003-04-27", "PENDING", 3, service);
        worker(agency, 9, "Lukas", "Reiter", "1991-08-05", "PENDING", 2, lager, staplerschein);
        worker(agency, 10, "Nina", "Hauser", "2005-02-16", "PENDING", 1);
        worker(agency, 11, "David", "Pichler", "1997-10-21", "PENDING", 0, bar);

        // Lena has a claim of her own, the warehouse shift has two spots taken (one confirmed) and the
        // bar is full. Jakob and Paul worked the inventory.
        claim(agency, weddingService, lena, "PENDING");
        claim(agency, warehouseHelp, jakob, "CONFIRMED");
        claim(agency, warehouseHelp, paul, "PENDING");
        claim(agency, weddingBar, felix, "PENDING");
        claim(agency, weddingBar, sophie, "PENDING");
        claim(agency, inventory, jakob, "COMPLETED");
        claim(agency, inventory, paul, "COMPLETED");
    }

    private void seedAlpenEvents() {
        var agency = agency("Alpen Events", ALPEN_SIGNUP_CODE);
        // Confirms claims right away and lets workers drop out until twelve hours before the start.
        jdbc.sql("update agency set settings = '{\"autoConfirm\": true, \"cancellationDeadlineHours\": 12}' where id = ?")
                .param(agency).update();
        var service = qualification(agency, "Service");
        qualification(agency, "Security");

        var dispatcher = staff(
                agency, "dispatcher.alpen@example.com", "DISPATCHER", "Julia", "Moser", "+43 660 5550192");

        var arena = client(agency, "Gipfelarena");
        var stadium = location(agency, arena, "Haupteingang", "Arenaweg 2, 6020 Innsbruck");
        shift(agency, arena, stadium, dispatcher, "Einlass Konzert", null, 4, 17, 6, true, "15.00", 12, "PUBLISHED",
                service);

        worker(agency, 12, "Tobias", "Gruber", "1990-06-09", "ACTIVE", 20, service);
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
        return staff(agencyId, email, role, null, null, null);
    }

    /** A dispatcher or admin. Unlike workers, they carry their name and phone on the account. */
    private UUID staff(UUID agencyId, String email, String role, String firstName, String lastName, String phone) {
        return jdbc.sql("""
                insert into user_account (id, agency_id, email, password_hash, role, first_name, last_name, phone)
                values (uuidv7(), ?, ?, ?, ?, ?, ?, ?) returning id
                """).params(agencyId, email, passwordHash, role, firstName, lastName, phone)
                .query(UUID.class).single();
    }

    private UUID client(UUID agencyId, String name) {
        return jdbc.sql("insert into client (id, agency_id, name) values (uuidv7(), ?, ?) returning id")
                .params(agencyId, name).query(UUID.class).single();
    }

    private UUID location(UUID agencyId, UUID clientId, String name, String address) {
        return jdbc.sql("""
                insert into location (id, agency_id, client_id, name, address)
                values (uuidv7(), ?, ?, ?, ?) returning id
                """).params(agencyId, clientId, name, address).query(UUID.class).single();
    }

    /** A shift that starts {@code inDays} days from today at {@code startHour} o'clock in Vienna. */
    private UUID shift(
            UUID agencyId, UUID clientId, UUID locationId, UUID contactUserId, String title, String description,
            int inDays, int startHour, int hours, boolean endIsEstimate, String hourlyRate, int slots, String status,
            UUID... qualificationIds) {
        var shiftId = jdbc.sql("""
                with start as (
                    select (date_trunc('day', now() at time zone 'Europe/Vienna')
                            + make_interval(days => ?, hours => ?)) at time zone 'Europe/Vienna' as at
                )
                insert into shift (
                    id, agency_id, client_id, location_id, contact_user_id, title, description, starts_at, ends_at,
                    end_is_estimate, hourly_rate, slots, status)
                select uuidv7(), ?, ?, ?, ?, ?, ?, start.at, start.at + make_interval(hours => ?), ?, ?, ?, ?
                from start
                returning id
                """)
                .params(
                        inDays, startHour, agencyId, clientId, locationId, contactUserId, title, description, hours,
                        endIsEstimate, new BigDecimal(hourlyRate), slots, status)
                .query(UUID.class).single();
        for (var qualificationId : qualificationIds) {
            jdbc.sql("insert into shift_qualification (shift_id, qualification_id) values (?, ?)")
                    .params(shiftId, qualificationId).update();
        }
        return shiftId;
    }

    /**
     * A claim of the worker on the shift, with its spot counted. Claimed a week before the start
     * at the latest, decided on right away unless pending.
     */
    private void claim(UUID agencyId, UUID shiftId, UUID workerId, String status) {
        jdbc.sql("""
                insert into assignment (
                    id, agency_id, shift_id, worker_id, status, starts_at, ends_at, claimed_at, decided_at)
                select uuidv7(), ?, s.id, ?, ?, s.starts_at, s.ends_at, c.at, case when ? = 'PENDING' then null else c.at end
                from shift s, lateral (select least(now(), s.starts_at - interval '7 days') as at) c
                where s.id = ?
                """).params(agencyId, workerId, status, status, shiftId).update();
        jdbc.sql("update shift set taken_slots = taken_slots + 1 where id = ?").param(shiftId).update();
    }

    private UUID worker(
            UUID agencyId, int number, String firstName, String lastName, String dateOfBirth, String status,
            int signedUpDaysAgo, UUID... qualificationIds) {
        var email = (firstName + "." + lastName + "@example.com").toLowerCase(Locale.ROOT);
        var phone = "+43 660 55501%02d".formatted(number);
        var accountId = account(agencyId, email, "WORKER");
        var workerId = jdbc.sql("""
                insert into worker (
                    id, agency_id, user_account_id, first_name, last_name, date_of_birth, phone, status, created_at)
                values (uuidv7(), ?, ?, ?, ?, ?, ?, ?, now() - make_interval(days => ?)) returning id
                """)
                .params(
                        agencyId, accountId, firstName, lastName, LocalDate.parse(dateOfBirth), phone, status,
                        signedUpDaysAgo)
                .query(UUID.class).single();
        for (var qualificationId : qualificationIds) {
            jdbc.sql("insert into worker_qualification (worker_id, qualification_id) values (?, ?)")
                    .params(workerId, qualificationId).update();
        }
        return workerId;
    }
}
