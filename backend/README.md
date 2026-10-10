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

The application reads `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER` and `DB_PASSWORD` and falls back to the local development values from `.env.example`. Flyway migrates the schema on startup.

| URL | What |
| --- | --- |
| `http://localhost:8080/api/v1/ping` | Service status and contract version |
| `http://localhost:8080/actuator/health` | Health, the only exposed actuator endpoint |

## Test

```sh
./gradlew build
```

Integration tests start PostgreSQL through Testcontainers, so Docker has to be running. `ModularityTests` verifies the module boundaries and writes module diagrams to `build/spring-modulith-docs/`.

## Layout

Base package `app.shiftboard`. Each direct subpackage is a Spring Modulith application module: its top-level package is the module's public API, subpackages are internal. Modules talk to each other through domain events.

| Module | Responsibility |
| --- | --- |
| `agency` | Agencies as tenants, their dispatchers and per-agency settings |
| `worker` | Workers in an agency's pool and their qualifications |
| `client` | Clients of an agency and the locations their shifts take place at |
| `shift` | Shifts an agency publishes, with their slots and requirements |
| `assignment` | Claims of workers on shifts, their confirmation and cancellation |
| `messaging` | Conversations between an agency and its workers |
| `notification` | Push notifications sent in reaction to events of other modules |
| `system` | Service status, `/api/v1` path prefix, problem details |

```
src/main/java/app/shiftboard/<module>/   module code
src/main/resources/application.yaml      configuration
src/main/resources/db/migration/         Flyway migrations (plain SQL, never edited once applied)
src/test/java/app/shiftboard/            modularity and integration tests
```

## Conventions

- Controllers are `@RestController`s with paths relative to `/api/v1`; the prefix is added centrally.
- Errors are RFC 9457 problem details (`application/problem+json`).
- `shiftboard.api.version` in `application.yaml` is the contract version the backend implements; a test compares it with the spec.
- Hibernate only validates the schema (`ddl-auto=validate`). Schema changes are new Flyway migrations.
- Times are `timestamptz` in UTC, money is `decimal`, IDs are UUID v7, every tenant-owned table carries `agency_id`.
