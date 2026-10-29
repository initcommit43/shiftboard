-- A client's request for staff, sent from the portal (ADR 0032). A dispatcher turns it into a
-- shift (ACCEPTED, with shift_id) or declines it with a reason; the client can withdraw it while
-- it is OPEN. It holds nothing about pay.
create table staff_request (
    id              uuid        primary key,
    agency_id       uuid        not null references agency (id),
    client_id       uuid        not null references client (id),
    location_id     uuid        not null references location (id),
    requested_by    uuid        not null references user_account (id),
    role            text        not null,
    starts_at       timestamptz not null,
    ends_at         timestamptz not null,
    end_is_estimate boolean     not null default false,
    worker_count    integer     not null,
    notes           text,
    status          text        not null default 'OPEN',
    decline_reason  text,
    shift_id        uuid        references shift (id),
    decided_at      timestamptz,
    created_at      timestamptz not null default now(),
    updated_at      timestamptz not null default now(),
    constraint staff_request_status_check check (status in ('OPEN', 'ACCEPTED', 'DECLINED', 'WITHDRAWN')),
    constraint staff_request_times_check check (ends_at > starts_at),
    constraint staff_request_worker_count_check check (worker_count between 1 and 500),
    constraint staff_request_accepted_has_shift check ((status = 'ACCEPTED') = (shift_id is not null)),
    constraint staff_request_declined_has_reason check ((status = 'DECLINED') = (decline_reason is not null)),
    constraint staff_request_decided check ((status = 'OPEN') = (decided_at is null)),
    -- One request per shift.
    constraint staff_request_shift_id_key unique (shift_id)
);

-- The client's list, newest first.
create index staff_request_client_id_idx on staff_request (client_id, created_at desc);

-- The dispatchers' list of open requests, earliest start first.
create index staff_request_open_idx on staff_request (agency_id, starts_at) where status = 'OPEN';
