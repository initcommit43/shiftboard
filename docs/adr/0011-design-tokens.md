# 0011: One design-token source with Style Dictionary

Status: accepted (2026-10-10)

## Context

Branding (colors, typography, spacing, app name) should be changeable per agency, and the worker app and the dashboard should look like one product. Maintaining the same values by hand in Dart and in CSS would let them drift.

## Decision

Tokens live in one source in `design-tokens/`. Style Dictionary generates a Flutter theme (Dart) and CSS variables from it. The Tailwind and shadcn/ui setup in the dashboard reads those variables. Neither app hardcodes colors or other brand values.

## Consequences

- A white-label change is made once and applies to both frontends.
- The generated files are build output of the token source; they are regenerated, never edited.
- Screens are designed in Figma per slice against the same token names.
- Style Dictionary is a Node tool, so changing tokens needs Node even when only the Flutter app is being worked on.
