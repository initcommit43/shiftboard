# 0012: Flutter routing with go_router

Status: accepted (2026-10-10)

## Context

The worker app needs declarative routing with guards (logged out, pending approval, active) and deep links from push notifications into a shift or the chat. The options were go_router and auto_route.

## Decision

go_router. Redirects are driven by the authentication state held in Riverpod.

## Consequences

- The package is maintained by the Flutter team and needs no code generation.
- Guards are one redirect function, which keeps the pending and logged-out flows in one place.
- Routes are less strictly typed than with auto_route; route paths and parameters are kept in one file to compensate.
