# 0023: Background jobs with @Scheduled and ShedLock

Status: accepted (2026-10-17)

## Context

Some changes happen because time passes, not because someone acts: a shift that has ended has to become `COMPLETED` together with its confirmed assignments (S2-6), and later slices add reminders and deadlines. The backend may run on more than one instance, and a job must not run twice at once there.

The options were Spring's `@Scheduled` with ShedLock, or a job library such as JobRunr or db-scheduler that stores single jobs ("complete shift X at its end") and retries them.

## Decision

- Background jobs are plain `@Scheduled` methods in the module they belong to, such as `ShiftCompletionJob` in `shift`.
- ShedLock with its JDBC provider keeps a job from running on two instances at the same time. The lock table `shedlock` is created by a Flyway migration, and the lock uses the database clock.
- A job is a query for what is due, so it is safe to run any number of times: it looks at the current state, not at a stored plan. Each item is changed in a transaction of its own, so one failure does not hold up the rest.
- Jobs run per agency, with the tenant bound for each one.
- `shiftboard.jobs.enabled=false` switches the scheduler off; the tests do that and start jobs themselves.

## Consequences

- No extra infrastructure or dashboard; the jobs are ordinary code with ordinary tests.
- A job only reacts within its interval (one minute for shift completion), which is enough for state changes that nobody waits for to the second.
- There is no per-job history or retry store. A failed item is picked up again by the next run because it is still due.
- Should exact timing or a job history be needed later, a job library can replace a job without changing the domain code it calls.
