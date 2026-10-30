# 0032: Clients get their own role in the dashboard and see who is coming, not what workers earn

Status: accepted (2026-10-27)

## Context

Clients (event companies, warehouses) are the agency's customers. Today they call or email to ask for staff and to find out who is coming. The concept lists a client portal as an optional module for later. Open questions were where it lives, how clients get access, what they may see, and how they ask for staff.

## Decision

- **A `CLIENT` role inside the agency dashboard,** not a separate app. A client user belongs to the agency (tenant) and to one client; every query is scoped to that client. A client can have several users.
- **Behind the feature flag `clientPortal`,** off by default, like the other optional modules.
- **Access through a one-time setup link.** An admin or dispatcher creates a client user and gets a link to pass on; the client sets a password with it. The link works once and expires after 7 days. There is no email sending yet, so this works like the signup link workers get.
- **Clients see their own shifts and the names of confirmed workers.** Times, location, status and fill status ("4 of 5"). Drafts stay hidden. No phone numbers or emails of workers (ADR 0017), no requests or waitlists, and **no hourly rate**: what workers earn isn't the client's business, and the client's own price differs.
- **Clients ask for staff with a request,** not by posting shifts: date, times, location, role, number of people and notes. A dispatcher turns it into a shift from a prefilled form, or declines it with a reason. The client sees the request's status. The agency stays in control of rates and who works.
- **Out of scope:** chat between client and agency, client sign-off of hours, ratings.

## Consequences

- One web app to build and ship; client screens reuse the dashboard's components and tokens.
- Every endpoint a client can reach needs a test that another client's data stays out of reach.
- Worker names reach a third party; the privacy notice has to say so.
- The portal is built in two slices: 8.1 access and seeing shifts, 8.2 staff requests.
