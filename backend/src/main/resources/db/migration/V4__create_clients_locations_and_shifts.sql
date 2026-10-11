-- A client is a customer of the agency; its locations are the sites shifts take place at.
create table client (
    id            uuid        primary key,
    agency_id     uuid        not null references agency (id),
    name          text        not null,
    contact_email text,
    created_at    timestamptz not null default now(),
    constraint client_agency_id_name_key unique (agency_id, name)
);

create table location (
    id         uuid        primary key,
    agency_id  uuid        not null references agency (id),
    client_id  uuid        not null references client (id),
    name       text        not null,
    address    text        not null,
    latitude   numeric(9, 6),
    longitude  numeric(9, 6),
    created_at timestamptz not null default now(),
    constraint location_client_id_name_key unique (client_id, name)
);

create index location_agency_id_idx on location (agency_id);

-- One role per shift. taken_slots counts the claims that hold a slot; version is the
-- optimistic lock that keeps two concurrent claims from taking the last one.
create table shift (
    id              uuid          primary key,
    agency_id       uuid          not null references agency (id),
    client_id       uuid          not null references client (id),
    location_id     uuid          not null references location (id),
    contact_user_id uuid          not null references user_account (id),
    title           text          not null,
    description     text,
    starts_at       timestamptz   not null,
    ends_at         timestamptz   not null,
    end_is_estimate boolean       not null default false,
    hourly_rate     numeric(8, 2) not null,
    slots           integer       not null,
    taken_slots     integer       not null default 0,
    status          text          not null,
    version         bigint        not null default 0,
    created_at      timestamptz   not null default now(),
    updated_at      timestamptz   not null default now(),
    constraint shift_status_check check (status in ('DRAFT', 'PUBLISHED', 'COMPLETED', 'CANCELLED')),
    constraint shift_ends_after_start check (ends_at > starts_at),
    constraint shift_hourly_rate_positive check (hourly_rate > 0),
    constraint shift_slots_positive check (slots >= 1),
    constraint shift_taken_slots_within_slots check (taken_slots between 0 and slots)
);

-- Serves the list of upcoming shifts: per agency, not ended yet, earliest start first.
create index shift_agency_id_ends_at_idx on shift (agency_id, ends_at);
create index shift_agency_id_starts_at_idx on shift (agency_id, starts_at, id);

create table shift_qualification (
    shift_id         uuid not null references shift (id) on delete cascade,
    qualification_id uuid not null references qualification (id),
    primary key (shift_id, qualification_id)
);

create index shift_qualification_qualification_id_idx on shift_qualification (qualification_id);
