-- The devices a worker gets push notifications on: one Firebase Cloud Messaging token each. A
-- token belongs to one worker at a time; logging in with another account on the device moves it.
create table push_token (
    id         uuid        primary key,
    agency_id  uuid        not null references agency (id),
    worker_id  uuid        not null references worker (id),
    token      text        not null,
    platform   text        not null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    constraint push_token_token_key unique (token),
    constraint push_token_platform_check check (platform in ('ANDROID', 'IOS'))
);

create index push_token_worker_id_idx on push_token (worker_id);
