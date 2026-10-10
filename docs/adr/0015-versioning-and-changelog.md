# 0015: Versioning and changelog

Status: accepted (2026-10-10)

## Context

The apps are released independently in the long run (ADR 0003), but during the MVP they move together slice by slice and nothing is deployed yet.

## Decision

- During the MVP, one tag per completed slice for the whole repository: `v0.1.0` for slice 0, `v0.2.0` for slice 1, and so on.
- The changelog is written by hand in `CHANGELOG.md` when a slice closes.
- Per-app tags are introduced when the apps start shipping separately (Phase 3). That change gets its own ADR.

## Consequences

- A tag always marks a demoable state of the whole system.
- No release tooling has to be set up or maintained yet.
- The changelog stays readable because it describes capabilities, not commits. Conventional Commits keep generating it from history possible later.
