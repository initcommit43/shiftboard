# 0007: Authentication and security basics

Status: accepted (2026-10-10)

## Context

Workers log in to the mobile app, dispatchers and admins to the dashboard. The API is stateless and serves both. Logging out has to end the session on one device, and the login endpoint must not be open to password guessing.

## Decision

- Spring Security with JWT. Login is email and password; passwords are stored only as a hash.
- A short-lived access token plus a refresh token. Refresh tokens are stored server-side, rotated on every use and revoked on logout.
- The role is checked per client: workers on the app, dispatchers and admins on the dashboard. A role on the wrong client is rejected.
- Wrong credentials always produce the same generic error.
- Login attempts are rate limited.
- Password reset works through a single-use, time-limited token sent by email. It is built as its own issue once email sending exists, not as part of slice 0.

## Consequences

- Requests are authenticated without a session lookup; only refreshing and logging out touch the database.
- A stolen access token is valid only for a short time, and a reused refresh token can be detected through rotation.
- Both clients need refresh handling and secure token storage.
- Until password reset is built, a forgotten password needs manual help from the agency.
