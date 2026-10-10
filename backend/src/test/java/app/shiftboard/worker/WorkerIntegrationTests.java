package app.shiftboard.worker;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;
import java.util.UUID;

import app.shiftboard.IntegrationTest;
import app.shiftboard.TestData;
import app.shiftboard.identity.Role;
import app.shiftboard.identity.TokenPair;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.SessionFactory;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

class WorkerIntegrationTests extends IntegrationTest {

    @Autowired
    EntityManagerFactory entityManagerFactory;

    TestData.Agency agency;
    TokenPair dispatcher;

    @BeforeEach
    void createAgencyWithDispatcher() {
        agency = data.agency("Donau Personal");
        dispatcher = login(data.account(agency, Role.DISPATCHER), DASHBOARD);
    }

    @Test
    void listsTheWorkersOfTheAgencyOldestSignupFirst() {
        var bar = data.qualification(agency, "Bar");
        var service = data.qualification(agency, "Service");
        var first = TestData.email();
        var second = TestData.email();
        var firstId = workerId(signUp(agency.signupCode(), first));
        data.qualify(firstId, service, bar);
        signUp(agency.signupCode(), second);

        get("/api/v1/workers", dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.page").isEqualTo(0)
                .jsonPath("$.size").isEqualTo(20)
                .jsonPath("$.totalElements").isEqualTo(2)
                .jsonPath("$.totalPages").isEqualTo(1)
                .jsonPath("$.content[*].email").isEqualTo(List.of(first, second))
                .jsonPath("$.content[0].id").isEqualTo(firstId.toString())
                .jsonPath("$.content[0].firstName").isEqualTo("Lena")
                .jsonPath("$.content[0].lastName").isEqualTo("Hofer")
                .jsonPath("$.content[0].dateOfBirth").isEqualTo("1996-03-14")
                .jsonPath("$.content[0].phone").isEqualTo("+43 660 5550101")
                .jsonPath("$.content[0].status").isEqualTo("PENDING")
                .jsonPath("$.content[0].createdAt").isNotEmpty()
                .jsonPath("$.content[0].qualifications[*].name").isEqualTo(List.of("Bar", "Service"))
                .jsonPath("$.content[0].qualifications[*].id").isEqualTo(List.of(bar.toString(), service.toString()))
                .jsonPath("$.content[1].qualifications").isEmpty();
    }

    @Test
    void filtersTheListByStatus() {
        var pending = TestData.email();
        var active = TestData.email();
        var inactive = TestData.email();
        signUp(agency.signupCode(), pending);
        post("/api/v1/workers/" + workerId(signUp(agency.signupCode(), active)) + "/approve", dispatcher);
        post("/api/v1/workers/" + workerId(signUp(agency.signupCode(), inactive)) + "/reject", dispatcher);

        get("/api/v1/workers?status=PENDING", dispatcher).expectBody()
                .jsonPath("$.content[*].email").isEqualTo(List.of(pending))
                .jsonPath("$.totalElements").isEqualTo(1);
        get("/api/v1/workers?status=ACTIVE", dispatcher).expectBody()
                .jsonPath("$.content[*].email").isEqualTo(List.of(active));
        get("/api/v1/workers?status=INACTIVE", dispatcher).expectBody()
                .jsonPath("$.content[*].email").isEqualTo(List.of(inactive));
        get("/api/v1/workers", dispatcher).expectBody()
                .jsonPath("$.content[*].email").isEqualTo(List.of(pending, active, inactive));
    }

    @Test
    void pagesTheList() {
        var emails = List.of(TestData.email(), TestData.email(), TestData.email());
        emails.forEach(email -> signUp(agency.signupCode(), email));

        get("/api/v1/workers?page=0&size=2", dispatcher).expectBody()
                .jsonPath("$.content[*].email").isEqualTo(emails.subList(0, 2))
                .jsonPath("$.page").isEqualTo(0)
                .jsonPath("$.size").isEqualTo(2)
                .jsonPath("$.totalElements").isEqualTo(3)
                .jsonPath("$.totalPages").isEqualTo(2);
        get("/api/v1/workers?page=1&size=2", dispatcher).expectBody()
                .jsonPath("$.content[*].email").isEqualTo(emails.subList(2, 3))
                .jsonPath("$.page").isEqualTo(1);
        get("/api/v1/workers?page=2&size=2", dispatcher).expectBody()
                .jsonPath("$.content").isEmpty()
                .jsonPath("$.totalElements").isEqualTo(3);
    }

    @Test
    void invalidListParametersAreValidationErrors() {
        expectProblem(get("/api/v1/workers?page=-1", dispatcher), 400, "validation_failed")
                .jsonPath("$.errors[0].field").isEqualTo("page")
                .jsonPath("$.errors[0].code").isEqualTo("out_of_range");
        expectProblem(get("/api/v1/workers?size=0", dispatcher), 400, "validation_failed")
                .jsonPath("$.errors[0].field").isEqualTo("size");
        expectProblem(get("/api/v1/workers?size=101", dispatcher), 400, "validation_failed")
                .jsonPath("$.errors[0].field").isEqualTo("size");
        expectProblem(get("/api/v1/workers?status=RETIRED", dispatcher), 400, "validation_failed")
                .jsonPath("$.errors[0].field").isEqualTo("status")
                .jsonPath("$.errors[0].code").isEqualTo("invalid_format");
    }

    @Test
    void loadsAPageWithTheSameNumberOfQueriesWhateverItsSize() {
        var service = data.qualification(agency, "Service");
        var statistics = entityManagerFactory.unwrap(SessionFactory.class).getStatistics();

        data.qualify(workerId(signUp(agency.signupCode(), TestData.email())), service);
        statistics.clear();
        get("/api/v1/workers", dispatcher).expectBody().jsonPath("$.content.length()").isEqualTo(1);
        var statementsForOneWorker = statistics.getPrepareStatementCount();

        for (int i = 0; i < 5; i++) {
            data.qualify(workerId(signUp(agency.signupCode(), TestData.email())), service);
        }
        statistics.clear();
        get("/api/v1/workers", dispatcher).expectBody().jsonPath("$.content.length()").isEqualTo(6);

        assertThat(statistics.getPrepareStatementCount()).isEqualTo(statementsForOneWorker);
    }

    @Test
    void theWorkerPoolIsForDispatchersAndAdminsOnly() {
        var worker = signUp(agency.signupCode(), TestData.email());
        var workerId = workerId(worker);
        var admin = login(data.account(agency, Role.ADMIN), DASHBOARD);

        expectProblem(get("/api/v1/workers", worker), 403, "forbidden");
        expectProblem(post("/api/v1/workers/" + workerId + "/approve", worker), 403, "forbidden");
        expectProblem(post("/api/v1/workers/" + workerId + "/reject", worker), 403, "forbidden");
        expectProblem(client.get().uri("/api/v1/workers").exchange(), 401, "unauthenticated");
        expectProblem(
                client.post().uri("/api/v1/workers/" + workerId + "/approve").exchange(), 401, "unauthenticated");

        get("/api/v1/workers", admin).expectStatus().isOk();
        post("/api/v1/workers/" + workerId + "/approve", admin).expectStatus().isOk();
    }

    @Test
    void approvingActivatesThePendingWorker() {
        var email = TestData.email();
        var worker = signUp(agency.signupCode(), email);
        var workerId = workerId(worker);

        post("/api/v1/workers/" + workerId + "/approve", dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.id").isEqualTo(workerId.toString())
                .jsonPath("$.email").isEqualTo(email)
                .jsonPath("$.status").isEqualTo("ACTIVE")
                .jsonPath("$.qualifications").isEmpty()
                .jsonPath("$.createdAt").isNotEmpty();

        get("/api/v1/me", worker).expectBody().jsonPath("$.worker.status").isEqualTo("ACTIVE");
        assertThat(events.all()).contains(new WorkerApproved(agency.id(), workerId));
    }

    @Test
    void rejectingDeactivatesThePendingWorker() {
        var worker = signUp(agency.signupCode(), TestData.email());
        var workerId = workerId(worker);

        post("/api/v1/workers/" + workerId + "/reject", dispatcher)
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.id").isEqualTo(workerId.toString())
                .jsonPath("$.status").isEqualTo("INACTIVE");

        get("/api/v1/me", worker).expectBody().jsonPath("$.worker.status").isEqualTo("INACTIVE");
        assertThat(events.all()).contains(new WorkerRejected(agency.id(), workerId));
    }

    @Test
    void aDecidedSignupCannotBeDecidedAgain() {
        var approved = workerId(signUp(agency.signupCode(), TestData.email()));
        var rejected = workerId(signUp(agency.signupCode(), TestData.email()));
        post("/api/v1/workers/" + approved + "/approve", dispatcher).expectStatus().isOk();
        post("/api/v1/workers/" + rejected + "/reject", dispatcher).expectStatus().isOk();

        expectProblem(post("/api/v1/workers/" + approved + "/approve", dispatcher), 409, "worker_not_pending");
        expectProblem(post("/api/v1/workers/" + approved + "/reject", dispatcher), 409, "worker_not_pending");
        expectProblem(post("/api/v1/workers/" + rejected + "/approve", dispatcher), 409, "worker_not_pending");
        expectProblem(post("/api/v1/workers/" + rejected + "/reject", dispatcher), 409, "worker_not_pending");
        assertThat(statusOf(approved)).isEqualTo("ACTIVE");
        assertThat(statusOf(rejected)).isEqualTo("INACTIVE");
    }

    @Test
    void anUnknownWorkerIsNotFound() {
        var unknown = UUID.randomUUID();

        expectProblem(post("/api/v1/workers/" + unknown + "/approve", dispatcher), 404, "worker_not_found");
        expectProblem(post("/api/v1/workers/" + unknown + "/reject", dispatcher), 404, "worker_not_found");
        expectProblem(post("/api/v1/workers/not-a-uuid/approve", dispatcher), 400, "validation_failed");
    }

    @Test
    void aDispatcherSeesOnlyTheWorkersOfTheOwnAgency() {
        var otherAgency = data.agency("Alpen Events");
        var own = TestData.email();
        signUp(agency.signupCode(), own);
        signUp(otherAgency.signupCode(), TestData.email());

        get("/api/v1/workers", dispatcher).expectBody()
                .jsonPath("$.content[*].email").isEqualTo(List.of(own))
                .jsonPath("$.totalElements").isEqualTo(1);
        get("/api/v1/workers?status=PENDING", dispatcher).expectBody()
                .jsonPath("$.content[*].email").isEqualTo(List.of(own));
    }

    @Test
    void aDispatcherCannotDecideSignupsOfAnotherAgency() {
        var otherAgency = data.agency("Alpen Events");
        var foreignWorker = signUp(otherAgency.signupCode(), TestData.email());
        var foreignWorkerId = workerId(foreignWorker);

        expectProblem(post("/api/v1/workers/" + foreignWorkerId + "/approve", dispatcher), 404, "worker_not_found");
        expectProblem(post("/api/v1/workers/" + foreignWorkerId + "/reject", dispatcher), 404, "worker_not_found");

        assertThat(statusOf(foreignWorkerId)).isEqualTo("PENDING");
        get("/api/v1/me", foreignWorker).expectBody().jsonPath("$.worker.status").isEqualTo("PENDING");
    }

    private String statusOf(UUID workerId) {
        return jdbc.sql("select status from worker where id = ?").param(workerId).query(String.class).single();
    }
}
