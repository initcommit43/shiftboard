package app.shiftboard.shift;

import static org.assertj.core.api.Assertions.assertThat;

import java.math.BigDecimal;
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
import org.springframework.test.web.servlet.client.RestTestClient;

class ShiftIntegrationTests extends IntegrationTest {

    static final Instant TOMORROW = Instant.now().plus(Duration.ofDays(1)).truncatedTo(ChronoUnit.SECONDS);

    TestData.Agency agency;
    String dispatcherEmail;
    TokenPair dispatcher;
    UUID clientId;
    UUID locationId;

    @BeforeEach
    void createAgencyWithDispatcherAndClient() {
        agency = data.agency("Donau Personal");
        dispatcherEmail = data.account(agency, Role.DISPATCHER);
        dispatcher = login(dispatcherEmail, DASHBOARD);
        clientId = data.client(agency, "Nordlicht Logistik");
        locationId = data.location(agency, clientId, "Zentrallager Linz", "Hafenstraße 12, 4020 Linz");
    }

    @Test
    void createsADraftWithEverythingTheDispatcherEntered() {
        var lager = data.qualification(agency, "Lager");
        var stapler = data.qualification(agency, "Staplerschein");
        var request = shiftRequest();
        request.put("description", "  Sicherheitsschuhe mitbringen.  ");
        request.put("endIsEstimate", true);
        request.put("qualificationIds", List.of(stapler, lager));

        var id = post("/api/v1/shifts", dispatcher, request)
                .expectStatus().isCreated()
                .expectBody()
                .jsonPath("$.id").isNotEmpty()
                .jsonPath("$.title").isEqualTo("Lagerunterstützung")
                .jsonPath("$.description").isEqualTo("Sicherheitsschuhe mitbringen.")
                .jsonPath("$.status").isEqualTo("DRAFT")
                .jsonPath("$.client.id").isEqualTo(clientId.toString())
                .jsonPath("$.client.name").isEqualTo("Nordlicht Logistik")
                .jsonPath("$.location.id").isEqualTo(locationId.toString())
                .jsonPath("$.location.name").isEqualTo("Zentrallager Linz")
                .jsonPath("$.location.address").isEqualTo("Hafenstraße 12, 4020 Linz")
                .jsonPath("$.startsAt").isEqualTo(TOMORROW.toString())
                .jsonPath("$.endsAt").isEqualTo(TOMORROW.plus(Duration.ofHours(8)).toString())
                .jsonPath("$.endIsEstimate").isEqualTo(true)
                .jsonPath("$.hourlyRateCents").isEqualTo(1650)
                .jsonPath("$.slots").isEqualTo(5)
                .jsonPath("$.takenSlots").isEqualTo(0)
                .jsonPath("$.qualifications[*].name").isEqualTo(List.of("Lager", "Staplerschein"))
                .jsonPath("$.createdAt").isNotEmpty()
                .returnResult();

        var stored = jdbc.sql("""
                        select s.hourly_rate, a.email
                        from shift s join user_account a on a.id = s.contact_user_id
                        where s.agency_id = ?
                        """)
                .param(agency.id()).query().singleRow();
        assertThat(id).isNotNull();
        assertThat((BigDecimal) stored.get("hourly_rate")).isEqualByComparingTo("16.50");
        assertThat(stored.get("email")).isEqualTo(dispatcherEmail);
    }

    @Test
    void createsAPublishedShiftWhenAskedTo() {
        var request = shiftRequest();
        request.put("publish", true);

        post("/api/v1/shifts", dispatcher, request)
                .expectStatus().isCreated()
                .expectBody()
                .jsonPath("$.status").isEqualTo("PUBLISHED")
                .jsonPath("$.endIsEstimate").isEqualTo(false)
                .jsonPath("$.description").doesNotExist()
                .jsonPath("$.qualifications").isEmpty();
    }

