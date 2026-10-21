import type { FieldError, HoursRequest, ShiftAssignment } from '@/api/generated'
import { dateOf, localTimes, timeOfDay } from '@/features/shifts/shift-draft'

/** The hours form as the dispatcher types it: every input as text. */
export interface HoursDraft {
  /** `yyyy-mm-dd`, the day work started on. */
  date: string
  /** `hh:mm` */
  startTime: string
  /** `hh:mm`; a time before the start means work ended on the next day. */
  endTime: string
  /** Whole minutes. */
  breakMinutes: string
}

/** In the order of the form, which is the order errors are focused in. */
export const HOURS_FIELDS = ['date', 'startTime', 'endTime', 'breakMinutes'] as const

export type HoursField = (typeof HOURS_FIELDS)[number]

/** The key of the message below a field, `hours.dialog.errors.<key>`. */
export type HoursError =
  | 'required'
  | 'invalid_format'
  | 'before_start'
  | 'hours_too_long'
  | 'break_too_long'
  | 'break_out_of_range'
  | 'unknown'

export type HoursErrors = Partial<Record<HoursField, HoursError>>

const MINUTE = 60 * 1000
const MAX_MINUTES = 24 * 60
const MAX_BREAK = 1440

/** Working more than six hours means a break of 30 minutes (ADR 0028). */
const BREAK_AFTER_MINUTES = 6 * 60
const DEFAULT_BREAK = 30

/** The break suggested for a stretch of work, in minutes. */
export function defaultBreak(minutes: number) {
  return minutes > BREAK_AFTER_MINUTES ? DEFAULT_BREAK : 0
}

/**
 * What the form starts with: the approved hours once there are some; otherwise check-in
 * and check-out, or the planned times where one is missing, with the suggested break.
 */
export function hoursDraftFrom(
  shift: { startsAt: Date; endsAt: Date },
  assignment: ShiftAssignment,
): HoursDraft {
  const { hours } = assignment
  if (hours) {
    return draftOf(hours.startedAt, hours.endedAt, hours.breakMinutes)
  }
  const startedAt = assignment.checkedInAt ?? shift.startsAt
  const endedAt = assignment.checkedOutAt ?? shift.endsAt
  return draftOf(startedAt, endedAt, defaultBreak((endedAt.getTime() - startedAt.getTime()) / MINUTE))
}

function draftOf(startedAt: Date, endedAt: Date, breakMinutes: number): HoursDraft {
  return {
    date: dateOf(startedAt),
    startTime: timeOfDay(startedAt),
    endTime: timeOfDay(endedAt),
    breakMinutes: String(breakMinutes),
  }
}

/** Start and end as points in time, in the time zone of the browser. */
export function hoursTimes({ date, startTime, endTime }: HoursDraft) {
  return localTimes(date, startTime, endTime)
}

function parseBreak(text: string) {
  return /^\d{1,4}$/.test(text.trim()) ? Number(text.trim()) : null
}

/** End minus start minus break, or null while the draft is incomplete or wrong. */
export function workedMinutes(draft: HoursDraft) {
  const times = hoursTimes(draft)
  const breakMinutes = parseBreak(draft.breakMinutes)
  if (!times || breakMinutes === null) {
    return null
  }
  const worked = (times.endsAt.getTime() - times.startsAt.getTime()) / MINUTE - breakMinutes
  return worked > 0 ? worked : null
}

/** Worked minutes times the hourly rate, in cents, rounded half up like the backend. */
export function grossCents(minutes: number, hourlyRateCents: number) {
  return Math.round((minutes * hourlyRateCents) / 60)
}

export function validateHours(draft: HoursDraft): HoursErrors {
  const errors: HoursErrors = {}

  for (const field of HOURS_FIELDS) {
    if (!draft[field].trim()) {
      errors[field] = 'required'
    }
  }

  const breakMinutes = parseBreak(draft.breakMinutes)
  if (!errors.breakMinutes) {
    if (breakMinutes === null) {
      errors.breakMinutes = 'invalid_format'
    } else if (breakMinutes > MAX_BREAK) {
      errors.breakMinutes = 'break_out_of_range'
    }
  }

  const times = hoursTimes(draft)
  if (times) {
    const minutes = (times.endsAt.getTime() - times.startsAt.getTime()) / MINUTE
    if (minutes <= 0) {
      errors.endTime = 'before_start'
    } else if (minutes > MAX_MINUTES) {
      errors.endTime = 'hours_too_long'
    } else if (breakMinutes !== null && !errors.breakMinutes && breakMinutes >= minutes) {
      errors.breakMinutes = 'break_too_long'
    }
  }

  return errors
}

/** The request for a draft that passed `validateHours`. */
export function toHoursRequest(draft: HoursDraft): HoursRequest {
  const times = hoursTimes(draft)
  const breakMinutes = parseBreak(draft.breakMinutes)
  if (!times || breakMinutes === null) {
    throw new Error('The draft has not been validated')
  }
  return { startedAt: times.startsAt, endedAt: times.endsAt, breakMinutes }
}

const REQUEST_FIELDS: Record<string, HoursField> = {
  startedAt: 'startTime',
  endedAt: 'endTime',
  breakMinutes: 'breakMinutes',
}

/** The field errors of a `validation_failed` response, placed on the fields of the form. */
export function hoursServerErrors(fieldErrors: FieldError[]): HoursErrors {
  const errors: HoursErrors = {}
  for (const { field, code } of fieldErrors) {
    const draftField = REQUEST_FIELDS[field]
    if (!draftField) {
      continue
    }
    const onBreak = draftField === 'breakMinutes'
    if (code === 'required' || code === 'before_start') {
      errors[draftField] = code
    } else if (code === 'too_long') {
      errors[draftField] = onBreak ? 'break_too_long' : 'hours_too_long'
    } else if (code === 'out_of_range' && onBreak) {
      errors[draftField] = 'break_out_of_range'
    } else {
      errors[draftField] = 'unknown'
    }
  }
  return errors
}
