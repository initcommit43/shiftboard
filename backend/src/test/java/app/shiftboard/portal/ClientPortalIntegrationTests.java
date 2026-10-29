package app.shiftboard.portal;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Duration;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import app.shiftboard.IntegrationTest;
import app.shiftboard.TestData;
import app.shiftboard.identity.Role;
import app.shiftboard.identity.TokenPair;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;

@SuppressWarnings("unchecked")
class ClientPortalIntegrationTests extends IntegrationTest {

    static final Instant IN_TWO_DAYS = Instant.now().plus(Duration.ofDays(2)).truncatedTo(ChronoUnit.SECONDS);

    TestData.Agency agency;

    TokenPair admin;

    TokenPair dispatcher;

    UUID clientId;

    UUID locationId;

    UUID otherClientId;

    UUID otherLocationId;

    TokenPair clientUser;

    @BeforeEach
    void createAgency() {
        agency = data.agency("Donau Personal");
        admin = login(data.account(agency, Role.ADMIN), DASHBOARD);
        dispatcher = login(data.account(agency, Role.DISPATCHER), DASHBOARD);
        clientId = data.client(agency, "Nordlicht Logistik");
        locationId = data.location(agency, clientId, "Zentrallager Linz", "Hafenstraße 12, 4020 Linz");
        otherClientId = data.client(agency, "Hafen Events");
        otherLocationId = data.location(agency, otherClientId, "Messehalle", "Messeplatz 1, 4020 Linz");
        client.put().uri("/api/v1/agency/features")
                .headers(headers -> headers.setBearerAuth(admin.accessToken()))
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of("contactButton", false, "clientPortal", true))
                .exchange()
                .expectStatus().isOk();
        clientUser = clientUser(clientId);
    }

    @Test
    void aClientSeesItsOwnShiftsWithoutDraftsOrRates() {
        var later = publish(clientId, locationId, IN_TWO_DAYS.plus(Duration.ofDays(1)), 2, "Inventur");
        var soon = publish(clientId, locationId, IN_TWO_DAYS, 3, "Lagerunterstützung");
        var cancelled = publish(clientId, locationId, IN_TWO_DAYS.plus(Duration.ofDays(2)), 1, "Kommissionierung");
        post("/api/v1/shifts/" + cancelled + "/cancel", dispatcher).expectStatus().isOk();
        create(clientId, locationId, IN_TWO_DAYS, 1, "Entwurf", false);
        publish(otherClientId, otherLocationId, IN_TWO_DAYS, 4, "Messeaufbau");
        var past = publish(clientId, locationId, IN_TWO_DAYS, 2, "Wareneingang");
        jdbc.sql("""
                update shift set starts_at = starts_at - interval '5 days', ends_at = ends_at - interval '5 days',
                status = 'COMPLETED' where id = ?
                """).param(past).update();

        var lena = activeWorker("Lena", "Hofer");
        var jonas = activeWorker("Jonas", "Berger");
        approve(soon, claim(soon, lena));
        claim(soon, jonas); // pending, doesn't count

        var upcoming = get("/api/v1/client/shifts", clientUser)
                .expectStatus().isOk()
                .expectBody(Map.class).returnResult().getResponseBody();
        var content = (List<Map<String, Object>>) upcoming.get("content");
        assertThat(content).extracting(shift -> shift.get("id"))
                .containsExactly(soon.toString(), later.toString(), cancelled.toString());
        var first = content.getFirst();
        assertThat(first.get("title")).isEqualTo("Lagerunterstützung");
        assertThat(first.get("status")).isEqualTo("PUBLISHED");
        assertThat(first.get("slots")).isEqualTo(3);
        assertThat(first.get("confirmedCount")).isEqualTo(1);
        assertThat(((Map<?, ?>) first.get("location")).get("name")).isEqualTo("Zentrallager Linz");
        assertThat(first).doesNotContainKeys("hourlyRateCents", "takenSlots", "contact", "client");
        assertThat(content.getLast().get("status")).isEqualTo("CANCELLED");

        get("/api/v1/client/shifts?period=PAST", clientUser)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalElements").isEqualTo(1)
                .jsonPath("$.content[0].id").isEqualTo(past.toString())
                .jsonPath("$.content[0].status").isEqualTo("COMPLETED");
    }

    @Test
    void theDetailNamesTheConfirmedWorkersOnly() {
        var shiftId = publish(clientId, locationId, IN_TWO_DAYS, 3, "Lagerunterstützung");
        var lena = activeWorker("Lena", "Hofer");
        var jonas = activeWorker("Jonas", "Berger");
        var emma = activeWorker("Emma", "Koller");
        approve(shiftId, claim(shiftId, lena));
        approve(shiftId, claim(shiftId, jonas));
        claim(shiftId, emma);

        var detail = get("/api/v1/client/shifts/" + shiftId, clientUser)
                .expectStatus().isOk()
                .expectBody(Map.class).returnResult().getResponseBody();
        assertThat(detail.get("description")).isEqualTo("Sicherheitsschuhe mitbringen.");
        assertThat(detail.get("confirmedCount")).isEqualTo(2);
        assertThat((List<Map<String, Object>>) detail.get("confirmedWorkers")).containsExactly(
                Map.of("firstName", "Jonas", "lastName", "Berger"),
                Map.of("firstName", "Lena", "lastName", "Hofer"));
        assertThat((Map<String, Object>) detail).doesNotContainKeys("hourlyRateCents", "takenSlots", "contact");
    }

    @Test
    void otherClientsShiftsAndDraftsAreNotFound() {
        var draft = create(clientId, locationId, IN_TWO_DAYS, 1, "Entwurf", false);
        var foreign = publish(otherClientId, otherLocationId, IN_TWO_DAYS, 4, "Messeaufbau");
        var otherUser = clientUser(otherClientId);

        expectProblem(get("/api/v1/client/shifts/" + draft, clientUser), 404, "shift_not_found");
        expectProblem(get("/api/v1/client/shifts/" + foreign, clientUser), 404, "shift_not_found");
        expectProblem(get("/api/v1/client/shifts/" + UUID.randomUUID(), clientUser), 404, "shift_not_found");
        get("/api/v1/client/shifts/" + foreign, otherUser).expectStatus().isOk();
        get("/api/v1/client/shifts", otherUser).expectStatus().isOk()
                .expectBody().jsonPath("$.content[0].id").isEqualTo(foreign.toString());

        // Another agency's client user with the same view sees nothing of this one.
        var otherAgency = data.agency("Inn Staffing");
        var otherAdmin = login(data.account(otherAgency, Role.ADMIN), DASHBOARD);
        client.put().uri("/api/v1/agency/features")
                .headers(headers -> headers.setBearerAuth(otherAdmin.accessToken()))
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of("contactButton", false, "clientPortal", true))
                .exchange().expectStatus().isOk();
        var innClient = data.client(otherAgency, "Nordlicht Logistik");
        var innUser = clientUser(otherAgency, otherAdmin, innClient);
        get("/api/v1/client/shifts", innUser).expectStatus().isOk()
                .expectBody().jsonPath("$.totalElements").isEqualTo(0);
        expectProblem(get("/api/v1/client/shifts/" + foreign, innUser), 404, "shift_not_found");
    }

    @Test
    void aClientListsOnlyItsOwnLocationsByName() {
        data.location(agency, clientId, "Außenlager Enns", "Hafenweg 3, 4470 Enns");

        get("/api/v1/client/locations", clientUser)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.length()").isEqualTo(2)
                .jsonPath("$[0].name").isEqualTo("Außenlager Enns")
                .jsonPath("$[1].name").isEqualTo("Zentrallager Linz")
                .jsonPath("$[1].address").isEqualTo("Hafenstraße 12, 4020 Linz");
        expectProblem(get("/api/v1/client/locations", dispatcher), 403, "forbidden");
    }

    // --- helpers -------------------------------------------------------------------------

    private TokenPair clientUser(UUID forClient) {
        return clientUser(agency, dispatcher, forClient);
    }

    private TokenPair clientUser(TestData.Agency inAgency, TokenPair staff, UUID forClient) {
        var invitation = post("/api/v1/clients/" + forClient + "/users", staff,
                Map.of("firstName", "Petra", "lastName", "Wimmer", "email", TestData.email()))
                .expectStatus().isCreated()
                .expectBody(Map.class).returnResult().getResponseBody();
        return client.post().uri("/api/v1/client-setup/{code}", invitation.get("setupCode"))
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of("password", "lagerhalle-2026"))
                .exchange()
                .expectStatus().isOk()
                .expectBody(TokenPair.class).returnResult().getResponseBody();
    }

    private TokenPair activeWorker(String firstName, String lastName) {
        var request = signupRequest(TestData.email());
        request.put("firstName", firstName);
        request.put("lastName", lastName);
        var tokens = postSignup(agency.signupCode(), request)
                .expectStatus().isCreated()
                .expectBody(TokenPair.class).returnResult().getResponseBody();
        post("/api/v1/workers/" + workerId(tokens) + "/approve", dispatcher).expectStatus().isOk();
        return tokens;
    }

    private UUID publish(UUID forClient, UUID atLocation, Instant startsAt, int slots, String title) {
        return create(forClient, atLocation, startsAt, slots, title, true);
    }

    private UUID create(UUID forClient, UUID atLocation, Instant startsAt, int slots, String title, boolean publish) {
        var request = new HashMap<String, Object>();
        request.put("clientId", forClient);
        request.put("locationId", atLocation);
        request.put("title", title);
        request.put("description", "Sicherheitsschuhe mitbringen.");
        request.put("startsAt", startsAt.toString());
        request.put("endsAt", startsAt.plus(Duration.ofHours(8)).toString());
        request.put("hourlyRateCents", 1650);
        request.put("slots", slots);
        request.put("publish", publish);
        var created = post("/api/v1/shifts", dispatcher, request)
                .expectStatus().isCreated()
                .expectBody(Map.class).returnResult().getResponseBody();
        return UUID.fromString((String) created.get("id"));
    }

    private UUID claim(UUID shiftId, TokenPair worker) {
        var claimed = post("/api/v1/worker/shifts/" + shiftId + "/claim", worker)
                .expectStatus().isCreated()
                .expectBody(Map.class).returnResult().getResponseBody();
        return UUID.fromString((String) ((Map<?, ?>) claimed.get("assignment")).get("id"));
    }

    private void approve(UUID shiftId, UUID assignmentId) {
        post("/api/v1/shifts/" + shiftId + "/assignments/" + assignmentId + "/approve", dispatcher)
                .expectStatus().isOk();
    }
}
