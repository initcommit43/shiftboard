# 0004: Flutter worker app and React agency dashboard

Status: accepted (2026-10-10)

## Context

The two user groups work on different devices: workers on their phones, dispatchers and admins at a desk. Workers need a polished mobile experience with push notifications; the agency needs tables and forms.

## Decision

- Worker app: Flutter for iOS and Android. Feature-first structure (`lib/features/<feature>/data|presentation`), with a domain layer only where real logic lives. Riverpod for state.
- Agency dashboard: React and TypeScript in strict mode, built with Vite, using shadcn/ui components and Tailwind.
- The worker side is built once, in Flutter only; there is no worker web view. A client portal comes later as a role inside the dashboard.

## Consequences

- Each frontend uses the technology that suits its device and its kind of UI.
- Two frontend stacks have to be maintained. Generated API clients (ADR 0006) and shared design tokens (ADR 0011) keep them consistent.
- Workers need the installed app; there is no browser fallback.
