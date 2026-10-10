# 0008: Overbooking protection with optimistic locking

Status: accepted (2026-10-10)

## Context

Shifts are claimed first come, first served, often by several workers within seconds of a notification. A shift must never end up with more assignments than slots, and a worker must never hold two assignments for the same shift.

## Decision

- Claiming runs in one transaction inside the domain model: check for a free slot, the required qualifications and an existing claim, create the assignment, increment `taken_slots`.
- The shift carries a `@Version` column. A concurrent claim fails the version check and the worker is told that the shift just filled up.
- A unique constraint on (`shift_id`, `worker_id`) blocks double claims at the database level.
- Rejections and cancellations decrement `taken_slots` again.

## Consequences

- Correctness is guaranteed by the database, not by application-level locks, so it holds across several instances.
- No lock is held while a claim is processed; contention only costs the losing request.
- A failed version check on the last slot is an expected outcome and is mapped to a clear error, not retried blindly.
- The concurrent claim on the last slot needs its own integration test.