    @Test
    void publishesADraftOnce() {
        var id = create(shiftRequest());

        post("/api/v1/shifts/" + id + "/publish", dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.id").isEqualTo(id)
                .jsonPath("$.status").isEqualTo("PUBLISHED");

        expectProblem(post("/api/v1/shifts/" + id + "/publish", dispatcher), 409, "shift_not_draft");
    }

    @Test
    void aShiftThatDoesNotExistCannotBePublished() {
        expectProblem(post("/api/v1/shifts/" + UUID.randomUUID() + "/publish", dispatcher), 404, "shift_not_found");
    }

    @Test
    void rejectsAnEndThatIsNotAfterTheStart() {
        var request = shiftRequest();
        request.put("endsAt", TOMORROW.toString());

        expectFieldError(post("/api/v1/shifts", dispatcher, request), "endsAt", "before_start");
        assertThat(shiftCount()).isZero();
    }

    @Test
    void rejectsARateOrSlotsOutOfRange() {
        var request = shiftRequest();
        request.put("hourlyRateCents", 0);
        request.put("slots", 0);

        expectProblem(post("/api/v1/shifts", dispatcher, request), 400, "validation_failed")
                .jsonPath("$.errors[?(@.field == 'hourlyRateCents')].code").isEqualTo(List.of("out_of_range"))
                .jsonPath("$.errors[?(@.field == 'slots')].code").isEqualTo(List.of("out_of_range"));

        request.put("hourlyRateCents", 1650);
        request.put("slots", 501);
        expectFieldError(post("/api/v1/shifts", dispatcher, request), "slots", "out_of_range");
    }

    @Test
    void rejectsMissingAndUnreadableFields() {
        var request = shiftRequest();
        request.remove("title");
        request.remove("clientId");
        expectProblem(post("/api/v1/shifts", dispatcher, request), 400, "validation_failed")
                .jsonPath("$.errors[?(@.field == 'title')].code").isEqualTo(List.of("required"))
                .jsonPath("$.errors[?(@.field == 'clientId')].code").isEqualTo(List.of("required"));

        request = shiftRequest();
        request.put("title", "x".repeat(121));
        expectFieldError(post("/api/v1/shifts", dispatcher, request), "title", "invalid_length");

        request = shiftRequest();
        request.put("startsAt", "morgen früh");
        expectFieldError(post("/api/v1/shifts", dispatcher, request), "startsAt", "invalid_format");
    }

    @Test
    void rejectsAClientLocationOrQualificationTheAgencyDoesNotHave() {
        var otherAgency = data.agency("Alpen Events");
        var otherClient = data.client(otherAgency, "Gipfelarena");
        var otherLocation = data.location(otherAgency, otherClient, "Haupteingang", "Arenaweg 2, 6020 Innsbruck");
        var otherQualification = data.qualification(otherAgency, "Security");
        var secondClient = data.client(agency, "Hotel Lindenhof");
        var secondLocation = data.location(agency, secondClient, "Bankettsaal", "Lindenallee 3, 4040 Linz");

        var request = shiftRequest();
        request.put("clientId", otherClient);
        request.put("locationId", otherLocation);
        expectFieldError(post("/api/v1/shifts", dispatcher, request), "clientId", "not_found");

        // A location of the agency, but of another client.
        request = shiftRequest();
        request.put("locationId", secondLocation);
        expectFieldError(post("/api/v1/shifts", dispatcher, request), "locationId", "not_found");

        request = shiftRequest();
        request.put("qualificationIds", List.of(otherQualification));
        expectFieldError(post("/api/v1/shifts", dispatcher, request), "qualificationIds", "not_found");

        assertThat(shiftCount()).isZero();
    }

    @Test
    void listsDraftPublishedAndCancelledShiftsThatHaveNotEndedEarliestStartFirst() {
        var later = shiftRequest();
        later.put("title", "Später");
        later.put("startsAt", TOMORROW.plus(Duration.ofDays(2)).toString());
        later.put("endsAt", TOMORROW.plus(Duration.ofDays(2)).plus(Duration.ofHours(4)).toString());
        later.put("publish", true);
        create(later);
        var sooner = shiftRequest();
        sooner.put("title", "Früher");
        create(sooner);
        // Started an hour ago and still running.
        var running = shiftRequest();
        running.put("title", "Läuft gerade");
        running.put("startsAt", Instant.now().minus(Duration.ofHours(1)).toString());
        running.put("endsAt", Instant.now().plus(Duration.ofHours(3)).toString());
        running.put("publish", true);
        create(running);
        var over = shiftRequest();
        over.put("title", "Vorbei");
        over.put("startsAt", Instant.now().minus(Duration.ofHours(9)).toString());
        over.put("endsAt", Instant.now().minus(Duration.ofHours(1)).toString());
        create(over);
        // Cancelled, and still listed until it would have ended.
        var cancelled = shiftRequest();
        cancelled.put("title", "Abgesagt");
        cancelled.put("publish", true);
        post("/api/v1/shifts/" + create(cancelled) + "/cancel", dispatcher).expectStatus().isOk();

        for (var uri : List.of("/api/v1/shifts", "/api/v1/shifts?period=UPCOMING")) {
            get(uri, dispatcher)
                    .expectStatus().isOk()
                    .expectBody()
                    .jsonPath("$.page").isEqualTo(0)
                    .jsonPath("$.size").isEqualTo(20)
                    .jsonPath("$.totalElements").isEqualTo(4)
                    .jsonPath("$.totalPages").isEqualTo(1)
                    .jsonPath("$.content[*].title").isEqualTo(List.of("Läuft gerade", "Früher", "Abgesagt", "Später"))
                    .jsonPath("$.content[*].status").isEqualTo(List.of("PUBLISHED", "DRAFT", "CANCELLED", "PUBLISHED"))
                    .jsonPath("$.content[1].client.name").isEqualTo("Nordlicht Logistik")
                    .jsonPath("$.content[1].location.name").isEqualTo("Zentrallager Linz")
                    .jsonPath("$.content[1].slots").isEqualTo(5)
                    .jsonPath("$.content[1].takenSlots").isEqualTo(0);
        }

        get("/api/v1/shifts?page=1&size=3", dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalPages").isEqualTo(2)
                .jsonPath("$.content[*].title").isEqualTo(List.of("Später"));
    }

    @Test
    void listsPublishedCompletedAndCancelledShiftsThatHaveEndedLatestStartFirst() {
        var yesterday = Instant.now().minus(Duration.ofDays(1)).truncatedTo(ChronoUnit.SECONDS);
        var older = ended("Vorgestern", yesterday.minus(Duration.ofDays(1)), true);
        var newer = ended("Gestern", yesterday, true);
        ended("Nie veröffentlicht", yesterday, false);
        var completed = ended("Erledigt", yesterday.minus(Duration.ofHours(12)), true);
        jdbc.sql("update shift set status = 'COMPLETED' where id = ?").param(UUID.fromString(completed)).update();
        var cancelled = ended("Abgesagt", yesterday.minus(Duration.ofHours(6)), true);
        jdbc.sql("update shift set status = 'CANCELLED' where id = ?").param(UUID.fromString(cancelled)).update();
        create(shiftRequest());

        get("/api/v1/shifts?period=PAST", dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalElements").isEqualTo(4)
                .jsonPath("$.content[*].title").isEqualTo(List.of("Gestern", "Abgesagt", "Erledigt", "Vorgestern"))
                .jsonPath("$.content[*].status")
                .isEqualTo(List.of("PUBLISHED", "CANCELLED", "COMPLETED", "PUBLISHED"))
                .jsonPath("$.content[0].id").isEqualTo(newer)
                .jsonPath("$.content[3].id").isEqualTo(older);

        expectFieldError(get("/api/v1/shifts?period=SOON", dispatcher), "period", "invalid_format");
    }

    @Test
    void showsOneShiftDraftsIncluded() {
        var draft = create(shiftRequest());

        get("/api/v1/shifts/" + draft, dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.id").isEqualTo(draft)
                .jsonPath("$.status").isEqualTo("DRAFT")
                .jsonPath("$.title").isEqualTo("Lagerunterstützung")
                .jsonPath("$.createdAt").isNotEmpty();
        expectProblem(get("/api/v1/shifts/" + UUID.randomUUID(), dispatcher), 404, "shift_not_found");
    }

    @Test
    void cancelsADraftOrPublishedShiftOnce() {
        var draft = create(shiftRequest());
        var request = shiftRequest();
        request.put("publish", true);
        var published = create(request);

        for (var id : List.of(draft, published)) {
            post("/api/v1/shifts/" + id + "/cancel", dispatcher)
                    .expectStatus().isOk()
                    .expectBody()
                    .jsonPath("$.id").isEqualTo(id)
                    .jsonPath("$.status").isEqualTo("CANCELLED");
            expectProblem(post("/api/v1/shifts/" + id + "/cancel", dispatcher), 409, "shift_not_cancellable");
        }
        assertThat(events.all()).contains(
                new ShiftCancelled(agency.id(), UUID.fromString(draft)),
                new ShiftCancelled(agency.id(), UUID.fromString(published)));

        var over = ended("Vorbei", Instant.now().minus(Duration.ofDays(1)), true);
        expectProblem(post("/api/v1/shifts/" + over + "/cancel", dispatcher), 409, "shift_not_cancellable");
        expectProblem(post("/api/v1/shifts/" + UUID.randomUUID() + "/cancel", dispatcher), 404, "shift_not_found");
    }

    @Test
    void anotherAgencyNeitherSeesNorPublishesTheShift() {
        var id = create(shiftRequest());
        var otherAgency = data.agency("Alpen Events");
        var otherDispatcher = login(data.account(otherAgency, Role.DISPATCHER), DASHBOARD);

        get("/api/v1/shifts", otherDispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalElements").isEqualTo(0)
                .jsonPath("$.content").isEmpty();
        expectProblem(post("/api/v1/shifts/" + id + "/publish", otherDispatcher), 404, "shift_not_found");
        expectProblem(get("/api/v1/shifts/" + id, otherDispatcher), 404, "shift_not_found");
        expectProblem(post("/api/v1/shifts/" + id + "/cancel", otherDispatcher), 404, "shift_not_found");
    }

    @Test
    void workersHaveNoAccess() {
        var worker = signUp(agency.signupCode(), TestData.email());
        var id = create(shiftRequest());

        expectProblem(get("/api/v1/shifts", worker), 403, "forbidden");
        expectProblem(post("/api/v1/shifts", worker, shiftRequest()), 403, "forbidden");
        expectProblem(post("/api/v1/shifts/" + id + "/publish", worker), 403, "forbidden");
        expectProblem(get("/api/v1/shifts/" + id, worker), 403, "forbidden");
        expectProblem(post("/api/v1/shifts/" + id + "/cancel", worker), 403, "forbidden");
        expectProblem(client.get().uri("/api/v1/shifts").exchange(), 401, "unauthenticated");
    }

    private Map<String, Object> shiftRequest() {
        var request = new HashMap<String, Object>();
        request.put("clientId", clientId);
        request.put("locationId", locationId);
        request.put("title", "Lagerunterstützung");
        request.put("startsAt", TOMORROW.toString());
        request.put("endsAt", TOMORROW.plus(Duration.ofHours(8)).toString());
        request.put("hourlyRateCents", 1650);
        request.put("slots", 5);
        return request;
    }

    /** Creates an eight-hour shift that has ended and returns its id. */
    private String ended(String title, Instant startsAt, boolean publish) {
        var request = shiftRequest();
        request.put("title", title);
        request.put("startsAt", startsAt.toString());
        request.put("endsAt", startsAt.plus(Duration.ofHours(8)).toString());
        request.put("publish", publish);
        return create(request);
    }

    /** Creates the shift and returns its id. */
    private String create(Map<String, Object> request) {
        var created = post("/api/v1/shifts", dispatcher, request)
                .expectStatus().isCreated()
                .expectBody(Map.class).returnResult().getResponseBody();
        return (String) created.get("id");
    }

    private int shiftCount() {
        return jdbc.sql("select count(*) from shift where agency_id = ?")
                .param(agency.id()).query(Integer.class).single();
    }

    private static void expectFieldError(RestTestClient.ResponseSpec response, String field, String code) {
        expectProblem(response, 400, "validation_failed")
                .jsonPath("$.errors.length()").isEqualTo(1)
                .jsonPath("$.errors[0].field").isEqualTo(field)
                .jsonPath("$.errors[0].code").isEqualTo(code);
    }
}
