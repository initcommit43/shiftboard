package app.shiftboard.shift;

import static org.assertj.core.api.Assertions.assertThat;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;
import java.util.UUID;

import app.shiftboard.IntegrationTest;
import app.shiftboard.TestData;
import app.shiftboard.identity.Role;
import app.shiftboard.identity.TokenPair;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.client.RestTestClient;

class ShiftTemplateIntegrationTests extends IntegrationTest {

    TestData.Agency agency;
    TokenPair dispatcher;
    UUID clientId;
    UUID locationId;

    @BeforeEach
    void createAgencyWithDispatcherAndClient() {
        agency = data.agency("Donau Personal");
        dispatcher = login(data.account(agency, Role.DISPATCHER), DASHBOARD);
        clientId = data.client(agency, "Nordlicht Logistik");
        locationId = data.location(agency, clientId, "Zentrallager Linz", "Hafenstraße 12, 4020 Linz");
    }

    @Test
    void savesEverythingButTheDate() {
        var lager = data.qualification(agency, "Lager");
        var request = templateRequest("  Lager Nachtschicht  ");
        request.put("description", "  Sicherheitsschuhe mitbringen.  ");
        request.put("startTime", "22:00");
        request.put("durationMinutes", 480);
        request.put("endIsEstimate", true);
        request.put("qualificationIds", List.of(lager));

        post("/api/v1/shift-templates", dispatcher, request)
                .expectStatus().isCreated()
                .expectBody()
                .jsonPath("$.id").isNotEmpty()
                .jsonPath("$.name").isEqualTo("Lager Nachtschicht")
                .jsonPath("$.clientId").isEqualTo(clientId.toString())
                .jsonPath("$.locationId").isEqualTo(locationId.toString())
                .jsonPath("$.title").isEqualTo("Lagerunterstützung")
                .jsonPath("$.description").isEqualTo("Sicherheitsschuhe mitbringen.")
                .jsonPath("$.startTime").isEqualTo("22:00")
                .jsonPath("$.durationMinutes").isEqualTo(480)
                .jsonPath("$.endIsEstimate").isEqualTo(true)
                .jsonPath("$.hourlyRateCents").isEqualTo(1650)
                .jsonPath("$.slots").isEqualTo(5)
                .jsonPath("$.qualificationIds").isEqualTo(List.of(lager.toString()))
                .jsonPath("$.createdAt").isNotEmpty();

        var stored = jdbc.sql("select hourly_rate from shift_template where agency_id = ?")
                .param(agency.id()).query(BigDecimal.class).single();
        assertThat(stored).isEqualByComparingTo("16.50");
    }

    @Test
    void storesTheStartAsTypedWhateverTheServersTimeZone() {
        var serverZone = TimeZone.getDefault();
        try {
            TimeZone.setDefault(TimeZone.getTimeZone("Europe/Vienna"));
            var request = templateRequest("Nachtschicht");
            request.put("startTime", "22:00");
            post("/api/v1/shift-templates", dispatcher, request).expectStatus().isCreated();

            var stored = jdbc.sql("select start_time::text from shift_template where agency_id = ?")
                    .param(agency.id()).query(String.class).single();
            assertThat(stored).isEqualTo("22:00:00");

            // Written outside the application, like the seed data.
            jdbc.sql("update shift_template set start_time = '06:15' where agency_id = ?").param(agency.id()).update();
            get("/api/v1/shift-templates", dispatcher)
                    .expectStatus().isOk()
                    .expectBody().jsonPath("$.content[0].startTime").isEqualTo("06:15");
        } finally {
            TimeZone.setDefault(serverZone);
        }
    }

    @Test
    void leavesOutAnEmptyDescriptionAndDefaultsTheRest() {
        post("/api/v1/shift-templates", dispatcher, templateRequest("Frühschicht"))
                .expectStatus().isCreated()
                .expectBody()
                .jsonPath("$.description").doesNotExist()
                .jsonPath("$.endIsEstimate").isEqualTo(false)
                .jsonPath("$.qualificationIds").isEmpty();
    }

