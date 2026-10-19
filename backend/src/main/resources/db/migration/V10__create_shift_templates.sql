-- A shift without a date that dispatchers start new shifts from (ADR 0025). Shared by the whole
-- agency; the start is a local time of day, which the dashboard places on the chosen date.
create table shift_template (
    id               uuid          primary key,
    agency_id        uuid          not null references agency (id),
    name             text          not null,
    client_id        uuid          not null references client (id),
    location_id      uuid          not null references location (id),
    title            text          not null,
    description      text,
    start_time       time          not null,
    duration_minutes integer       not null,
    end_is_estimate  boolean       not null default false,
    hourly_rate      numeric(8, 2) not null,
    slots            integer       not null,
    created_at       timestamptz   not null default now(),
    updated_at       timestamptz   not null default now(),
    constraint shift_template_duration_check check (duration_minutes between 1 and 1439),
    constraint shift_template_hourly_rate_positive check (hourly_rate > 0),
    constraint shift_template_slots_check check (slots between 1 and 500)
);

-- Names are unique per agency, ignoring case.
create unique index shift_template_agency_id_name_key on shift_template (agency_id, lower(name));

create table shift_template_qualification (
    shift_template_id uuid not null references shift_template (id) on delete cascade,
    qualification_id  uuid not null references qualification (id),
    primary key (shift_template_id, qualification_id)
);
