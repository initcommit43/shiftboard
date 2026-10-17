# Architecture Decision Records

One short record per real decision. Format: `NNNN-title.md` with the sections Context, Decision and Consequences. A decision that changes gets a new ADR that supersedes the old one; accepted ADRs are not rewritten.

| # | Decision |
| --- | --- |
| [0001](0001-modular-monolith.md) | Spring Boot modular monolith on PostgreSQL |
| [0002](0002-shared-schema-multi-tenancy.md) | Shared-schema multi-tenancy |
| [0003](0003-monorepo.md) | One monorepo, independent releases per app |
| [0004](0004-frontends.md) | Flutter worker app and React agency dashboard |
| [0005](0005-contract-first-api.md) | Contract-first API and API conventions |
| [0006](0006-api-client-generation.md) | API clients generated with openapi-generator |
| [0007](0007-authentication-and-security.md) | Authentication and security basics |
| [0008](0008-overbooking-protection.md) | Overbooking protection with optimistic locking |
| [0009](0009-database-migrations.md) | Database migrations with Flyway |
| [0010](0010-reliable-domain-events.md) | Reliable domain events with the Spring Modulith event publication registry |
| [0011](0011-design-tokens.md) | One design-token source with Style Dictionary |
| [0012](0012-flutter-routing.md) | Flutter routing with go_router |
| [0013](0013-app-languages.md) | German first, i18n from the start |
| [0014](0014-testing-strategy.md) | Testing strategy |
| [0015](0015-versioning-and-changelog.md) | Versioning and changelog |
| [0016](0016-push-notifications.md) | Push notifications via Firebase Cloud Messaging |
| [0017](0017-data-protection.md) | Minimal personal data and anonymization on deletion |
| [0018](0018-date-of-birth.md) | Date of birth in the worker profile |
| [0019](0019-source-available-all-rights-reserved.md) | Public repository, all rights reserved |
| [0020](0020-worker-app-tabs.md) | Tabs of the worker app |
| [0021](0021-qualifications-information-only.md) | Qualifications are information only in the MVP |
| [0022](0022-staff-names-and-shift-contact.md) | Names on staff accounts and the contact person of a shift |
| [0023](0023-background-jobs.md) | Background jobs with @Scheduled and ShedLock |
