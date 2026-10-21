# Contributing

How work gets into this repository. The reasons behind the larger decisions are in [`docs/adr/`](docs/adr/).

## Slices

Work happens in vertical slices: one user-facing capability, built end to end and demoable on its own. One slice is one GitHub milestone; its issues are user stories and technical tasks.

Order within a slice:

1. **Define:** user stories with acceptance criteria as issues
2. **Design:** screens for new UI, including empty, loading and error states
3. **Contract:** change the OpenAPI spec first, then regenerate the Dart and TypeScript clients
4. **Backend:** domain rules with tests first, then endpoints
5. **Dashboard:** minimal UI for the slice's data
6. **Worker app:** polished UI on the generated client
7. **Verify:** Definition of Done per issue, end-to-end walkthrough with seed data
8. **Close:** changelog, version tag, short retro

API models in the clients always come from the generated code and are never written by hand.

## Issues

An issue is ready to be worked on when it has:

- a story or task with acceptance criteria
- a slice milestone and an area label (`backend`, `mobile`, `dashboard`, `api`, `design`, `docs`, `chore`, `bug`)
- the API changes it needs in the merged spec
- designs linked, for UI work
- a size that fits one pull request of a few days

## Branches

- `main` is always releasable. Nobody pushes to it directly.
- Work on short-lived branches named after the issue: `feat/<issue>-<slug>`, `fix/<issue>-<slug>`, `chore/<slug>`. Example: `feat/12-claim-shift`.

## Commits

[Conventional Commits](https://www.conventionalcommits.org/), with an optional scope:

```
feat(shift): reject claims on shifts that have started
```

- Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `ci`.
- Subject line short and imperative, about 72 characters at most. Add a body only when the reason is not obvious.
- One commit per complete, meaningful unit of work. Every commit leaves the code in a working state.

## Pull requests

- One issue or story per pull request. Split large work into several.
- Title in Conventional Commit style; it becomes the commit on `main`, because pull requests are squash merged.
- Fill in the template: what and why, how it was tested, screenshots for UI changes, linked issue.
- CI must be green.
- Working solo: review your own pull request after a break, against the Definition of Done. With a team: one approval from someone else.

## Definition of Done

- [ ] Acceptance criteria of the issue met
- [ ] Tests for new logic (domain rules always)
- [ ] CI green
- [ ] Spec and generated clients updated if the API changed
- [ ] Docs or ADR updated if a decision changed

## Development

Needs Docker, JDK 25, Node.js 24 and Flutter 3.47. Starting the stack, the demo accounts and the signup code are described under "Getting started" in the [README](README.md#getting-started).

**Local stack** (repo root)

```
docker compose up --build     PostgreSQL and backend on :8080, demo data loaded on startup
docker compose down -v        stop and reset the database
docker compose up -d db       database only, to run the backend from Gradle
```

Seed data loads automatically in the `local` profile, which docker compose and `bootRun` use, and is skipped when it already exists.

**Backend** (`backend/`)

```
./gradlew bootRun     run against the compose database
./gradlew build       unit tests, module boundary test, integration tests (needs Docker)
```

**API contract and generated clients** (`api/`)

```
npm ci
npm run lint          lint openapi.yaml
npm run generate      regenerate the Dart and TypeScript clients (needs Java and Dart)
npm run check         fail if the committed clients differ from the spec
```

**Design tokens** (`design-tokens/`)

```
npm ci
npm run build         regenerate the CSS variables and the Dart constants
npm run check         fail if the committed outputs differ from the tokens
```

**Dashboard** (`dashboard/`)

```
npm ci
npm run dev           http://localhost:5173, proxies /api to the backend
npm run lint
npm run typecheck
npm test
npm run build
```

**Worker app** (`mobile/`)

```
flutter pub get       also generates the localizations
flutter run           add --dart-define=API_BASE_URL=http://<host>:8080/api/v1 for another host
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

**Push notifications** are off until Firebase is configured (ADR 0024). The backend sends through FCM when `FCM_CREDENTIALS_FILE` points to the service account key of the Firebase project; without it, it only logs. Key files are ignored by Git; keep them outside the repository.

Push notifications in the app need a Firebase project (ADR 0024). Copy `mobile/firebase.json.example` to `mobile/firebase.json` (ignored by Git), fill in the project's values and run `flutter run --dart-define-from-file=firebase.json`. Without it the app runs without push. On iOS, push also needs the Push Notifications capability in Xcode and an APNs key in Firebase.

CI runs the same checks per folder; see `.github/workflows/`. Each folder's README has more detail.

## Privacy and secrets

- No personal information in the repository. Seed data, demo data, tests and screenshots use fictional agencies, clients and people only.
- No secrets: no tokens, keys, passwords or `.env` files. Configuration comes from environment variables; `.env.example` holds placeholders.

## Decisions

A decision that shapes the codebase gets a short ADR in `docs/adr/` (`NNNN-title.md` with Context, Decision, Consequences). A changed decision gets a new ADR that supersedes the old one.
