# 0002: Shared-schema multi-tenancy

Status: accepted (2026-10-10)

## Context

Every agency is a tenant, and its workers, clients and shifts must never be visible to another agency. A schema or database per tenant isolates strongly but multiplies migrations and operations, which is out of proportion for the expected number of tenants.

## Decision

- One shared schema. Every table except join tables carries an `agency_id`.
- Filtering is automatic through Hibernate `@TenantId`; the tenant is resolved from the authenticated user for each request.
- Per-agency behaviour (workflow settings, feature flags) is data on the agency, not code.

## Consequences

- One set of migrations and one connection pool for all tenants.
- Isolation depends on the tenant filter, so integration tests must prove that one agency cannot read or change another agency's data.
- Native queries and background jobs bypass the automatic filter unless the tenant is set explicitly; both need care in review.
- Unique constraints have to include `agency_id` where uniqueness is per agency.
