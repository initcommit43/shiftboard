# 0008: Overbooking protection with optimistic locking

Status: accepted (2026-10-10)

## Context

Shifts are claimed first come, first served, often by several workers within seconds of a notification. A shift must never end up with more assignments than slots, and a worker must never hold two assignments for the same shift.

## Decision

- Claiming runs in one transaction inside the domain model: check for a free slot and an existing claim, create the assignment, increment `taken_slots`. Qualifications are not checked in the MVP ([ADR 0021](0021-qualifications-information-only.md)).
- The shift carries a `@Version` column. A concurrent claim fails the version check and the worker is told that the shift just filled up.
- A unique constraint on (`shift_id`, `worker_id`) blocks double claims at the database level.
- Rejections and cancellations decrement `taken_slots` again.

## Consequences

- Correctness is guaranteed by the database, not by application-level locks, so it holds across several instances.
- No lock is held while a claim is processed; contention only costs the losing request.
- A failed version check is an expected outcome. The claim is tried again a few times, each time reading the shift anew, so a worker is only told that the shift filled up when it did, not when another claim on a shift with spots left was merely faster. If the attempts run out, the answer is the same clear error.
- The concurrent claim on the last slot needs its own integration test.
