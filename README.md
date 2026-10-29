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

## Getting started

Needs Docker, JDK 25, Node.js 24 and Flutter 3.47.

**Backend and database**

```
docker compose up --build
```

Starts PostgreSQL and the backend on http://localhost:8080 and loads fictional demo data. No setup is needed; to change ports or credentials, copy `.env.example` to `.env`.

**Dashboard**

```
cd dashboard
npm ci
npm run dev
```

Opens on http://localhost:5173 and proxies `/api` to the backend.

**Worker app**

```
cd mobile
flutter pub get
flutter run
```

On the Android emulator the app reaches the backend through `10.0.2.2`. For another host, pass `--dart-define=API_BASE_URL=http://<host>:8080/api/v1`.

**Demo accounts**

All demo accounts use the password `shiftboard-demo`.

| Where | Account | What you see |
| --- | --- | --- |
| Dashboard | `dispatcher1.donau@example.com` | Dispatcher of "Donau Personal" with pending signups |
| Dashboard | `dispatcher.alpen@example.com` | Dispatcher of a second agency, to see tenant isolation |
| Dashboard | `kunde.nordlicht@example.com` | Client portal of "Nordlicht Logistik": its shifts and who is coming. "Karl Huber" of the same client is invited and has no password yet |
| App | `lena.hofer@example.com` | Active worker |
| App | `emma.koller@example.com` | Worker waiting for approval |
| App | `simon.egger@example.com` | Inactive worker |

To sign up a new worker, open `shiftboard://join/donau-demo` on the device or paste the code `donau-demo` after tapping "Registrieren".

Tests, client generation and the other development commands are in [CONTRIBUTING.md](CONTRIBUTING.md#development).

## Screenshots

Added with the first slice.

## Team

| Who | Parts |
| --- | --- |
| [@initcommit43](https://github.com/initcommit43) | Architecture and API, design, DevOps, backend, worker app, dashboard |

Review requests follow [CODEOWNERS](.github/CODEOWNERS).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

All rights reserved. The code is published for viewing only; see [LICENSE](LICENSE).
