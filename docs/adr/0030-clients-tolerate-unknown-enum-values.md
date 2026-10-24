# 0030: Generated clients tolerate unknown enum values

Status: accepted (2026-10-24)

## Context

The generated Dart client failed on enum values it did not know. Installed app versions lag behind the backend, so every new enum value would have broken them. ADR 0026 and ADR 0029 worked around it: the shift-changed and waitlist system messages went out without an `event`, and the waitlist got its own field instead of an assignment status. No app build has been distributed yet, so the clients can still change without old installs to care about (#122).

## Decision

- **Both generators run with `enumUnknownDefaultCase`.** Every generated enum gets a fallback value (`unknownDefaultOpenApi` in Dart, `unknown_default_open_api` in TypeScript). The Dart client maps values it does not know to it. The TypeScript client passes them through unchanged, so the dashboard checks values with `known()` (`dashboard/src/api/enums.ts`) or a lookup before it uses them as keys.
- **The clients fall back where they word or style enum values.** A system message whose event the client does not word shows its `body`. An unknown status shows no badge in the app and "Unbekannt" in the dashboard, and allows no actions.
- **New enum values are backward compatible** for clients built from now on, so the API can add them like any other optional change.
- **`SystemEvent` lists every event**, including `SHIFT_CHANGED` and the four waitlist events. The app and dashboard word the waitlist events; a shift change keeps showing its `body`, which says what changed.

This supersedes the enum reasoning in ADR 0026 and ADR 0029 for system events only. The `waitlist` field on `WorkerShift` and the hidden `WAITLISTED` assignment status from ADR 0029 stay as they are.

## Consequences

- Adding an enum value no longer needs a workaround, but a client still has to be updated to word or handle the new value well.
- Code that switches over a generated enum needs a fallback branch. Dart does not enforce it for built_value enums, so reviews and tests cover it.
- The dashboard has to check values before indexing, because its types claim a closed set while the data may hold more.
