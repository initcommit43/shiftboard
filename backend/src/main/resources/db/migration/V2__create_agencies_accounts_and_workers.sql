-- Agencies are the tenants. Every other table except join tables carries agency_id.
create table agency (
    id          uuid        primary key,
    name        text        not null,
    signup_code text        not null,
    settings    jsonb       not null default '{}',
    features    jsonb       not null default '{}',
    created_at  timestamptz not null default now(),
    constraint agency_signup_code_key unique (signup_code),
    constraint agency_signup_code_length check (char_length(signup_code) between 1 and 64)
);

create table qualification (
    id         uuid        primary key,
    agency_id  uuid        not null references agency (id),
    name       text        not null,
    created_at timestamptz not null default now(),
    constraint qualification_agency_id_name_key unique (agency_id, name)
);

-- Emails are stored in lower case, so the unique constraint is case-insensitive
-- and a login is a plain index lookup.
create table user_account (
    id            uuid        primary key,
    agency_id     uuid        not null references agency (id),
    email         text        not null,
    password_hash text        not null,
    role          text        not null,
    created_at    timestamptz not null default now(),
    constraint user_account_email_key unique (email),
    constraint user_account_email_lower_case check (email = lower(email)),
    constraint user_account_role_check check (role in ('ADMIN', 'DISPATCHER', 'WORKER'))
);

create index user_account_agency_id_idx on user_account (agency_id);

-- Only the SHA-256 hash of a refresh token is stored.
create table refresh_token (
    id              uuid        primary key,
    agency_id       uuid        not null references agency (id),
    user_account_id uuid        not null references user_account (id),
    token_hash      text        not null,
    expires_at      timestamptz not null,
    revoked_at      timestamptz,
    created_at      timestamptz not null default now(),
    constraint refresh_token_token_hash_key unique (token_hash)
);

create index refresh_token_agency_id_idx on refresh_token (agency_id);
create index refresh_token_user_account_id_idx on refresh_token (user_account_id);

create table worker (
    id                   uuid        primary key,
    agency_id            uuid        not null references agency (id),
    user_account_id      uuid        not null references user_account (id),
    first_name           text        not null,
    last_name            text        not null,
    phone                text        not null,
    status               text        not null,
    notifications_paused boolean     not null default false,
    created_at           timestamptz not null default now(),
    updated_at           timestamptz not null default now(),
    constraint worker_user_account_id_key unique (user_account_id),
    constraint worker_status_check check (status in ('PENDING', 'ACTIVE', 'INACTIVE'))
);

-- Serves the worker list: per agency, optionally per status, oldest signup first.
create index worker_agency_id_created_at_idx on worker (agency_id, created_at, id);
create index worker_agency_id_status_created_at_idx on worker (agency_id, status, created_at, id);

create table worker_qualification (
    worker_id        uuid not null references worker (id) on delete cascade,
    qualification_id uuid not null references qualification (id),
    primary key (worker_id, qualification_id)
);

create index worker_qualification_qualification_id_idx on worker_qualification (qualification_id);
