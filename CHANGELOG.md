# Changelog

Notable changes per slice. One version tag per completed slice during the MVP.

## Unreleased: slice 0, skeleton, signup and login

### Added

- Monorepo with a Spring Boot backend, a Flutter worker app, a React dashboard, an OpenAPI contract with generated Dart and TypeScript clients, and design tokens generated into both frontends.
- Local stack with one command (`docker compose up`), including fictional demo data.
- CI per folder with path filters.
- Workers sign up through an agency's invitation link or code and wait for approval.
- Dispatchers approve or reject pending signups in the dashboard.
- Login and logout with email and password: workers in the app, dispatchers and admins in the dashboard.
