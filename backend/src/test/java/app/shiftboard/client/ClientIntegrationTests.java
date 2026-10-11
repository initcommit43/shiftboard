package app.shiftboard.client;

import java.util.List;

import app.shiftboard.IntegrationTest;
import app.shiftboard.TestData;
import app.shiftboard.identity.Role;
import app.shiftboard.identity.TokenPair;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

/**
 * What the shift form offers to choose from: clients with their locations, and qualifications.
 */
class ClientIntegrationTests extends IntegrationTest {

    TestData.Agency agency;
    TokenPair dispatcher;

    @BeforeEach
    void createAgencyWithDispatcher() {
        agency = data.agency("Donau Personal");
        dispatcher = login(data.account(agency, Role.DISPATCHER), DASHBOARD);
    }

    @Test
    void listsTheClientsOfTheAgencyWithTheirLocationsByName() {
        var logistics = data.client(agency, "Nordlicht Logistik");
        var wels = data.location(agency, logistics, "Umschlagplatz Wels", "Terminalstraße 5, 4600 Wels");
        var linz = data.location(agency, logistics, "Lager Linz", "Hafenstraße 12, 4020 Linz");
        var hotel = data.client(agency, "Hotel Lindenhof");
        var otherAgency = data.agency("Alpen Events");
        data.location(otherAgency, data.client(otherAgency, "Gipfelarena"), "Haupteingang", "Arenaweg 2, Innsbruck");

        get("/api/v1/clients", dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.page").isEqualTo(0)
                .jsonPath("$.size").isEqualTo(20)
                .jsonPath("$.totalElements").isEqualTo(2)
                .jsonPath("$.totalPages").isEqualTo(1)
                .jsonPath("$.content[*].name").isEqualTo(List.of("Hotel Lindenhof", "Nordlicht Logistik"))
                .jsonPath("$.content[0].id").isEqualTo(hotel.toString())
                .jsonPath("$.content[0].locations").isEmpty()
                .jsonPath("$.content[1].id").isEqualTo(logistics.toString())
                .jsonPath("$.content[1].locations[*].id").isEqualTo(List.of(linz.toString(), wels.toString()))
                .jsonPath("$.content[1].locations[0].name").isEqualTo("Lager Linz")
                .jsonPath("$.content[1].locations[0].address").isEqualTo("Hafenstraße 12, 4020 Linz");

        get("/api/v1/clients?page=1&size=1", dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalPages").isEqualTo(2)
                .jsonPath("$.content[*].name").isEqualTo(List.of("Nordlicht Logistik"));
    }

    @Test
    void listsTheQualificationsOfTheAgencyByName() {
        var service = data.qualification(agency, "Service");
        var bar = data.qualification(agency, "Bar");
        data.qualification(data.agency("Alpen Events"), "Security");

        get("/api/v1/qualifications", dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.totalElements").isEqualTo(2)
                .jsonPath("$.content[*].name").isEqualTo(List.of("Bar", "Service"))
                .jsonPath("$.content[*].id").isEqualTo(List.of(bar.toString(), service.toString()));
    }

    @Test
    void workersHaveNoAccess() {
        var worker = signUp(agency.signupCode(), TestData.email());

        expectProblem(get("/api/v1/clients", worker), 403, "forbidden");
        expectProblem(get("/api/v1/qualifications", worker), 403, "forbidden");
        expectProblem(client.get().uri("/api/v1/clients").exchange(), 401, "unauthenticated");
    }
}
