-- A system message about a change of the shift (ADR 0026). Its body says what changed.
alter table message drop constraint message_event_check;
alter table message add constraint message_event_check
    check (event in ('CLAIM_CONFIRMED', 'CLAIM_REJECTED', 'CLAIM_CANCELLED_BY_WORKER', 'REMOVED_BY_AGENCY',
                     'SHIFT_CANCELLED', 'SHIFT_CHANGED'));
