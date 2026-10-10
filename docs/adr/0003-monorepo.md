# 0003: One monorepo, independent releases per app

Status: accepted (2026-10-10)

## Context

The backend, the worker app and the dashboard all depend on the same API contract and the same design tokens. Spread over several repositories, a single feature would need coordinated pull requests and the contract could drift.

## Decision

One repository with a folder per part: `backend/`, `mobile/`, `dashboard/`, `api/`, `design-tokens/` and `docs/`. Each app is built, versioned and released on its own. CI runs per folder using path filters.

## Consequences

- A vertical slice, from the spec change to both clients, fits in one repository and one history.
- CI only runs the jobs for the folders a change touches.
- The repository mixes three toolchains (Gradle, Flutter, Node); the root stays free of tool-specific setup beyond Docker Compose and shared scripts.
