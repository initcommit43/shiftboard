-- The waitlist of a full shift (ADR 0029): a place in line is an assignment with status
-- WAITLISTED, so that a worker is on a shift once, whether waiting or claimed. Its claimed_at is
-- the time the worker joined until they move up, which keeps the line in order with the index on
-- (shift_id, claimed_at, id). It holds no slot and books no time: the exclusion constraint
-- assignment_no_overlap only covers PENDING and CONFIRMED.
alter table assignment drop constraint assignment_status_check;
alter table assignment add constraint assignment_status_check
    check (status in ('WAITLISTED', 'PENDING', 'CONFIRMED', 'REJECTED', 'CANCELLED', 'COMPLETED', 'NO_SHOW'));
