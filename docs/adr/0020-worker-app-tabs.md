# 0020: Tabs of the worker app

Status: accepted (2026-10-11)

## Context

The mobile design system describes a tab bar with four tabs: shifts, calendar, earnings and profile. The app was built with shifts, my shifts, messages and profile, which follows the MVP: workers claim shifts, track their own, and message the agency in the app. The design system's set has no place for messages, and neither a calendar nor earnings is part of the MVP stories.

## Decision

- The app keeps its four tabs: Schichten, Meine Schichten, Nachrichten, Profil. Everything else about the tab bar follows the design system: floating, four tabs at most, no "more" tab, never hidden on top-level screens.
- A tab label is one short word, because four tabs share the width of a 375pt screen. The tab for the worker's own shifts is labelled "Meine" ("Mine"); the screen title and the name read by screen readers stay "Meine Schichten".
- Tab labels grow with the system text size only up to 1.2 times, as in a native tab bar. The screen title above scales without a limit.

## Consequences

- The app deviates from the design system in the tab set; this ADR is the record of that.
- A calendar view or earnings, if they come, are views inside "Meine Schichten" or the profile, not new tabs.
- A fifth destination means replacing one of the four, and a new ADR.
