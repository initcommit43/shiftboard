# 0018: Date of birth in the worker profile

Status: accepted (2026-10-10)

## Context

[ADR 0017](0017-data-protection.md) limits the worker profile to name, email, phone and qualifications. An agency cannot employ someone without knowing the date of birth, so it would have to ask for it outside the platform after every signup.

## Decision

- The worker profile also holds the date of birth. This extends the list in ADR 0017; everything else in it stays as decided.
- It is collected at signup and required. The API accepts a real calendar date in the past that is at most 120 years ago.
- No minimum age is enforced yet.
- The agency sees it with the worker; the worker's own profile in the API does not return it.

## Consequences

- The date of birth is personal data: the anonymization on account deletion has to clear it, and it must not appear in logs or event payloads.
- Workers that signed up before this change have no date of birth. Only local demo data exists, so those databases are reset instead of migrated.
- A minimum age, once decided, becomes a validation rule and a new ADR.
