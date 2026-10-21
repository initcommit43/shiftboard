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

`bootRun` and docker compose start the application with the `local` profile, which brings a development JWT secret and the [demo data](#demo-data). Flyway migrates the schema on startup.

A local database created before the date of birth was added (migration `V3`) cannot be migrated, because its workers have none. Reset it with `docker compose down -v` and start again.

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
| `SEED_PASSWORD` | `shiftboard-demo`, `local` profile only | Password of the seeded demo accounts |
| `SPRING_PROFILES_ACTIVE` | none (`local` for `bootRun` and docker compose) | `local` is for development machines only: development JWT secret and demo data |

Without the `local` profile there is no default for `JWT_SECRET` and the application refuses to start until one is set, for example from `openssl rand -base64 48`.

The `local` profile in turn only starts against a database on the same machine: `localhost`, a loopback address, or a host name without a dot such as the `db` service of docker compose. Against any other database the application stops during startup, before it connects to it, so a deployment that sets the profile by mistake fails instead of running with the development JWT secret and the demo accounts.

## Authentication

- `POST /auth/login` checks email and password and returns an access token and a refresh token. Workers log in with client `WORKER_APP`, dispatchers and admins with `DASHBOARD`; the other combination is rejected, but only after the password was right.
- The access token is a JWT (HS256) carrying the account id (`sub`), `agency_id` and `role`. The API is stateless: a request is authenticated by the token alone, without a database lookup.
- The refresh token is a random opaque value. Only its SHA-256 hash is stored. `POST /auth/refresh` revokes it and returns a new pair, so a token works once; `POST /auth/logout` revokes it and ends the session on that device.
- Passwords are hashed with Argon2id. A wrong password and an unknown email give the same answer and take comparable time.
- Login attempts are limited per email and client address. The counters are kept in memory: the limit holds per application instance and is forgotten on restart, so running several instances needs a shared store. The client address is the remote address of the connection; behind a reverse proxy set `server.forward-headers-strategy`.
- `/ping`, `/signup/**`, `/auth/**` and `/actuator/health` are public. Everything else needs an access token; `/workers/**`, `/clients/**`, `/qualifications/**`, `/shifts/**` and `/hours/**` need the role `DISPATCHER` or `ADMIN`, `/worker/**` needs the role `WORKER`.

Pending and inactive workers can log in; the app reads their status from `GET /me` and shows the matching screen. The endpoints under `/worker/**` answer them with `worker_not_active`.

## Claiming a shift

`POST /worker/shifts/{shiftId}/claim` takes one slot of the shift and stores the worker's assignment as `PENDING`, in one transaction.

- The rule lives in the entity: `Shift.claim` only takes a slot of a published shift that has not started and is not full.
- The shift row carries a `@Version`. Of two claims that read the same row, the slower one fails the version check when it writes. It is tried again up to three times, each time reading the shift anew, so a worker hears `shift_full` when the shift filled up, not when a colleague was merely faster on a shift with spots left ([ADR 0008](../docs/adr/0008-overbooking-protection.md)).
- The database has the last word: a unique constraint keeps a worker from claiming the same shift twice, an exclusion constraint from being booked for two overlapping shifts. Both also hold against two requests of the same worker at once.
- An assignment copies start and end of its shift. Overlaps are checked and "my shifts" is sorted on the assignment alone; whatever moves a shift later has to move its assignments too.
- Qualifications are not checked ([ADR 0021](../docs/adr/0021-qualifications-information-only.md)).

## Multi-tenancy

Every tenant-owned table carries `agency_id`, and the entities map it with Hibernate's `@TenantId`, so every query is filtered by the agency bound to `TenantContext` and every insert is stamped with it.

- Authenticated requests: the agency comes from the `agency_id` claim of the access token.
- Signup: the agency comes from the signup code in the path.
- Login, refresh and logout run before any agency is known. They only touch `user_account` and `refresh_token`, which are looked up by a globally unique key (email, token hash) and are therefore the two tables that are not tenant-filtered.
- With no agency bound, Hibernate works with a tenant that does not exist: tenant-owned rows are invisible and cannot be inserted.

A request for a row of another agency answers `404`, exactly like a row that does not exist.

## Demo data

With the `local` profile the application seeds two fictional agencies on startup. The seed runs once: a database that already has the demo agency is left alone, and `docker compose down -v` starts over. It is never active without the `local` profile, and that profile does not start against a database on another machine (see Configuration).

Every account has the password `shiftboard-demo` (`SEED_PASSWORD`). It is a local demo credential, not a secret.

| Agency | Signup code | Role | Login |
| --- | --- | --- | --- |
| Donau Personal | `donau-demo` | Admin | `admin.donau@example.com` |
| | | Dispatcher | `dispatcher1.donau@example.com`, `dispatcher2.donau@example.com` |
| | | Worker, active | `lena.hofer@example.com`, `jakob.steiner@example.com`, `mira.aigner@example.com`, `felix.brandner@example.com`, `sophie.lechner@example.com`, `paul.winkler@example.com` |
| | | Worker, pending | `emma.koller@example.com`, `lukas.reiter@example.com`, `nina.hauser@example.com`, `david.pichler@example.com` |
| | | Worker, inactive | `simon.egger@example.com` |
| Alpen Events | `alpen-demo` | Dispatcher | `dispatcher.alpen@example.com` |
| | | Worker, active | `tobias.gruber@example.com` |

Every worker has a fictional date of birth. Donau Personal has the qualifications Service, Bar, Lager and Staplerschein. The second agency exists to show tenant isolation: its dispatcher sees one worker, the dispatchers of Donau Personal see eleven.

A signup link carries the signup code; the API behind it is `GET` and `POST /api/v1/signup/donau-demo`:

```sh
curl http://localhost:8080/api/v1/signup/donau-demo
curl -X POST http://localhost:8080/api/v1/auth/login -H 'Content-Type: application/json' \
    -d '{"email": "dispatcher1.donau@example.com", "password": "shiftboard-demo", "client": "DASHBOARD"}'
```

Donau Personal also has three clients (Nordlicht Logistik, Hotel Lindenhof, Genusswerk Catering) with four locations, and seven shifts in the next nine days: six published and one draft. Alpen Events has one client with one published shift. Five claims are pending at Donau Personal: Lena Hofer has one on "Service Hochzeit", "Lagerunterstützung" has two of five spots taken and "Barkeeper:in Hochzeit" is full. The dispatchers and admins have fictional names, two of them a phone number; they are the contact persons of the shifts. Donau Personal has four shift templates, one for each location ("Messe Nachtabbau" runs past midnight), and Alpen Events has one. The shifts are dated relative to the day the database was seeded, so an old demo database shows them in the past; `docker compose down -v` gives fresh ones.

Donau Personal uses check-in in the app (ADR 0028). Jakob Steiner and Paul Winkler worked the "Inventur" three days ago and checked in and out; Jakob's hours are approved, Paul's wait for a dispatcher. Both worked "Auf- und Abbau Messe" about a month ago, with approved hours, so the payroll export has rows. "Service Tagung" starts 20 minutes after the data was seeded and Lena Hofer has a confirmed spot, so check-in can be tried right away; to try it later, reset the database with `docker compose down -v`.

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
| `seed` | Fictional demo data for development machines (`local` profile) |
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
- Requests are validated with Bean Validation on the request records; a rule without a standard constraint gets its own, like `@DateOfBirth`. A value that cannot be read as the type of its field is reported as `invalid_format` for that field.
- A rule that needs more than one field or a lookup, such as an end before the start or the id of a client the agency does not have, throws `InvalidFieldException` with the field and a code. It is reported like any other validation error.
- Money crosses the API as an integer number of euro cents (`hourlyRateCents`) and is a `decimal` in euros in the database.
- Personal data such as the date of birth is never logged and never part of an event payload.
- `shiftboard.api.version` in `application.yaml` is the contract version the backend implements; a test compares it with the spec.
- Hibernate only validates the schema (`ddl-auto=validate`). Schema changes are new Flyway migrations.
- Times are `timestamptz` in UTC, money is `decimal`, IDs are UUID v7, every tenant-owned table carries `agency_id`.
