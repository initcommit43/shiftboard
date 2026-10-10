# shiftboard

Shift distribution platform for staffing agencies: agencies publish short-term shifts, workers from their own pool claim them in a mobile app, and both sides communicate in one place.

"shiftboard" is a codename until the real name is decided.

## What it is

Many staffing agencies send job offers by SMS several times a day. It is first come, first served, nobody knows whether spots are still open, and coordination is split across several channels.

shiftboard replaces that with one flow:

1. A dispatcher posts a shift in the agency dashboard.
2. Workers with matching qualifications see it in the app, with open spots, hourly rate and estimated earnings.
3. A worker claims a spot; the agency confirms it, or claims are confirmed automatically.
4. Both sides message each other in the app, with the shift attached.

The core flow is fixed. Branding, wording, workflow rules, qualifications and optional modules are configured per agency.

## Stack

| Folder | What | Technology |
| --- | --- | --- |
| `backend/` | API and domain logic | Spring Boot modular monolith (Java), PostgreSQL |
| `mobile/` | Worker app for iOS and Android | Flutter, Riverpod |
| `dashboard/` | Agency dashboard | React, TypeScript, Vite, shadcn/ui, Tailwind |
| `api/` | API contract, the single source of truth | OpenAPI |
| `design-tokens/` | One token source for both frontends | Style Dictionary |
| `docs/` | Architecture decisions | [ADRs](docs/adr/) |

Both API clients are generated from the OpenAPI spec.

## How to run

The scaffold is being built. This section is filled in once the stack starts locally with one command.

## Screenshots

Added with the first slice.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).
