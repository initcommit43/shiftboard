# 0013: German first, i18n from the start

Status: accepted (2026-10-10)

## Context

The reference market is German-speaking, but wording is one of the things agencies differ on (for example "Schicht" or "Einsatz"), and an English version should not require a rewrite later.

## Decision

- Both frontends ship in German first.
- Localization is set up from the first screen: no user-facing string is hardcoded in a widget or component.
- English is added as a translation, not as a code change.
- Code, API field names, commits and documentation are in English. Machine-readable error codes come from the API; the clients translate them.

## Consequences

- Adding a language or changing an agency's terminology means editing localization files only.
- Every new screen carries the small cost of adding its strings to the localization files.
- Dates, times and currency are formatted through the locale, not by hand.
