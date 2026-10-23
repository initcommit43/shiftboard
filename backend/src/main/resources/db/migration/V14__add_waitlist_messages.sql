-- System messages about the waitlist (ADR 0029). Their body is all clients show of them.
alter table message drop constraint message_event_check;
alter table message add constraint message_event_check
    check (event in ('CLAIM_CONFIRMED', 'CLAIM_REJECTED', 'CLAIM_CANCELLED_BY_WORKER', 'REMOVED_BY_AGENCY',
                     'SHIFT_CANCELLED', 'SHIFT_CHANGED', 'WAITLIST_MOVED_UP', 'WAITLIST_MOVED_UP_CONFIRMED',
                     'WAITLIST_REMOVED_BY_AGENCY', 'WAITLIST_SKIPPED'));
