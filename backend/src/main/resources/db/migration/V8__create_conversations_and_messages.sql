-- One conversation per worker and agency, created with its first message.
create table conversation (
    id              uuid        primary key,
    agency_id       uuid        not null references agency (id),
    worker_id       uuid        not null references worker (id),
    last_message_at timestamptz not null,
    created_at      timestamptz not null default now(),
    constraint conversation_worker_id_key unique (worker_id)
);

-- Serves the shared inbox: per agency, the most recent message first.
create index conversation_agency_id_last_message_at_idx on conversation (agency_id, last_message_at desc, id);

-- A message from the worker (from_worker), from a dispatcher (sender_user_id) or from the platform
-- (type SYSTEM, no sender). read_at is set when the other side has read it.
create table message (
    id              uuid        primary key,
    agency_id       uuid        not null references agency (id),
    conversation_id uuid        not null references conversation (id),
    shift_id        uuid        references shift (id),
    sender_user_id  uuid        references user_account (id),
    from_worker     boolean     not null,
    type            text        not null,
    event           text,
    body            text        not null,
    -- Keeps a system message from being written twice when its event is delivered again.
    dedup_key       text,
    created_at      timestamptz not null,
    read_at         timestamptz,
    constraint message_type_check check (type in ('TEXT', 'SYSTEM', 'BROADCAST')),
    constraint message_event_check
        check (event in ('CLAIM_CONFIRMED', 'CLAIM_REJECTED', 'CLAIM_CANCELLED_BY_WORKER', 'REMOVED_BY_AGENCY',
                         'SHIFT_CANCELLED')),
    constraint message_system_has_event check ((type = 'SYSTEM') = (event is not null)),
    constraint message_dedup_key_key unique (dedup_key)
);

-- Serves a conversation's messages, newest first.
create index message_conversation_id_created_at_idx on message (conversation_id, created_at desc, id desc);
-- Serves the unread counts.
create index message_unread_idx on message (conversation_id, from_worker) where read_at is null;
create index message_agency_id_idx on message (agency_id);
