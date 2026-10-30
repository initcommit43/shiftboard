package app.shiftboard.staffrequest;

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
class StaffRequestIntegrationTests extends IntegrationTest {

    static final Instant IN_TWO_DAYS = Instant.now().plus(Duration.ofDays(2)).truncatedTo(ChronoUnit.SECONDS);

    TestData.Agency agency;

    TokenPair dispatcher;

    UUID clientId;

    UUID locationId;

    UUID otherClientId;

    UUID otherLocationId;

    TokenPair clientUser;

    @BeforeEach
    void createAgency() {
        agency = data.agency("Donau Personal");
        var admin = login(data.account(agency, Role.ADMIN), DASHBOARD);
        dispatcher = login(data.account(agency, Role.DISPATCHER), DASHBOARD);
        clientId = data.client(agency, "Nordlicht Logistik");
        locationId = data.location(agency, clientId, "Zentrallager Linz", "Hafenstraße 12, 4020 Linz");
        otherClientId = data.client(agency, "Hafen Events");
        otherLocationId = data.location(agency, otherClientId, "Messehalle", "Messeplatz 1, 4020 Linz");
        switchPortalOn(admin);
        clientUser = clientUser(dispatcher, clientId);
    }

    @Test
    void dispatchersSeeOpenRequestsEarliestStartFirst() {
        var later = send(IN_TWO_DAYS.plus(Duration.ofDays(3)), 2);
        var soon = send(IN_TWO_DAYS, 4);
        var withdrawn = send(IN_TWO_DAYS.plus(Duration.ofDays(1)), 1);
        post("/api/v1/client/staff-requests/" + withdrawn + "/withdraw", clientUser).expectStatus().isOk();

        var open = get("/api/v1/staff-requests", dispatcher)
                .expectStatus().isOk()
                .expectBody(Map.class).returnResult().getResponseBody();

        assertThat(open.get("totalElements")).isEqualTo(2);
        var content = (List<Map<String, Object>>) open.get("content");
        assertThat(content).extracting(request -> request.get("id")).containsExactly(soon, later);
        var first = content.getFirst();
        assertThat(((Map<?, ?>) first.get("client")).get("name")).isEqualTo("Nordlicht Logistik");
        assertThat(first.get("role")).isEqualTo("Lagerhelfer");
        assertThat(first.get("workerCount")).isEqualTo(4);
        assertThat(first.get("requestedBy")).isEqualTo("Petra Wimmer");

        get("/api/v1/staff-requests?status=WITHDRAWN", dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalElements").isEqualTo(1)
                .jsonPath("$.content[0].id").isEqualTo(withdrawn);
        get("/api/v1/staff-requests/" + soon, dispatcher)
                .expectStatus().isOk()
                .expectBody().jsonPath("$.notes").isEqualTo("Rampe 3.");
    }

    @Test
    void aDispatcherTurnsARequestIntoAShift() {
        var requestId = send(IN_TWO_DAYS, 3);

        var shift = post("/api/v1/staff-requests/" + requestId + "/shift", dispatcher, shift(clientId, locationId, true))
                .expectStatus().isCreated()
                .expectBody(Map.class).returnResult().getResponseBody();

        assertThat(shift.get("status")).isEqualTo("PUBLISHED");
        assertThat(shift.get("slots")).isEqualTo(3);
        var request = get("/api/v1/staff-requests/" + requestId, dispatcher)
                .expectStatus().isOk()
                .expectBody(Map.class).returnResult().getResponseBody();
        assertThat(request.get("status")).isEqualTo("ACCEPTED");
        assertThat(request.get("shiftId")).isEqualTo(shift.get("id"));
        assertThat(request.get("decidedAt")).isNotNull();
        get("/api/v1/staff-requests", dispatcher)
                .expectStatus().isOk()
                .expectBody().jsonPath("$.totalElements").isEqualTo(0);

        get("/api/v1/client/staff-requests", clientUser)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[0].status").isEqualTo("ACCEPTED")
                .jsonPath("$.content[0].shiftId").isEqualTo(shift.get("id"));
        get("/api/v1/client/shifts/" + shift.get("id"), clientUser).expectStatus().isOk();
    }

    @Test
    void theClientGetsTheShiftOnlyOnceItIsPublished() {
        var requestId = send(IN_TWO_DAYS, 3);
        var draft = post("/api/v1/staff-requests/" + requestId + "/shift", dispatcher, shift(clientId, locationId, false))
                .expectStatus().isCreated()
                .expectBody(Map.class).returnResult().getResponseBody();

        var listed = get("/api/v1/client/staff-requests", clientUser)
                .expectStatus().isOk()
                .expectBody(Map.class).returnResult().getResponseBody();
        var request = ((List<Map<String, Object>>) listed.get("content")).getFirst();
        assertThat(request.get("status")).isEqualTo("ACCEPTED");
        assertThat(request).doesNotContainKey("shiftId");

        post("/api/v1/shifts/" + draft.get("id") + "/publish", dispatcher).expectStatus().isOk();
        get("/api/v1/client/staff-requests", clientUser)
                .expectStatus().isOk()
                .expectBody().jsonPath("$.content[0].shiftId").isEqualTo(draft.get("id"));
    }

    @Test
    void aShiftForAnotherClientIsRejectedAndNotKept() {
        var requestId = send(IN_TWO_DAYS, 3);

        expectProblem(post("/api/v1/staff-requests/" + requestId + "/shift", dispatcher,
                shift(otherClientId, otherLocationId, true)), 400, "validation_failed")
                .jsonPath("$.errors[0].field").isEqualTo("clientId")
                .jsonPath("$.errors[0].code").isEqualTo("not_request_client");

        assertThat(shiftCount()).isZero();
        get("/api/v1/staff-requests/" + requestId, dispatcher)
                .expectStatus().isOk()
                .expectBody().jsonPath("$.status").isEqualTo("OPEN");
    }

    @Test
    void aWithdrawnRequestCannotBecomeAShift() {
        var requestId = send(IN_TWO_DAYS, 3);
        post("/api/v1/client/staff-requests/" + requestId + "/withdraw", clientUser).expectStatus().isOk();

        expectProblem(post("/api/v1/staff-requests/" + requestId + "/shift", dispatcher,
                shift(clientId, locationId, true)), 409, "staff_request_not_open");
        expectProblem(post("/api/v1/staff-requests/" + requestId + "/decline", dispatcher,
                Map.of("reason", "Zu spät.")), 409, "staff_request_not_open");

        assertThat(shiftCount()).isZero();
    }

    @Test
    void aRequestBecomesOneShiftOnly() {
        var requestId = send(IN_TWO_DAYS, 3);
        post("/api/v1/staff-requests/" + requestId + "/shift", dispatcher, shift(clientId, locationId, true))
                .expectStatus().isCreated();

        expectProblem(post("/api/v1/staff-requests/" + requestId + "/shift", dispatcher,
                shift(clientId, locationId, true)), 409, "staff_request_not_open");
        assertThat(shiftCount()).isEqualTo(1);
    }

    @Test
    void aDispatcherDeclinesWithAReasonTheClientSees() {
        var requestId = send(IN_TWO_DAYS, 3);

        expectProblem(post("/api/v1/staff-requests/" + requestId + "/decline", dispatcher, Map.of("reason", " ")),
                400, "validation_failed")
                .jsonPath("$.errors[0].field").isEqualTo("reason");
        var declined = post("/api/v1/staff-requests/" + requestId + "/decline", dispatcher,
                Map.of("reason", " Am Wochenende ausgebucht. "))
                .expectStatus().isOk()
                .expectBody(Map.class).returnResult().getResponseBody();

        assertThat(declined.get("status")).isEqualTo("DECLINED");
        assertThat(declined.get("declineReason")).isEqualTo("Am Wochenende ausgebucht.");
        get("/api/v1/client/staff-requests", clientUser)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[0].status").isEqualTo("DECLINED")
                .jsonPath("$.content[0].declineReason").isEqualTo("Am Wochenende ausgebucht.");
        get("/api/v1/staff-requests?status=DECLINED", dispatcher)
                .expectStatus().isOk()
                .expectBody().jsonPath("$.content[0].id").isEqualTo(requestId);
    }

    @Test
    void anotherAgencyNeitherSeesNorHandlesTheRequests() {
        var requestId = send(IN_TWO_DAYS, 3);
        var otherAgency = data.agency("Inn Staffing");
        var otherDispatcher = login(data.account(otherAgency, Role.DISPATCHER), DASHBOARD);

        get("/api/v1/staff-requests", otherDispatcher)
                .expectStatus().isOk()
                .expectBody().jsonPath("$.totalElements").isEqualTo(0);
        expectProblem(get("/api/v1/staff-requests/" + requestId, otherDispatcher), 404, "staff_request_not_found");
        expectProblem(post("/api/v1/staff-requests/" + requestId + "/decline", otherDispatcher,
                Map.of("reason", "Nein.")), 404, "staff_request_not_found");
    }

    @Test
    void clientUsersCannotHandleRequests() {
        var requestId = send(IN_TWO_DAYS, 3);

        expectProblem(get("/api/v1/staff-requests", clientUser), 403, "forbidden");
        expectProblem(post("/api/v1/staff-requests/" + requestId + "/decline", clientUser,
                Map.of("reason", "Doch nicht.")), 403, "forbidden");
        expectProblem(post("/api/v1/staff-requests/" + requestId + "/shift", clientUser,
                shift(clientId, locationId, true)), 403, "forbidden");
    }

    // --- helpers -------------------------------------------------------------------------

    private String send(Instant startsAt, int workerCount) {
        var request = new HashMap<String, Object>();
        request.put("locationId", locationId);
        request.put("role", "Lagerhelfer");
        request.put("startsAt", startsAt.toString());
        request.put("endsAt", startsAt.plus(Duration.ofHours(8)).toString());
        request.put("workerCount", workerCount);
        request.put("notes", "Rampe 3.");
        var created = post("/api/v1/client/staff-requests", clientUser, request)
                .expectStatus().isCreated()
                .expectBody(Map.class).returnResult().getResponseBody();
        return (String) created.get("id");
    }

    private static Map<String, Object> shift(UUID forClient, UUID atLocation, boolean publish) {
        var request = new HashMap<String, Object>();
        request.put("clientId", forClient);
        request.put("locationId", atLocation);
        request.put("title", "Lagerhelfer");
        request.put("description", "Rampe 3.");
        request.put("startsAt", IN_TWO_DAYS.toString());
        request.put("endsAt", IN_TWO_DAYS.plus(Duration.ofHours(8)).toString());
        request.put("hourlyRateCents", 1650);
        request.put("slots", 3);
        request.put("publish", publish);
        return request;
    }

    private int shiftCount() {
        return jdbc.sql("select count(*) from shift where agency_id = ?").param(agency.id()).query(Integer.class).single();
    }

    private void switchPortalOn(TokenPair admin) {
        client.put().uri("/api/v1/agency/features")
                .headers(headers -> headers.setBearerAuth(admin.accessToken()))
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of("contactButton", false, "clientPortal", true))
                .exchange()
                .expectStatus().isOk();
    }

    private TokenPair clientUser(TokenPair staff, UUID forClient) {
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
}
