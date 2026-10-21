# 0024: Push notifications are off until Firebase is configured

Status: accepted (2026-10-17)

## Context

ADR 0016 chose Firebase Cloud Messaging. Sending needs a Firebase project: a service account key for the backend and the project's app configuration for the worker app. Neither may be committed, and the project does not exist yet. Development, CI and demos have to work without it.

## Decision

- The backend sends through the FCM HTTP v1 API when `FCM_CREDENTIALS_FILE` points to a service account key. Without it, a logging sender takes its place and records that a push would have gone out, without tokens or text.
- The worker app sets up Firebase only when its options are passed at build time (`--dart-define-from-file` with a local, ignored file). Without them it skips registration and works as before.
- Devices are stored per worker as FCM tokens. A token the push service reports as unknown is deleted.
- Push texts are German, the app's first language (ADR 0013). They carry the shift id and a type, so the app can open the right screen; the app always loads the current state from the API (ADR 0016).
- Push is sent in the background after the change is committed, so no request waits for FCM.

## Consequences

- Everything around push (registration, preferences, the events that trigger it) is built and tested without a Firebase project, with a recording sender in the tests.
- Turning push on is configuration: create the Firebase project, set `FCM_CREDENTIALS_FILE` on the backend, pass the app options at build time, and enable push notifications and an APNs key for iOS in Xcode and Firebase.
- Push texts do not follow the language the worker uses in the app until the backend knows it.
