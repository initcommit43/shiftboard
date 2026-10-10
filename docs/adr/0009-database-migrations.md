# 0009: Database migrations with Flyway

Status: accepted (2026-10-10)

## Context

The schema has to evolve in versioned, repeatable steps, both locally and in production. The options were Flyway and Liquibase.

## Decision

Flyway with plain SQL migrations, run on application startup. Hibernate only validates the schema (`ddl-auto=validate`) and never changes it.

## Consequences

- Migrations are ordinary PostgreSQL, readable in review and free to use database-specific features.
- A migration that has been applied is never edited; corrections are new migrations.
- The mapping and the schema cannot drift apart unnoticed, because validation fails at startup.
- The database-independent changelog and generated rollbacks that Liquibase offers are given up; neither is needed on a PostgreSQL-only project.
