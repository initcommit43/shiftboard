# shiftboard backend

Spring Boot modular monolith on PostgreSQL. It implements the API contract in [`../api/openapi.yaml`](../api/openapi.yaml); the decisions behind the setup are in [`../docs/adr/`](../docs/adr/).

Java 25, Spring Boot 4.1, Spring Modulith 2.1, Gradle 9.8 (wrapper), PostgreSQL 18, Flyway.

## Run

Everything in containers, from the repository root:

```sh
cp .env.example .env        # optional, the defaults work without it
docker compose up --build
curl http://localhost:8080/api/v1/ping
```

Or only the database in a container and the application from Gradle (needs JDK 25):

```sh
docker compose up -d db     # repository root
./gradlew bootRun           # backend/
```

`bootRun` and docker compose start the application with the `local` profile, which brings a development JWT secret. Flyway migrates the schema on startup.

| URL | What |
| --- | --- |
| `http://localhost:8080/api/v1/ping` | Service status and contract version |
| `http://localhost:8080/actuator/health` | Health, the only exposed actuator endpoint |

## Configuration

Everything comes from environment variables; `.env.example` in the repository root lists the ones docker compose passes on.

| Variable | Default | What |
| --- | --- | --- |
| `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` | `localhost`, `5432`, `shiftboard`, `shiftboard`, `shiftboard` | PostgreSQL connection |
| `JWT_SECRET` | none; a development value with the `local` profile | Signs the access tokens (HS256), at least 32 characters |
| `SHIFTBOARD_SECURITY_ACCESS_TOKEN_TTL` | `15m` | Lifetime of an access token |
| `SHIFTBOARD_SECURITY_REFRESH_TOKEN_TTL` | `30d` | Lifetime of a refresh token |
| `SHIFTBOARD_SECURITY_LOGIN_RATE_LIMIT_MAX_ATTEMPTS` | `5` | Login attempts per email and client address within the window |
| `SHIFTBOARD_SECURITY_LOGIN_RATE_LIMIT_WINDOW` | `15m` | Length of that window |
| `SPRING_PROFILES_ACTIVE` | none (`local` for `bootRun` and docker compose) | `local` is for development machines only |

Without the `local` profile there is no default for `JWT_SECRET` and the application refuses to start until one is set, for example from `openssl rand -base64 48`.

## Authentication

- `POST /auth/login` checks email and password and returns an access token and a refresh token. Workers log in with client `WORKER_APP`, dispatchers and admins with `DASHBOARD`; the other combination is rejected, but only after the password was right.
- The access token is a JWT (HS256) carrying the account id (`sub`), `agency_id` and `role`. The API is stateless: a request is authenticated by the token alone, without a database lookup.
- The refresh token is a random opaque value. Only its SHA-256 hash is stored. `POST /auth/refresh` revokes it and returns a new pair, so a token works once; `POST /auth/logout` revokes it and ends the session on that device.
- Passwords are hashed with Argon2id. A wrong password and an unknown email give the same answer and take comparable time.
- Login attempts are limited per email and client address. The counters are kept in memory: the limit holds per application instance and is forgotten on restart, so running several instances needs a shared store. The client address is the remote address of the connection; behind a reverse proxy set `server.forward-headers-strategy`.
- `/ping`, `/signup/**`, `/auth/**` and `/actuator/health` are public. Everything else needs an access token, `/workers/**` the role `DISPATCHER` or `ADMIN`.

Pending and inactive workers can log in; the app reads their status from `GET /me` and shows the matching screen.

## Multi-tenancy

Every tenant-owned table carries `agency_id`, and the entities map it with Hibernate's `@TenantId`, so every query is filtered by the agency bound to `TenantContext` and every insert is stamped with it.

- Authenticated requests: the agency comes from the `agency_id` claim of the access token.
- Signup: the agency comes from the signup code in the path.
- Login, refresh and logout run before any agency is known. They only touch `user_account` and `refresh_token`, which are looked up by a globally unique key (email, token hash) and are therefore the two tables that are not tenant-filtered.
- With no agency bound, Hibernate works with a tenant that does not exist: tenant-owned rows are invisible and cannot be inserted.

A request for a row of another agency answers `404`, exactly like a row that does not exist.

## Test

```sh
./gradlew build
```

Integration tests start PostgreSQL through Testcontainers, so Docker has to be running. `ModularityTests` verifies the module boundaries and writes module diagrams to `build/spring-modulith-docs/`.

## Layout

Base package `app.shiftboard`. Each direct subpackage is a Spring Modulith application module: its top-level package is the module's public API, subpackages are internal. Modules talk to each other through domain events.

| Module | Responsibility |
| --- | --- |
| `agency` | Agencies as tenants, their qualifications and per-agency settings, the tenant context |
| `identity` | User accounts, login, access and refresh tokens, security configuration |
| `worker` | Workers in an agency's pool: signup, approval and the qualifications they have |
| `client` | Clients of an agency and the locations their shifts take place at |
| `shift` | Shifts an agency publishes, with their slots and requirements |
| `assignment` | Claims of workers on shifts, their confirmation and cancellation |
| `messaging` | Conversations between an agency and its workers |
| `notification` | Push notifications sent in reaction to events of other modules |
| `system` | Service status, `/api/v1` path prefix, problem details |

Inside a module the top-level package holds what other modules may use (service interfaces, value records, domain events); entities, repositories, services and controllers are package-private in `internal`.

```
src/main/java/app/shiftboard/<module>/   module code
src/main/resources/application.yaml      configuration
src/main/resources/db/migration/         Flyway migrations (plain SQL, never edited once applied)
src/test/java/app/shiftboard/            modularity and integration tests
```

## Conventions

- Controllers are `@RestController`s with paths relative to `/api/v1`; the prefix is added centrally.
- Errors are RFC 9457 problem details (`application/problem+json`) with the `code` of the contract. Modules throw `ApiException`; `ProblemDetailsHandler` renders it, as well as validation errors and the 401 and 403 of Spring Security.
- Rules live in the entities (`worker.approve()`); services load, call and publish the domain event.
- `shiftboard.api.version` in `application.yaml` is the contract version the backend implements; a test compares it with the spec.
- Hibernate only validates the schema (`ddl-auto=validate`). Schema changes are new Flyway migrations.
- Times are `timestamptz` in UTC, money is `decimal`, IDs are UUID v7, every tenant-owned table carries `agency_id`.
