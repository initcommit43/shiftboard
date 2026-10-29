import type { FieldError, Location, StaffRequestRequest } from '@/api/generated'
import { dateOf, localTimes } from '@/features/shifts/shift-draft'

/** The request form as the client types it: every input as text. */
export interface RequestDraft {
  locationId: string
  role: string
  /** `yyyy-mm-dd` */
  date: string
  /** `hh:mm` */
  startTime: string
  /** `hh:mm`; a time before the start means the end is on the next day. */
  endTime: string
  endIsEstimate: boolean
  workerCount: string
  notes: string
}

/** In the order of the form, which is the order errors are focused in. */
export const REQUEST_FIELDS = [
  'locationId',
  'role',
  'date',
  'startTime',
  'endTime',
  'workerCount',
  'notes',
] as const

export type RequestField = (typeof REQUEST_FIELDS)[number]

/** The key of the message below a field, `portal.requests.form.errors.<key>`. */
export type RequestError =
  | 'required'
  | 'invalid_format'
  | 'invalid_length'
  | 'before_start'
  | 'in_past'
  | 'out_of_range'
  | 'not_found'
  | 'unknown'

export type RequestErrors = Partial<Record<RequestField, RequestError>>

const ROLE_MAX = 120
const NOTES_MAX = 2000
const WORKER_COUNT_MAX = 500

/** A new request; a sole location is chosen already. */
export function emptyRequestDraft(locations: Location[]): RequestDraft {
  return {
    locationId: locations.length === 1 ? (locations[0]?.id ?? '') : '',
    role: '',
    date: '',
    startTime: '',
    endTime: '',
    endIsEstimate: false,
    workerCount: '1',
    notes: '',
  }
}

export function requestTimes({ date, startTime, endTime }: RequestDraft) {
  return localTimes(date, startTime, endTime)
}

/** The same rules as the API, so that most mistakes show before anything is sent. */
export function validateRequest(draft: RequestDraft, now = new Date()): RequestErrors {
  const errors: RequestErrors = {}

  for (const field of ['locationId', 'date', 'startTime', 'endTime'] as const) {
    if (!draft[field]) {
      errors[field] = 'required'
    }
  }

  const role = draft.role.trim()
  if (!role) {
    errors.role = 'required'
  } else if (role.length > ROLE_MAX) {
    errors.role = 'invalid_length'
  }
  if (draft.notes.trim().length > NOTES_MAX) {
    errors.notes = 'invalid_length'
  }

  if (draft.startTime && draft.startTime === draft.endTime) {
    errors.endTime = 'before_start'
  }

  const times = requestTimes(draft)
  if (times && times.startsAt.getTime() <= now.getTime()) {
    // A day that has passed is wrong as a whole; on today only the start time is.
    if (draft.date < dateOf(now)) {
      errors.date = 'in_past'
    } else {
      errors.startTime = 'in_past'
    }
  }

  const count = draft.workerCount.trim()
  if (!count) {
    errors.workerCount = 'required'
  } else if (!/^\d+$/.test(count)) {
    errors.workerCount = 'invalid_format'
  } else if (Number(count) < 1 || Number(count) > WORKER_COUNT_MAX) {
    errors.workerCount = 'out_of_range'
  }

  return errors
}

/** The request for a draft that passed `validateRequest`. */
export function toStaffRequest(draft: RequestDraft): StaffRequestRequest {
  const times = requestTimes(draft)
  if (!times) {
    throw new Error('The draft has not been validated')
  }
  const notes = draft.notes.trim()
  return {
    locationId: draft.locationId,
    role: draft.role.trim(),
    startsAt: times.startsAt,
    endsAt: times.endsAt,
    endIsEstimate: draft.endIsEstimate,
    workerCount: Number(draft.workerCount),
    ...(notes && { notes }),
  }
}

const API_FIELDS: Record<string, RequestField> = {
  locationId: 'locationId',
  role: 'role',
  startsAt: 'startTime',
  endsAt: 'endTime',
  workerCount: 'workerCount',
  notes: 'notes',
}

const KNOWN_CODES = new Set<string>([
  'required',
  'invalid_format',
  'invalid_length',
  'before_start',
  'in_past',
  'out_of_range',
  'not_found',
])

/** The field errors of a `validation_failed` response, placed on the fields of the form. */
export function requestServerErrors(fieldErrors: FieldError[]): RequestErrors {
  const errors: RequestErrors = {}
  for (const { field, code } of fieldErrors) {
    const formField = API_FIELDS[field]
    if (formField) {
      errors[formField] = KNOWN_CODES.has(code) ? (code as RequestError) : 'unknown'
    }
  }
  return errors
}
