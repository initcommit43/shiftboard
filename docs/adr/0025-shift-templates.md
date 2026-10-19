# 0025: Shift templates are shared per agency and store a local time of day

Status: accepted (2026-10-19)

## Context

Agencies post the same jobs for the same clients and locations several times a week. Slice 4 adds duplicating a shift and saving shifts as named templates, so a dispatcher only has to pick the date.

Three questions shaped the design: who sees a template, how a template stores time when it has no date, and whether one shift can be posted for several dates at once.

## Decision

- **Shared per agency.** Every dispatcher and admin of an agency sees and edits all of its templates, the same way the shared inbox works. Template names are unique within the agency.
- **Contents.** A template holds client, location, title, description, start time, length, "end is estimated", hourly rate, slots and qualifications. It holds no date and no contact person: the dispatcher who creates the shift becomes its contact (ADR 0022).
- **Time as a local time of day plus a length.** A template stores the start as a local time (e.g. 07:00) and the length in minutes, not as `timestamptz`. When a shift is created from it, the start is resolved on the chosen date in the agency's time zone, so 07:00 stays 07:00 across daylight saving changes, and an overnight shift keeps its length.
- **One time zone setting.** The agency's time zone moves out of the classes that hard-code `Europe/Vienna` into one setting, `Europe/Vienna` by default. Templates, system messages and push texts all read it.
- **Templates live in the `shift` module.** Creating a shift from a template goes through the same validation as any other new shift. A template whose client, location or qualification no longer exists can still be used; the missing value is left empty in the form.
- **Duplicating needs no new endpoint.** The dashboard fills the new-shift form from an existing shift and leaves the date empty.
- **Out of scope:** recurring shifts and posting one shift for several dates at once. Both can build on templates later.

## Consequences

- Dispatchers on duty can use each other's templates; nobody owns one, so anyone can change or delete it.
- Deleting or changing a template does not touch shifts created from it; a shift keeps no link to its template.
- Templates are the first place that stores a time without a date. Shifts themselves stay `timestamptz`.
- The time zone is still one value for the whole deployment. A per-agency time zone can replace it once an agency outside that zone needs one.
