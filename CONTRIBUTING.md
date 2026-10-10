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

## Privacy and secrets

- No personal information in the repository. Seed data, demo data, tests and screenshots use fictional agencies, clients and people only.
- No secrets: no tokens, keys, passwords or `.env` files. Configuration comes from environment variables; `.env.example` holds placeholders.

## Decisions

A decision that shapes the codebase gets a short ADR in `docs/adr/` (`NNNN-title.md` with Context, Decision, Consequences). A changed decision gets a new ADR that supersedes the old one.
