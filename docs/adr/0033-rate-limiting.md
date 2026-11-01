# 0033: Every API request is rate limited, in memory per instance

Status: accepted (2026-11-01)

## Context

ADR 0007 rate limits login attempts per client address and email. Nothing else is limited: signup and client setup codes can be guessed without limit, one address can try passwords across many emails, and a single user or script can send any number of requests to the API. Open questions were which endpoints to limit, by what key, and where the counters live.

## Decision

- **The endpoints that need no login are limited per client address.** Logins across all emails (20 per 15 minutes), signup and client setup links together (30 per 15 minutes), token refresh and logout (60 per 15 minutes).
- **The failed-login limit of ADR 0007 stays.** 5 per client address and email in 15 minutes, cleared by a successful login.
- **The rest of the API is limited per user,** generously: 300 requests per minute, from any address. Requests without a valid token count against their address. `/ping` and the health check are not limited.
- **Token buckets with Bucket4j.** A bucket allows its limit at once and refills evenly over the period, so there is no burst at the edge of a fixed window. The failed-login limit uses the same buckets, so it now frees one attempt every 3 minutes instead of all five after 15 minutes.
- **In memory, per instance.** Buckets live in a size-bounded Caffeine cache and are forgotten on restart. There is one instance and no deployment yet; a shared store such as PostgreSQL can replace the cache when there are several.
- **A limited request gets `429`** as problem details with a `Retry-After` header in seconds. The code is `too_many_attempts` for logins, as before, and `too_many_requests` everywhere else.
- **All limits are configuration** under `shiftboard.security.rate-limits`.

## Consequences

- Guessing codes and passwords is slow even across many emails, and a runaway client cannot flood the API.
- With several instances, each one counts on its own, so the effective limit grows with the number of instances.
- The client address is the address the server sees. Behind a reverse proxy, every request comes from the proxy, so the proxy's forwarded headers have to be trusted (`server.forward-headers-strategy`) before deploying behind one.
- People behind one shared address, such as an agency office, share the limits per address. The numbers are set high enough for a normal office.
- Tests that share one application context run with the limits per address out of reach; the 429 response is tested in a context of its own.
