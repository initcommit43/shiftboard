# Changelog

Notable changes per slice. One version tag per completed slice during the MVP.

## v0.7.0 (2026-10-23): slice 6, waitlist

### Added

- Workers join the waitlist of a full shift in the app and see their place in line ("Warteliste · Platz 2"), also under "Meine". Leaving is possible until the start, and joining again puts them at the back.
- When a spot frees up before the cancellation deadline, the first in line moves up automatically into a request, or is confirmed right away with auto-confirm, and gets a system message and a push. Anyone who is booked for an overlapping shift by then is skipped and told. After the deadline, everyone waiting gets a "Platz frei" push and the first to claim gets the spot (ADR 0029).
- Dispatchers see a shift's waitlist in line order on its detail page and can take a worker off it; the shift list shows how many are waiting.
- Admins switch the waitlist on or off in the workflow settings; it is off by default.
- App versions without the waitlist keep working: it is exposed as its own field, not as a new claim status.
- Demo data has a full shift with three workers waiting.

### Fixed

- Two dashboard tests that failed under load: the hours page test raced a router update, and toasts leaked from one test into the next.

## v0.6.0 (2026-10-21): slice 5, check-in/out and payroll export

### Added

- Workers check in and out of a confirmed shift in the app, from 30 minutes before the start; only the times are stored, no location. Check-out stays possible after the planned end until the agency approves the hours (ADR 0028).
- Admins switch check-in in the app on or off under "Zusatzfunktionen"; it is off by default.
- Dispatchers approve each worker's hours on the shift detail page. The form suggests the check-in times or the planned times and a 30-minute break over six hours, and shows hours and gross pay. Approved hours can be changed again.
- A "Stunden" page lists the hours of a period, open ones first, and exports the approved ones as a CSV file for payroll that opens correctly in Excel for German and Austrian users.
- A worker who checked in or has approved hours can't be marked as a no-show.
- Demo data has check-in times, open and approved hours, and a shift that starts right after seeding to try check-in.

## v0.5.0 (2026-10-21): slice 4, duplicate shifts, shift templates and editing shifts

### Added

- Dispatchers duplicate any shift, cancelled and past ones included. The new-shift form opens filled in with everything but the date; overnight shifts keep their length, and claims and messages are not copied.
- Dispatchers save a shift as a named template, from the new-shift form or a shift's detail page. Templates are shared across the agency, names are unique, and a template keeps the time of day and the length (ADR 0025).
- Dispatchers start a new shift from a template and only pick the date. A client, location or qualification that no longer exists is left empty and named in a note.
- A templates page lists the agency's templates and lets dispatchers edit, rename and delete them. Deleting a template leaves the shifts made from it as they are.
- Dispatchers edit a draft, or a published shift until it starts, even after workers claimed it (ADR 0026). Every worker holding a spot gets a system message saying what changed and a "Schicht geändert" push. Fewer spots than are taken, and a new time that would double-book a worker, are rejected.
- Demo data has five fictional shift templates, one of them overnight.

## v0.4.0 (2026-10-21): slice 3, messaging and notifications

### Added

- Workers message their agency in the app's "Nachrichten" tab, optionally about a shift, with an unread count on the tab.
- Dispatchers answer every worker from one shared inbox in the dashboard, with unread counts per conversation and in the navigation.
- Confirmations, rejections, removals, drop-outs and cancelled shifts appear as system messages in the worker's chat, worded in the reader's language.
- Dispatchers send a message to all confirmed workers of a shift at once.
- Push notifications for a new shift, a decision on a claim, a removal, a cancelled shift and messages from the agency. Tapping one opens the shift or the chat. Push is off until a Firebase project is configured; until then the backend only logs (ADR 0024).
- Workers pause new-shift notifications on the new "Profil" tab; decisions, cancellations and messages still arrive.
- Admins switch on a WhatsApp button for the shift's contact person, shown next to the call button in the app.

## v0.3.0 (2026-10-17): slice 2, approve, reject and cancel

### Added

- A shift detail page in the dashboard with the open requests oldest first, the staffed workers and the history of every claim.
- Dispatchers approve or reject requests, remove a confirmed worker with a reason the worker does not see, and cancel a whole shift with all its claims.
- Shifts complete on their own after they end: confirmed claims become worked, undecided requests are rejected. Dispatchers mark no-shows on a list of past shifts.
- Workers drop out of a shift in the app until the agency's cancellation deadline. After it, the shift points them to the contact person. "Meine Schichten" says who cancelled a claim.
- Admins set auto-confirm and the cancellation deadline (default 24 hours) on the settings page; dispatchers see them read-only.
- Background jobs run with `@Scheduled` and ShedLock (ADR 0023).

## v0.2.0 (2026-10-17): slice 1, create, see and claim a shift

### Added

- Dispatchers create a shift for a client and location in the dashboard, published right away or saved as a draft, and publish drafts later.
- The dashboard lists the upcoming shifts with their status and taken vs. total spots.
- Workers see the agency's upcoming shifts in the app as cards with date and time, place, estimated pay and spots left; full shifts stay in the list, marked as full.
- Workers open a shift for its description, requirements and contact person, open the address in a maps app and call the contact.
- Workers request a spot on a shift from its detail after confirming in a sheet; the spot is held while the agency decides. Full shifts, double requests, started shifts and overlaps are explained.
- Workers see the shifts they requested under "Meine Schichten" with the status of each request.

## v0.1.0 (2026-10-13): slice 0, skeleton, signup and login

### Added

- Monorepo with a Spring Boot backend, a Flutter worker app, a React dashboard, an OpenAPI contract with generated Dart and TypeScript clients, and design tokens generated into both frontends.
- Local stack with one command (`docker compose up`), including fictional demo data.
- CI per folder with path filters.
- Workers sign up through an agency's invitation link or code and wait for approval. The signup asks for name, date of birth, email, phone and password.
- Dispatchers approve or reject pending signups in the dashboard.
- Login and logout with email and password: workers in the app, dispatchers and admins in the dashboard.
