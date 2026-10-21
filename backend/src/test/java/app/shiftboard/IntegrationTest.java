package app.shiftboard;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import app.shiftboard.identity.TokenPair;
import app.shiftboard.notification.internal.RecordingPushSender;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureRestTestClient;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.client.RestTestClient;

/**
 * Base of the tests that go through HTTP against the whole application and a real PostgreSQL.
 * All of them share one application context and one database, so each test creates the
 * agencies and users it needs.
 */
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@AutoConfigureRestTestClient
@Import({TestcontainersConfiguration.class, TestData.class, RecordedEvents.class, RecordingPushSender.class})
@ActiveProfiles("test")
public abstract class IntegrationTest {

    protected static final String WORKER_APP = "WORKER_APP";
    protected static final String DASHBOARD = "DASHBOARD";

    @Autowired
    protected RestTestClient client;

    @Autowired
    protected JdbcClient jdbc;

    @Autowired
    protected TestData data;

    @Autowired
    protected RecordedEvents events;

    protected static Map<String, Object> signupRequest(String email) {
        var request = new HashMap<String, Object>();
        request.put("firstName", "Lena");
        request.put("lastName", "Hofer");
        request.put("dateOfBirth", "1996-03-14");
        request.put("email", email);
        request.put("phone", "+43 660 5550101");
        request.put("password", TestData.PASSWORD);
        return request;
    }

    protected RestTestClient.ResponseSpec postSignup(String signupCode, Map<String, Object> request) {
        return client.post().uri("/api/v1/signup/{code}", signupCode)
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange();
    }

    /** Signs a new worker up and returns the tokens the signup logs in with. */
    protected TokenPair signUp(String signupCode, String email) {
        return postSignup(signupCode, signupRequest(email))
                .expectStatus().isCreated()
                .expectBody(TokenPair.class).returnResult().getResponseBody();
    }

    protected RestTestClient.ResponseSpec postLogin(String email, String password, String clientType) {
        return client.post().uri("/api/v1/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of("email", email, "password", password, "client", clientType))
                .exchange();
    }

    protected TokenPair login(String email, String clientType) {
        return postLogin(email, TestData.PASSWORD, clientType)
                .expectStatus().isOk()
                .expectBody(TokenPair.class).returnResult().getResponseBody();
    }

    protected RestTestClient.ResponseSpec get(String uri, TokenPair tokens) {
        return client.get().uri(uri)
                .headers(headers -> headers.setBearerAuth(tokens.accessToken()))
                .exchange();
    }

    protected RestTestClient.ResponseSpec post(String uri, TokenPair tokens) {
        return client.post().uri(uri)
                .headers(headers -> headers.setBearerAuth(tokens.accessToken()))
                .exchange();
    }

    protected RestTestClient.ResponseSpec post(String uri, TokenPair tokens, Map<String, Object> body) {
        return client.post().uri(uri)
                .headers(headers -> headers.setBearerAuth(tokens.accessToken()))
                .contentType(MediaType.APPLICATION_JSON)
                .body(body)
                .exchange();
    }

    protected RestTestClient.ResponseSpec postRefreshToken(String uri, String refreshToken) {
        return client.post().uri(uri)
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of("refreshToken", refreshToken))
                .exchange();
    }

    /** The id of the worker profile the tokens belong to. */
    protected UUID workerId(TokenPair tokens) {
        var me = get("/api/v1/me", tokens).expectStatus().isOk().expectBody(Map.class).returnResult().getResponseBody();
        return UUID.fromString((String) ((Map<?, ?>) me.get("worker")).get("id"));
    }

    protected static RestTestClient.BodyContentSpec expectProblem(
            RestTestClient.ResponseSpec response, int status, String code) {
        return response
                .expectStatus().isEqualTo(status)
                .expectHeader().contentTypeCompatibleWith(MediaType.APPLICATION_PROBLEM_JSON)
                .expectBody()
                .jsonPath("$.type").isEqualTo("about:blank")
                .jsonPath("$.status").isEqualTo(status)
                .jsonPath("$.code").isEqualTo(code);
    }
}
