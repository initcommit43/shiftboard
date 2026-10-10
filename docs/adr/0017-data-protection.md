# 0017: Minimal personal data and anonymization on deletion

Status: accepted (2026-10-10)

## Context

The platform stores personal data of workers and falls under the GDPR. At the same time the agency needs an accurate history of who filled which shift, at least in aggregate.

## Decision

- The worker profile holds the basics only: name, email, phone and qualifications.
- Deleting an account anonymizes the worker instead of deleting rows. Personal fields are cleared and the login is removed, while past assignments stay linked to the anonymized record.
- The app shows a privacy notice.
- Seed data, demo data, tests and screenshots use fictional agencies, clients and people only.

## Consequences

- Shift history and slot counts stay consistent after an account is deleted.
- Every new personal field has to be added to the anonymization step; a test checks that nothing personal is left behind.
- Personal data must not be copied into places the anonymization does not reach, such as logs or event payloads.
