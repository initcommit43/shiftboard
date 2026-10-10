-- Event publication registry of Spring Modulith (spring-modulith-events-jpa 2.1).
create table event_publication (
    id                     uuid        primary key,
    listener_id            text        not null,
    event_type             text        not null,
    serialized_event       text        not null,
    publication_date       timestamptz not null,
    completion_date        timestamptz,
    status                 text,
    completion_attempts    integer     not null default 0,
    last_resubmission_date timestamptz
);

create index event_publication_serialized_event_hash_idx on event_publication using hash (serialized_event);
create index event_publication_by_completion_date_idx on event_publication (completion_date);
