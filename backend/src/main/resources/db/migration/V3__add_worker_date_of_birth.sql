-- Asked for at signup. Not null without a default: workers exist in local demo data only,
-- so a database that already has workers is reset instead of backfilled.
alter table worker add column date_of_birth date not null;
