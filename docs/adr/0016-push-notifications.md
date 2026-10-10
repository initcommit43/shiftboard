# 0016: Push notifications via Firebase Cloud Messaging

Status: accepted (2026-10-10)

## Context

The app replaces job offers sent by SMS, so workers have to learn about new shifts and decisions without opening it. The MVP requires the app; there is no SMS or email fallback.

## Decision

- Push is sent through Firebase Cloud Messaging for both iOS and Android.
- It is sent for: a new shift matching the worker's qualifications, a claim approved or rejected, a shift cancelled or changed by the agency, and a new chat message or broadcast.
- The `notification` module sends push in reaction to domain events. No other module calls it.
- Workers can pause new-shift notifications.

## Consequences

- One provider and one integration cover both platforms.
- The app depends on Firebase configuration files, which are kept out of the repository.
- Push is not guaranteed to arrive, so the app always loads the current state from the API and never relies on a notification's content.
- A worker without the app, or with notifications disabled, is not reached. That is accepted for the MVP.
