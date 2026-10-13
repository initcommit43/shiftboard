-- Dispatchers and admins are the contact persons of shifts, so their accounts carry a name and,
-- if they want to be called, a phone number. Workers keep both in their worker profile.
-- No backfill: staff accounts exist in local demo data only, so a database that already has
-- them is reset instead.
alter table user_account
    add column first_name text,
    add column last_name  text,
    add column phone      text,
    add constraint user_account_staff_has_name
        check (role = 'WORKER' or (first_name is not null and last_name is not null));
