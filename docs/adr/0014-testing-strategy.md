# 0014: Testing strategy

Status: accepted (2026-10-10)

## Context

The rules that matter most (claiming, overbooking, cancellation deadlines, tenant isolation) sit in the backend. Tests should cover them reliably without a slow and brittle suite across three codebases.

## Decision

- Unit tests for domain rules, always.
- Integration tests for the API against a real PostgreSQL through Testcontainers.
- A Spring Modulith test for module boundaries.
- Widget tests in the Flutter app and component tests in the dashboard.
- No end-to-end tests yet. Each slice is verified by a manual walkthrough with seed data.

## Consequences

- Database behaviour such as constraints, optimistic locking and the tenant filter is tested against the real database, not an in-memory substitute.
- Integration tests need Docker, both locally and in CI.
- Faults that only show up across the apps and the backend are caught by the walkthrough, not automatically. End-to-end tests are added once the flows are stable.
