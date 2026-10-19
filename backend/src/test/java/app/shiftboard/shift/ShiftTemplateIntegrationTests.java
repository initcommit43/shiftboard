package app.shiftboard.shift;

import static org.assertj.core.api.Assertions.assertThat;

import java.math.BigDecimal;
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
    void workersHaveNoAccess() {
        var worker = signUp(agency.signupCode(), TestData.email());

        expectProblem(get("/api/v1/shift-templates", worker), 403, "forbidden");
        expectProblem(post("/api/v1/shift-templates", worker, templateRequest("Frühschicht")), 403, "forbidden");
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

    private void create(TokenPair tokens, String name) {
        post("/api/v1/shift-templates", tokens, templateRequest(name)).expectStatus().isCreated();
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
