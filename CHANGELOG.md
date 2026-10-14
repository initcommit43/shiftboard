# Changelog

Notable changes per slice. One version tag per completed slice during the MVP.

## Unreleased: slice 1, create, see and claim a shift

### Added

- Dispatchers create a shift for a client and location in the dashboard, published right away or saved as a draft, and publish drafts later.
- The dashboard lists the upcoming shifts with their status and taken vs. total spots.
- Workers see the agency's upcoming shifts in the app as cards with date and time, place, estimated pay and spots left; full shifts stay in the list, marked as full.
- Workers open a shift for its description, requirements and contact person, open the address in a maps app and call the contact.

## v0.1.0 (2026-10-13): slice 0, skeleton, signup and login

### Added

- Monorepo with a Spring Boot backend, a Flutter worker app, a React dashboard, an OpenAPI contract with generated Dart and TypeScript clients, and design tokens generated into both frontends.
- Local stack with one command (`docker compose up`), including fictional demo data.
- CI per folder with path filters.
- Workers sign up through an agency's invitation link or code and wait for approval. The signup asks for name, date of birth, email, phone and password.
- Dispatchers approve or reject pending signups in the dashboard.
- Login and logout with email and password: workers in the app, dispatchers and admins in the dashboard.
