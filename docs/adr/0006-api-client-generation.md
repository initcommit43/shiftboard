# 0006: API clients generated with openapi-generator

Status: accepted (2026-10-10)

## Context

The Dart client for the worker app and the TypeScript client for the dashboard must match the spec exactly. The options were one generator for both languages or a dedicated generator per language.

## Decision

Both clients are generated with openapi-generator: `dart-dio` for the worker app and `typescript-fetch` for the dashboard. One script regenerates both. The generated code is committed, and API models are never written by hand in the clients.

## Consequences

- One tool, one version to pin and one script instead of two toolchains.
- CI can regenerate the clients and fail when the committed code differs from the spec.
- The generated code is less idiomatic than a language-specific generator would produce; thin wrappers in the apps hide that where it matters.
- If one generator turns out to be a real limitation, it can be replaced for that language without touching the spec.
