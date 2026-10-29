-- Users at one of the agency's clients log in to the client portal (ADR 0032).
alter table user_account
    drop constraint user_account_role_check,
    add constraint user_account_role_check check (role in ('ADMIN', 'DISPATCHER', 'WORKER', 'CLIENT')),
    add column client_id uuid references client (id),
    add column status text not null default 'ACTIVE',
    -- Client users have no password until they set one with their setup link.
    alter column password_hash drop not null,
    add constraint user_account_status_check check (status in ('INVITED', 'ACTIVE', 'DEACTIVATED')),
    add constraint user_account_client_role check ((role = 'CLIENT') = (client_id is not null)),
    add constraint user_account_password_set check (status <> 'ACTIVE' or password_hash is not null);

create index user_account_client_id_idx on user_account (client_id) where client_id is not null;

-- Only the SHA-256 hash of a setup code is stored. A code works once, until it expires.
create table client_setup_code (
    id              uuid        primary key,
    agency_id       uuid        not null references agency (id),
    user_account_id uuid        not null references user_account (id),
    code_hash       text        not null,
    expires_at      timestamptz not null,
    used_at         timestamptz,
    created_at      timestamptz not null default now(),
    constraint client_setup_code_code_hash_key unique (code_hash)
);

create index client_setup_code_user_account_id_idx on client_setup_code (user_account_id);
