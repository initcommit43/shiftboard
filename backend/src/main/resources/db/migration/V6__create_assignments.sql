-- Lets the exclusion constraint below compare worker ids.
create extension if not exists btree_gist;

-- A claim of a worker on a shift. starts_at and ends_at are the time the worker is booked for,
-- copied from the shift, so that overlaps are checked and "my shifts" is sorted without the shift.
create table assignment (
    id         uuid        primary key,
    agency_id  uuid        not null references agency (id),
    shift_id   uuid        not null references shift (id),
    worker_id  uuid        not null references worker (id),
    status     text        not null,
    starts_at  timestamptz not null,
    ends_at    timestamptz not null,
    claimed_at timestamptz not null,
    decided_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    -- A worker claims a shift once, whatever becomes of the claim.
    constraint assignment_shift_id_worker_id_key unique (shift_id, worker_id),
    constraint assignment_status_check
        check (status in ('PENDING', 'CONFIRMED', 'REJECTED', 'CANCELLED', 'COMPLETED', 'NO_SHOW')),
    constraint assignment_ends_after_start check (ends_at > starts_at),
    -- A worker cannot be booked for two shifts at the same time, also not by two concurrent claims.
    constraint assignment_no_overlap
        exclude using gist (worker_id with =, tstzrange(starts_at, ends_at) with &&)
        where (status in ('PENDING', 'CONFIRMED'))
);

create index assignment_agency_id_idx on assignment (agency_id);
-- Serves "my shifts": per worker, earliest start first.
create index assignment_worker_id_starts_at_idx on assignment (worker_id, starts_at, id);

-- Serves the list of shifts workers can claim: published, not started yet, earliest start first.
create index shift_agency_id_status_starts_at_idx on shift (agency_id, status, starts_at, id);
