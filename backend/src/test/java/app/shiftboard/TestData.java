package app.shiftboard;

import java.util.UUID;

import app.shiftboard.identity.Role;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.security.crypto.password.PasswordEncoder;

/**
 * Creates what no endpoint can create yet: agencies, their qualifications and who has them,
 * dispatchers and admins, clients and their locations.
 * Everything is fictional and unique per call, so tests do not see each other's data.
 */
public class TestData {

    public static final String PASSWORD = "correct-horse-battery";

    private final JdbcClient jdbc;
    private final String passwordHash;

    TestData(JdbcClient jdbc, PasswordEncoder passwordEncoder) {
        this.jdbc = jdbc;
        this.passwordHash = passwordEncoder.encode(PASSWORD);
    }

    public record Agency(UUID id, String name, String signupCode) {
    }

    public Agency agency(String name) {
        var agency = new Agency(UUID.randomUUID(), name, "code-" + UUID.randomUUID());
        jdbc.sql("insert into agency (id, name, signup_code) values (?, ?, ?)")
                .params(agency.id(), agency.name(), agency.signupCode())
                .update();
        return agency;
    }

    public UUID qualification(Agency agency, String name) {
        var id = UUID.randomUUID();
        jdbc.sql("insert into qualification (id, agency_id, name) values (?, ?, ?)")
                .params(id, agency.id(), name)
                .update();
        return id;
    }

    public void qualify(UUID workerId, UUID... qualificationIds) {
        for (var qualificationId : qualificationIds) {
            jdbc.sql("insert into worker_qualification (worker_id, qualification_id) values (?, ?)")
                    .params(workerId, qualificationId)
                    .update();
        }
    }

    public UUID client(Agency agency, String name) {
        var id = UUID.randomUUID();
        jdbc.sql("insert into client (id, agency_id, name) values (?, ?, ?)")
                .params(id, agency.id(), name)
                .update();
        return id;
    }

    public UUID location(Agency agency, UUID clientId, String name, String address) {
        var id = UUID.randomUUID();
        jdbc.sql("insert into location (id, agency_id, client_id, name, address) values (?, ?, ?, ?, ?)")
                .params(id, agency.id(), clientId, name, address)
                .update();
        return id;
    }

    /** Creates an account of Anna Berger with {@link #PASSWORD} and returns its email. */
    public String account(Agency agency, Role role) {
        return account(agency, role, "Anna", "Berger", "+43 660 5550191");
    }

    /** Creates an account with {@link #PASSWORD} and returns its email. */
    public String account(Agency agency, Role role, String firstName, String lastName, String phone) {
        var email = email();
        jdbc.sql("""
                insert into user_account (id, agency_id, email, password_hash, role, first_name, last_name, phone)
                values (?, ?, ?, ?, ?, ?, ?, ?)
                """)
                .params(UUID.randomUUID(), agency.id(), email, passwordHash, role.name(), firstName, lastName, phone)
                .update();
        return email;
    }

    public static String email() {
        return "user-" + UUID.randomUUID() + "@example.com";
    }
}
