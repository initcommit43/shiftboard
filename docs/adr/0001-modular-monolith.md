# 0001: Spring Boot modular monolith on PostgreSQL

Status: accepted (2026-10-10)

## Context

The platform covers several distinct areas (agencies, workers, shifts, assignments, messaging, notifications) but is built and operated by one person, possibly a small team later. Microservices would add deployment and consistency overhead without a matching benefit; an unstructured monolith would lose the boundaries between those areas.

## Decision

- One deployable Spring Boot application (Java) with PostgreSQL.
- Code is packaged by feature module: `agency`, `worker`, `client`, `shift`, `assignment`, `messaging`, `notification`, later `timetracking` and `export`.
- Each module exposes a small public API. Boundaries are verified with Spring Modulith in a test that runs in CI.
- Modules communicate through domain events, not by calling into each other's internals.
- The core has a rich domain model: rules live in the entity (`shift.claim(...)`), not in services. Simple CRUD modules stay plain.

## Consequences

- One build, one deployment, one database transaction per use case.
- A boundary violation fails the build instead of going unnoticed.
- Optional modules such as messaging can be switched off without breaking the others, because nothing calls them directly.
- Event-driven flows are harder to follow than direct calls; event names and listeners need to stay easy to find.
- A module can be extracted into its own service later if that is ever needed.
