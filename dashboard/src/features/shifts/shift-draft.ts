import type { Client, FieldError, ShiftRequest } from '@/api/generated'

/** The shift form as the dispatcher types it: every input as text. */
export interface ShiftDraft {
  clientId: string
  locationId: string
  title: string
  description: string
  /** `yyyy-mm-dd`, the day the shift starts on. */
  date: string
  /** `hh:mm` */
  startTime: string
  /** `hh:mm`; a time before the start means the shift ends on the next day. */
  endTime: string
  endIsEstimate: boolean
  /** Euros per hour, with a comma or a point. */
  hourlyRate: string
  slots: string
  qualificationIds: string[]
}

/** In the order of the form, which is the order errors are focused in. */
export const DRAFT_FIELDS = [
  'clientId',
  'locationId',
  'title',
  'description',
  'date',
  'startTime',
  'endTime',
  'hourlyRate',
  'slots',
  'qualificationIds',
] as const

export type DraftField = (typeof DRAFT_FIELDS)[number]

/** The key of the message below a field, `shifts.form.errors.<key>`. */
export type DraftError =
  | 'required'
  | 'invalid_format'
  | 'invalid_length'
  | 'before_start'
  | 'not_found'
  | 'rate_out_of_range'
  | 'slots_out_of_range'
  | 'unknown'

export type DraftErrors = Partial<Record<DraftField, DraftError>>

const TITLE_MAX = 120
const DESCRIPTION_MAX = 2000
const SLOTS_MAX = 500

/** A new draft. A sole client, and a sole location of a client, are chosen already. */
export function emptyDraft(clients: Client[]): ShiftDraft {
  const clientId = clients.length === 1 ? (clients[0]?.id ?? '') : ''
  return {
    clientId,
    locationId: soleLocationId(clients, clientId),
    title: '',
    description: '',
    date: '',
    startTime: '',
    endTime: '',
    endIsEstimate: false,
    hourlyRate: '',
    slots: '1',
    qualificationIds: [],
  }
}

export function soleLocationId(clients: Client[], clientId: string) {
  const locations = clients.find((client) => client.id === clientId)?.locations ?? []
  return locations.length === 1 ? (locations[0]?.id ?? '') : ''
}

/** "16,50" or "16.5" in cents, or null when it is not an amount. */
function parseRate(text: string) {
  if (!/^\d{1,5}([.,]\d{1,2})?$/.test(text.trim())) {
    return null
  }
  return Math.round(Number(text.trim().replace(',', '.')) * 100)
}

/** Start and end as points in time, in the time zone of the browser. */
export function shiftTimes({ date, startTime, endTime }: ShiftDraft) {
  if (!date || !startTime || !endTime) {
    return null
  }
  const startsAt = new Date(`${date}T${startTime}`)
  const endsAt = new Date(`${date}T${endTime}`)
  const endsNextDay = endTime < startTime
  if (endsNextDay) {
    endsAt.setDate(endsAt.getDate() + 1)
  }
  return { startsAt, endsAt, endsNextDay }
}

export function validate(draft: ShiftDraft): DraftErrors {
  const errors: DraftErrors = {}

  for (const field of ['clientId', 'locationId', 'date', 'startTime', 'endTime'] as const) {
    if (!draft[field]) {
      errors[field] = 'required'
    }
  }

  const title = draft.title.trim()
  if (!title) {
    errors.title = 'required'
  } else if (title.length > TITLE_MAX) {
    errors.title = 'invalid_length'
  }
  if (draft.description.trim().length > DESCRIPTION_MAX) {
    errors.description = 'invalid_length'
  }

  if (draft.startTime && draft.startTime === draft.endTime) {
    errors.endTime = 'before_start'
  }

  const rate = parseRate(draft.hourlyRate)
  if (!draft.hourlyRate.trim()) {
    errors.hourlyRate = 'required'
  } else if (rate === null) {
    errors.hourlyRate = 'invalid_format'
  } else if (rate < 1) {
    errors.hourlyRate = 'rate_out_of_range'
  }

  const slots = draft.slots.trim()
  if (!slots) {
    errors.slots = 'required'
  } else if (!/^\d+$/.test(slots)) {
    errors.slots = 'invalid_format'
  } else if (Number(slots) < 1 || Number(slots) > SLOTS_MAX) {
    errors.slots = 'slots_out_of_range'
  }

  return errors
}

/** The request for a draft that passed `validate`. */
export function toShiftRequest(draft: ShiftDraft, publish: boolean): ShiftRequest {
  const times = shiftTimes(draft)
  const rate = parseRate(draft.hourlyRate)
  if (!times || rate === null) {
    throw new Error('The draft has not been validated')
  }
  const description = draft.description.trim()
  return {
    clientId: draft.clientId,
    locationId: draft.locationId,
    title: draft.title.trim(),
    ...(description && { description }),
    startsAt: times.startsAt,
    endsAt: times.endsAt,
    endIsEstimate: draft.endIsEstimate,
    hourlyRateCents: rate,
    slots: Number(draft.slots),
    qualificationIds: new Set(draft.qualificationIds),
    publish,
  }
}

const REQUEST_FIELDS: Record<string, DraftField> = {
  clientId: 'clientId',
  locationId: 'locationId',
  title: 'title',
  description: 'description',
  startsAt: 'date',
  endsAt: 'endTime',
  hourlyRateCents: 'hourlyRate',
  slots: 'slots',
  qualificationIds: 'qualificationIds',
}

const SHARED_CODES = new Set<string>([
  'required',
  'invalid_format',
  'invalid_length',
  'before_start',
  'not_found',
])

/** The field errors of a `validation_failed` response, placed on the fields of the form. */
export function serverErrors(fieldErrors: FieldError[]): DraftErrors {
  const errors: DraftErrors = {}
  for (const { field, code } of fieldErrors) {
    const draftField = REQUEST_FIELDS[field]
    if (!draftField) {
      continue
    }
    if (code === 'out_of_range' && draftField === 'hourlyRate') {
      errors[draftField] = 'rate_out_of_range'
    } else if (code === 'out_of_range' && draftField === 'slots') {
      errors[draftField] = 'slots_out_of_range'
    } else {
      errors[draftField] = SHARED_CODES.has(code) ? (code as DraftError) : 'unknown'
    }
  }
  return errors
}
