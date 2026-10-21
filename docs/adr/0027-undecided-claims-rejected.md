# 0027: Requests nobody decided on are rejected when the shift ends

Status: accepted (2026-10-21)

## Context

With approval switched on, a worker's request stays `PENDING` until a dispatcher approves or rejects it. When a shift ends and a request is still pending, the request has to end somehow so it stops holding a spot and the history is complete. The concept didn't cover this case. `REJECTED` and `CANCELLED` were the options; it was built as `REJECTED` in slice 2 (#69) and confirmed on 2026-10-21.

## Decision

- When the completion job completes a shift (ADR 0023), every request still `PENDING` becomes `REJECTED`. Confirmed claims become `COMPLETED` as before.
- The worker is told like for any rejection: the "rejected" system message in the chat and its push.

## Consequences

- From the worker's view the request simply wasn't accepted, and "Meine Schichten" shows it that way.
- `CANCELLED` stays reserved for someone actively calling something off: the worker, a removal or a cancelled shift.
- The dashboard history can't tell an explicit rejection from one by the job. If agencies need that, it needs its own marker.