    @Test
    void everyDispatcherOfTheAgencySeesAllTemplatesSortedByName() {
        var colleague = login(data.account(agency, Role.DISPATCHER), DASHBOARD);
        var admin = login(data.account(agency, Role.ADMIN), DASHBOARD);
        create(dispatcher, "Spätschicht");
        create(colleague, "abendservice");
        create(admin, "Frühschicht");

        for (var tokens : List.of(dispatcher, colleague, admin)) {
            get("/api/v1/shift-templates", tokens)
                    .expectStatus().isOk()
                    .expectBody()
                    .jsonPath("$.page").isEqualTo(0)
                    .jsonPath("$.size").isEqualTo(20)
                    .jsonPath("$.totalElements").isEqualTo(3)
                    .jsonPath("$.content[*].name").isEqualTo(List.of("abendservice", "Frühschicht", "Spätschicht"));
        }

        get("/api/v1/shift-templates?page=1&size=2", dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalPages").isEqualTo(2)
                .jsonPath("$.content[*].name").isEqualTo(List.of("Spätschicht"));
    }

    @Test
    void aNameIsUsedOnlyOncePerAgencyIgnoringCase() {
        create(dispatcher, "Frühschicht");

        expectProblem(post("/api/v1/shift-templates", dispatcher, templateRequest("FRÜHSCHICHT ")), 409,
                "template_name_taken");
        assertThat(templateCount(agency)).isEqualTo(1);

        // Another agency may use the same name.
        var otherAgency = data.agency("Alpen Events");
        var otherDispatcher = login(data.account(otherAgency, Role.DISPATCHER), DASHBOARD);
        var otherClient = data.client(otherAgency, "Gipfelarena");
        var request = templateRequest("Frühschicht");
        request.put("clientId", otherClient);
        request.put("locationId", data.location(otherAgency, otherClient, "Haupteingang", "Arenaweg 2, 6020 Innsbruck"));
        post("/api/v1/shift-templates", otherDispatcher, request).expectStatus().isCreated();
    }

    @Test
    void rejectsMissingAndInvalidFields() {
        var request = templateRequest("Frühschicht");
        request.remove("name");
        request.remove("startTime");
        expectProblem(post("/api/v1/shift-templates", dispatcher, request), 400, "validation_failed")
                .jsonPath("$.errors[?(@.field == 'name')].code").isEqualTo(List.of("required"))
                .jsonPath("$.errors[?(@.field == 'startTime')].code").isEqualTo(List.of("required"));

        for (var startTime : List.of("7:00", "24:00", "07:60", "07:00:00", "früh")) {
            request = templateRequest("Frühschicht");
            request.put("startTime", startTime);
            expectFieldError(post("/api/v1/shift-templates", dispatcher, request), "startTime", "invalid_format");
        }

        request = templateRequest("x".repeat(81));
        expectFieldError(post("/api/v1/shift-templates", dispatcher, request), "name", "invalid_length");

        request = templateRequest("Frühschicht");
        request.put("durationMinutes", 1440);
        expectFieldError(post("/api/v1/shift-templates", dispatcher, request), "durationMinutes", "out_of_range");

        request = templateRequest("Frühschicht");
        request.put("slots", 0);
        expectFieldError(post("/api/v1/shift-templates", dispatcher, request), "slots", "out_of_range");

        assertThat(templateCount(agency)).isZero();
    }

    @Test
    void rejectsAClientLocationOrQualificationTheAgencyDoesNotHave() {
        var otherAgency = data.agency("Alpen Events");
        var otherClient = data.client(otherAgency, "Gipfelarena");
        var otherQualification = data.qualification(otherAgency, "Security");
        var secondClient = data.client(agency, "Hotel Lindenhof");

        var request = templateRequest("Frühschicht");
        request.put("clientId", otherClient);
        expectFieldError(post("/api/v1/shift-templates", dispatcher, request), "clientId", "not_found");

        // A location of the agency, but of another client.
        request = templateRequest("Frühschicht");
        request.put("clientId", secondClient);
        expectFieldError(post("/api/v1/shift-templates", dispatcher, request), "locationId", "not_found");

        request = templateRequest("Frühschicht");
        request.put("qualificationIds", List.of(otherQualification));
        expectFieldError(post("/api/v1/shift-templates", dispatcher, request), "qualificationIds", "not_found");
    }

    @Test
    void anotherAgencyDoesNotSeeTheTemplates() {
        create(dispatcher, "Frühschicht");
        var otherAgency = data.agency("Alpen Events");
        var otherDispatcher = login(data.account(otherAgency, Role.DISPATCHER), DASHBOARD);

        get("/api/v1/shift-templates", otherDispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalElements").isEqualTo(0);
    }

    @Test
    void anyDispatcherCanChangeEveryFieldIncludingTheName() {
        var id = create(dispatcher, "Frühschicht");
        var colleague = login(data.account(agency, Role.DISPATCHER), DASHBOARD);
        var lager = data.qualification(agency, "Lager");
        var secondClient = data.client(agency, "Hotel Lindenhof");
        var secondLocation = data.location(agency, secondClient, "Haupthaus", "Lindenweg 3, 5020 Salzburg");
        var request = templateRequest("  Bankett Abend ");
        request.put("clientId", secondClient);
        request.put("locationId", secondLocation);
        request.put("title", "Service");
        request.put("description", "Schwarze Hose");
        request.put("startTime", "18:30");
        request.put("durationMinutes", 360);
        request.put("endIsEstimate", true);
        request.put("hourlyRateCents", 1800);
        request.put("slots", 8);
        request.put("qualificationIds", List.of(lager));

        put("/api/v1/shift-templates/" + id, colleague, request)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.id").isEqualTo(id.toString())
                .jsonPath("$.name").isEqualTo("Bankett Abend")
                .jsonPath("$.clientId").isEqualTo(secondClient.toString())
                .jsonPath("$.locationId").isEqualTo(secondLocation.toString())
                .jsonPath("$.title").isEqualTo("Service")
                .jsonPath("$.description").isEqualTo("Schwarze Hose")
                .jsonPath("$.startTime").isEqualTo("18:30")
                .jsonPath("$.durationMinutes").isEqualTo(360)
                .jsonPath("$.endIsEstimate").isEqualTo(true)
                .jsonPath("$.hourlyRateCents").isEqualTo(1800)
                .jsonPath("$.slots").isEqualTo(8)
                .jsonPath("$.qualificationIds").isEqualTo(List.of(lager.toString()));

        get("/api/v1/shift-templates", dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[*].name").isEqualTo(List.of("Bankett Abend"));
    }

    @Test
    void aTemplateMayKeepItsNameInAnotherCaseButNotTakeAnotherOne() {
        var id = create(dispatcher, "Frühschicht");
        create(dispatcher, "Spätschicht");

        put("/api/v1/shift-templates/" + id, dispatcher, templateRequest("FRÜHSCHICHT"))
                .expectStatus().isOk()
                .expectBody().jsonPath("$.name").isEqualTo("FRÜHSCHICHT");

        expectProblem(put("/api/v1/shift-templates/" + id, dispatcher, templateRequest("spätschicht")), 409,
                "template_name_taken");
    }

    @Test
    void aChangeIsCheckedLikeANewTemplate() {
        var id = create(dispatcher, "Frühschicht");
        var otherClient = data.client(data.agency("Alpen Events"), "Gipfelarena");

        var request = templateRequest("Frühschicht");
        request.put("startTime", "7:00");
        expectFieldError(put("/api/v1/shift-templates/" + id, dispatcher, request), "startTime", "invalid_format");

        request = templateRequest("Frühschicht");
        request.put("clientId", otherClient);
        expectFieldError(put("/api/v1/shift-templates/" + id, dispatcher, request), "clientId", "not_found");
    }

    @Test
    void deletingRemovesTheTemplateForEveryone() {
        var id = create(dispatcher, "Frühschicht");
        create(dispatcher, "Spätschicht");
        var colleague = login(data.account(agency, Role.DISPATCHER), DASHBOARD);

        delete("/api/v1/shift-templates/" + id, colleague).expectStatus().isNoContent();

        get("/api/v1/shift-templates", dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content[*].name").isEqualTo(List.of("Spätschicht"));
        expectProblem(delete("/api/v1/shift-templates/" + id, dispatcher), 404, "template_not_found");
    }

    @Test
    void anotherAgencyCannotChangeOrDeleteTheTemplates() {
        var id = create(dispatcher, "Frühschicht");
        var otherAgency = data.agency("Alpen Events");
        var otherDispatcher = login(data.account(otherAgency, Role.DISPATCHER), DASHBOARD);

        expectProblem(put("/api/v1/shift-templates/" + id, otherDispatcher, templateRequest("Andere")), 404,
                "template_not_found");
        expectProblem(delete("/api/v1/shift-templates/" + id, otherDispatcher), 404, "template_not_found");
        assertThat(templateCount(agency)).isEqualTo(1);
    }

    @Test
    void workersHaveNoAccess() {
        var worker = signUp(agency.signupCode(), TestData.email());
        var id = create(dispatcher, "Frühschicht");

        expectProblem(get("/api/v1/shift-templates", worker), 403, "forbidden");
        expectProblem(post("/api/v1/shift-templates", worker, templateRequest("Frühschicht")), 403, "forbidden");
        expectProblem(put("/api/v1/shift-templates/" + id, worker, templateRequest("Frühschicht")), 403, "forbidden");
        expectProblem(delete("/api/v1/shift-templates/" + id, worker), 403, "forbidden");
    }

    private Map<String, Object> templateRequest(String name) {
        var request = new HashMap<String, Object>();
        request.put("name", name);
        request.put("clientId", clientId);
        request.put("locationId", locationId);
        request.put("title", "Lagerunterstützung");
        request.put("startTime", "07:00");
        request.put("durationMinutes", 480);
        request.put("hourlyRateCents", 1650);
        request.put("slots", 5);
        return request;
    }

    private UUID create(TokenPair tokens, String name) {
        var created = post("/api/v1/shift-templates", tokens, templateRequest(name))
                .expectStatus().isCreated()
                .expectBody(Map.class).returnResult().getResponseBody();
        return UUID.fromString((String) created.get("id"));
    }

    private RestTestClient.ResponseSpec put(String uri, TokenPair tokens, Map<String, Object> body) {
        return client.put().uri(uri)
                .headers(headers -> headers.setBearerAuth(tokens.accessToken()))
                .contentType(MediaType.APPLICATION_JSON)
                .body(body)
                .exchange();
    }

    private RestTestClient.ResponseSpec delete(String uri, TokenPair tokens) {
        return client.delete().uri(uri)
                .headers(headers -> headers.setBearerAuth(tokens.accessToken()))
                .exchange();
    }

    private int templateCount(TestData.Agency of) {
        return jdbc.sql("select count(*) from shift_template where agency_id = ?")
                .param(of.id()).query(Integer.class).single();
    }

    private static void expectFieldError(RestTestClient.ResponseSpec response, String field, String code) {
        expectProblem(response, 400, "validation_failed")
                .jsonPath("$.errors.length()").isEqualTo(1)
                .jsonPath("$.errors[0].field").isEqualTo(field)
                .jsonPath("$.errors[0].code").isEqualTo(code);
    }
}
