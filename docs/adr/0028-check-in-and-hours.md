# 0028: Check-in in the app, hours approved by the agency, CSV built in the dashboard

Status: accepted (2026-10-21)

## Context

Slice 5 records the hours a worker actually worked and hands them to payroll. Agencies pay by the hour, so the times have to be right, but today they live on paper or in messages. Four questions were open: how workers check in, which hours count for payroll, how breaks are handled and what the export looks like.

## Decision

- **Check-in is a button in the app, without location.** A worker with a confirmed spot checks in from 30 minutes before the booked start until the booked end, and checks out once after checking in. Only the two times are stored: no GPS, no photo (minimal data). The worker can't correct them; the agency does.
- **Check-out stays possible until the hours are approved,** also after the planned end and after the shift completed, because "end is estimated" shifts run over.
- **Check-in is an optional feature** (`checkIn` in the agency's features), off by default like the contact button. Without it, hours are approved from the planned times.
- **The agency approves the hours.** For every worker who held a confirmed spot on a started shift, a dispatcher saves start, end and break. The form suggests the check-in and check-out times, or the planned times where one is missing. Saving approves; the hours can be saved again later, and the latest save counts. Who approved and when is stored.
- **Breaks are set by the dispatcher,** prefilled with 30 minutes when the time worked is over six hours (the Austrian working-time rule), otherwise 0.
- **No rounding.** Hours are end − start − break in whole minutes. Gross is minutes × the shift's hourly rate / 60, rounded half up to the cent. A shift can't be edited after it starts (ADR 0026), so its rate is fixed by then.
- **Attendance and no-shows exclude each other.** A worker who checked in or has approved hours can't be marked as a no-show; no-shows and cancelled claims get no hours.
- **It lives in the `assignment` module.** Check-in and hours are steps in the life of an assignment, and the no-show rule needs both. The separate `timetracking` and `export` modules the concept sketched are not needed yet.
- **The CSV is built in the dashboard.** The API lists hours for a period (`GET /hours`); the dashboard writes the file, with dates and times in local time like everywhere else in the dashboard, so the backend still needs no time zone setting (ADR 0025). The file is generic: one row per worker and shift with last name, first name, date, client, location, shift, start, end, break, hours, hourly rate and gross; semicolons, decimal comma, UTF-8 with BOM, so it opens correctly in Excel for German and Austrian users. Cells that start like a formula are escaped. Only approved hours are in the file.

## Consequences

- The agency stays in control of what is paid; a forgotten check-out costs a dispatcher one edit, not a wrong payslip.
- Without location data, check-in proves little about where the worker was. Agencies that need that would need a new decision (geofence or QR code).
- An export for a specific payroll program (BMD, DPW, ...) is a later addition on top of the same list.
- Like the shift form, the export relies on dispatchers working in the agency's time zone.
