# 0005: Contract-first API and API conventions

Status: accepted (2026-10-10)

## Context

Three codebases share one API. If the contract is derived from the backend code, the clients learn about changes late, and conventions drift from endpoint to endpoint.

## Decision

- The OpenAPI spec in `api/` is the single source of truth. Every API change starts as a change to the spec, before any code.
- REST under `/api/v1`.
- Errors are RFC 9457 problem details.
- Lists use page/size pagination.
- IDs are UUID v7.
- Changes stay backward compatible, because installed app versions lag behind the backend.

## Consequences

- Backend, dashboard and app can be built in parallel once the spec change is merged.
- The backend has to be kept in line with the spec; CI lints the spec and checks that the generated clients are up to date.
- Removing or renaming a field takes a deprecation period instead of a single change.
- UUID v7 IDs sort by creation time, which keeps indexes compact, and they can be generated without a database round trip.
