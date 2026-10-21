-- Check-in and check-out in the app, and the hours the agency approves for payroll (ADR 0028).
-- Only times are stored, no location.
alter table assignment
    add column checked_in_at     timestamptz,
    add column checked_out_at    timestamptz,
    add column worked_started_at timestamptz,
    add column worked_ended_at   timestamptz,
    add column break_minutes     integer,
    add column hours_approved_at timestamptz,
    -- The account of the dispatcher or admin who last saved the hours.
    add column hours_approved_by uuid references user_account (id),
    add constraint assignment_checked_out_after_in
        check (checked_out_at is null or (checked_in_at is not null and checked_out_at >= checked_in_at)),
    -- Approved hours are complete: start, end, break and who approved them, or none of it.
    add constraint assignment_hours_complete
        check ((hours_approved_at is null) = (worked_started_at is null)
            and (hours_approved_at is null) = (worked_ended_at is null)
            and (hours_approved_at is null) = (break_minutes is null)
            and (hours_approved_at is null) = (hours_approved_by is null)),
    add constraint assignment_hours_valid
        check (worked_ended_at > worked_started_at
            and break_minutes >= 0
            and break_minutes * interval '1 minute' < worked_ended_at - worked_started_at);

-- Serves the hours of a period: per agency, by the booked start.
create index assignment_agency_id_starts_at_idx on assignment (agency_id, starts_at, id);
