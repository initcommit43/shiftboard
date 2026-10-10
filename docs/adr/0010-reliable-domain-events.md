# 0010: Reliable domain events with the Spring Modulith event publication registry

Status: accepted (2026-10-10)

## Context

Modules communicate through domain events (ADR 0001). With in-memory events only, an event is lost when the application stops between the commit and the listener: an assignment would be confirmed, but the system message and the push notification would never be sent.

## Decision

Events that cross a module boundary go through the Spring Modulith event publication registry, backed by the database. The publication is stored in the same transaction as the change, listeners run after the commit, and incomplete publications are retried.

## Consequences

- An event is delivered at least once, without introducing a message broker.
- Listeners may run more than once and have to be idempotent.
- The registry adds a table and needs completed publications to be cleaned up.
- A later move to a broker stays possible, since Spring Modulith can externalize the same events.
