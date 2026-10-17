-- Who cancelled an assignment, and why the agency removed a worker (kept for the agency only).
alter table assignment
    add column cancelled_by text,
    add column reason       text,
    add constraint assignment_cancelled_by_check check (cancelled_by in ('WORKER', 'AGENCY'));

-- Serves the claims of a shift, oldest first.
create index assignment_shift_id_claimed_at_idx on assignment (shift_id, claimed_at, id);

-- Serves the job that completes published shifts once they have ended, and the list of past shifts.
create index shift_agency_id_status_ends_at_idx on shift (agency_id, status, ends_at);

-- ShedLock: lets only one instance run a scheduled job at a time (ADR 0023).
create table shedlock (
    name       varchar(64)  primary key,
    lock_until timestamptz  not null,
    locked_at  timestamptz  not null,
    locked_by  varchar(255) not null
);
