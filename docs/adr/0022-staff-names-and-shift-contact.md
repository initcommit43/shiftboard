# 0022: Names on staff accounts and the contact person of a shift

Status: accepted (2026-10-13)

## Context

The worker app shows a contact person on every shift, and a shift already stores the dispatcher who created it as its contact. A user account only holds what the login needs: email, password and role. Workers have a profile with their name and phone; dispatchers and admins have none, so there is nothing to show but an email address.

The options were a name and phone on staff accounts, one contact per agency for all shifts, or leaving the contact person out until the contact button of slice 3.

## Decision

- Dispatcher and admin accounts get a first name, a last name and an optional phone number.
- The contact person of a shift is the dispatcher who created it. Workers see the name and, if one is on record, the phone number. The email address of the account is not shown.
- Workers stay as they are: their name and phone live in the worker profile.

## Consequences

- A migration adds the three fields to the user account. The demo dispatchers get fictional names and phone numbers; no other staff accounts exist yet.
- Staff accounts are still created by seed data only. Whatever creates them later has to ask for the name.
- The name and phone of a dispatcher are personal data shown to every active worker of the agency. They belong in the privacy notice (ADR 0017).
- The contact button of slice 3 (call or WhatsApp) can use the phone number without another change to the model.
- A shift whose dispatcher leaves keeps pointing at that account. Reassigning the contact comes with editing shifts.
