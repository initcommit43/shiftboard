# 0026: Shifts stay editable until they start, and workers are told what changed

Status: accepted (2026-10-20)

## Context

Shifts could only be created, published and cancelled. A typo in the meeting point or a start moved by an hour meant cancelling the shift and posting it again, which drops every claim. The "shift changed by the agency" push from S3-5 had nothing to trigger it.

Three questions were open (#84): which fields may change once workers have claimed, what happens when the spots drop below the workers who hold one, and whether a change sends a system message.

## Decision

- **Every field stays editable** until the shift starts: client, location, title, description, start, end, "end is estimated", hourly rate, spots and qualifications. A draft stays editable at any time. A shift that has started, ended, been cancelled or completed cannot be edited (`shift_not_editable`).
- **Spots never drop below the workers who hold one.** Confirmed and pending claims both take a spot, so fewer spots than that is rejected on the `slots` field (`below_taken`); the dispatcher rejects or removes someone first. No worker loses a spot by accident.
- **A new time must not double-book anyone.** A worker who holds a spot keeps it at the new time; if that overlaps another shift they hold, the edit is rejected (`shift_overlap`). The booked time of each claim follows the shift.
- **Workers who hold a spot are told:** a system message in their chat that says what changed with the new values, and the "shift changed" push. Saving without a change tells nobody.
- **The system message has no `event` in the API for now.** The generated Dart client rejects enum values it does not know, so a new `SystemEvent` would break installed app versions. The message carries its German text in `body`, which both clients already show when `event` is absent. The database stores it as `SHIFT_CHANGED`, so the API can expose it once the clients accept unknown values.

## Consequences

- Dispatchers fix mistakes without losing claims; a worker is never moved silently.
- An edit can fail because of other shifts of the workers on it, and the error says so.
- The shift-change message is German in both clients until it gets its event; it is the first system message without one.
- Changes are not versioned: the message names the new values, not the old ones.
