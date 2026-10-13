# 0021: Qualifications are information only in the MVP

Status: accepted (2026-10-13)

## Context

The concept planned to match shifts to workers by qualification: a worker only sees and claims shifts whose required qualifications they hold. That needs qualifications on every worker. The signup stopped asking for them on 2026-10-10: most of the jobs such an agency sends out have no hard requirements, and qualifications a worker ticks for themselves say little. Nothing else assigns them yet. Matching on empty worker qualifications would hide every shift that requires one.

The options were an editor in the dashboard, where dispatchers assign qualifications when approving a signup, self-declaration in the worker's profile, or no matching for now.

## Decision

- In the MVP, qualifications are not used for matching. Workers see every published shift of their agency, and a claim is not checked against qualifications.
- A shift keeps its required qualifications. The worker app shows them on the shift as a requirement to read, next to what to bring and the meeting point.
- The agency decides who is suited when it reviews a claim. Approval by the agency is the default claim flow, so an unsuitable claim is rejected there.
- Workers have no qualifications assigned in the MVP. The field stays in the API and the schema, empty.

## Consequences

- No story for assigning qualifications is needed before the worker side of slice 1.
- With auto-confirm switched on, nothing stops an unqualified worker from getting a shift. An agency that requires qualifications should keep approval on until matching exists.
- Push notifications for new shifts go to all active workers of the agency, not to the matching ones.
- Matching can be added later without a breaking change: assign qualifications to workers, then filter the list and check the claim. That gets its own ADR.
