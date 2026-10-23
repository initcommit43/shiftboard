# 0029: Workers move up from the waitlist automatically until the cancellation deadline

Status: accepted (2026-10-23)

## Context

Slice 6 adds a waitlist to full shifts. Today a full shift is a dead end: when someone drops out, the spot goes to whoever happens to look first, which is the SMS race the product is meant to replace. Three questions were open: what happens to the waitlist when a spot frees up, how much the agency steers it, and how it is switched on.

## Decision

- **First come, first served.** A worker joins the waitlist of a published, full shift that hasn't started, and sees their place in line. Joining is blocked when they already claimed the shift or it overlaps a shift they hold a spot or request for. A place in line holds no spot. Leaving is possible until the start and leaves no trace, so a worker can join again at the back.
- **Moving up is automatic until the cancellation deadline.** When a spot frees up before the deadline (a worker drops out, the agency removes someone or rejects a request, or adds spots), the first in line becomes a request, or is confirmed right away when the agency confirms automatically. That happens in the same transaction as the freeing, so a spot can't be given out twice. The worker gets a system message and a push. Whoever is first in line but is now booked for an overlapping shift is skipped, taken off the list and told.
- **After the deadline nobody is moved in without a say.** A worker who moved up after the deadline could no longer drop out in the app. Instead, everyone waiting gets a push that a spot is free, and the first to claim it gets it.
- **The agency sees the line and can take someone off it,** but can't reorder it or promote by hand. Requests that came from the waitlist are approved like any other.
- **When the shift is cancelled,** the waitlist is cleared and the workers get the usual cancellation message and push. **When it ends,** the waitlist is cleared silently.
- **It is an agency setting,** `waitlist` next to auto-confirm, off by default, because it changes how claiming works rather than adding a module. Switching it off stops new entries; workers already waiting stay in line.
- **Stored as an assignment with status `WAITLISTED`,** in the `assignment` module, so the unique constraint on (shift, worker) and the overlap rules apply unchanged. Moving up turns the same row into the claim.
- **The API doesn't expose `WAITLISTED` as an assignment status.** The generated Dart client fails on enum values it doesn't know, and installed app versions lag behind. The worker's place comes as its own `waitlist` field on the shift, waitlisted shifts appear in "my shifts" only with `includeWaitlist`, and the agency gets the line from its own endpoint.

## Consequences

- Freed spots fill themselves without a dispatcher, before the deadline at least; after it the agency may still need to chase someone.
- A worker who moved up and no longer wants the shift drops out like after any claim, which hands the spot to the next in line.
- Agencies that want to hand-pick from the waitlist would need a new decision.
- New enum values need the same care in later slices; switching the Dart generator to tolerate unknown values is a candidate for later.
