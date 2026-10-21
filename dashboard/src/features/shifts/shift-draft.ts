import {
  type Client,
  type FieldError,
  type Qualification,
  type Shift,
  type ShiftChangeRequest,
  type ShiftRequest,
  ShiftStatus,
  type ShiftTemplate,
  type ShiftTemplateRequest,
} from '@/api/generated'

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
  | 'below_taken'
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

/** What a new shift can be filled in from: an existing shift or a template. Times are `hh:mm`. */
export interface DraftSource {
  clientId: string
  locationId: string
  title: string
  description?: string | undefined
  startTime: string
  endTime: string
  endIsEstimate: boolean
  hourlyRateCents: number
  slots: number
  qualificationIds: string[]
}

/** A field whose value no longer exists and was left empty. */
export type MissingField = 'clientId' | 'locationId' | 'qualificationIds'

/** `yyyy-mm-dd` of a point in time, in the time zone of the browser. */
export function dateOf(date: Date) {
  return `${String(date.getFullYear())}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
}

/** `hh:mm` of a point in time, in the time zone of the browser. */
export function timeOfDay(date: Date) {
  return `${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}`
}

/** Euro cents as the rate field shows them: "16,50" in German, "16.50" otherwise. */
export function rateText(cents: number, language: string) {
  const text = (cents / 100).toFixed(2)
  return language.startsWith('de') ? text.replace('.', ',') : text
}

/**
 * A draft filled in from a shift or template, without a date. A client, location or
 * qualification that no longer exists is left out and named in `missing`.
 */
export function draftFrom(
  source: DraftSource,
  clients: Client[],
  qualifications: Qualification[],
  language: string,
): { draft: ShiftDraft; missing: MissingField[] } {
  const missing: MissingField[] = []
  const client = clients.find((it) => it.id === source.clientId)
  if (!client) {
    missing.push('clientId')
  }
  const location = client?.locations.find((it) => it.id === source.locationId)
  if (client && !location) {
    missing.push('locationId')
  }
  const known = source.qualificationIds.filter((id) => qualifications.some((it) => it.id === id))
  if (known.length < source.qualificationIds.length) {
    missing.push('qualificationIds')
  }

  return {
    draft: {
      clientId: client?.id ?? '',
      locationId: location?.id ?? '',
      title: source.title,
      description: source.description ?? '',
      date: '',
      startTime: source.startTime,
      endTime: source.endTime,
      endIsEstimate: source.endIsEstimate,
      hourlyRate: rateText(source.hourlyRateCents, language),
      slots: String(source.slots),
      qualificationIds: known,
    },
    missing,
  }
}

/** What a shift gives a duplicate: everything but its date, claims and status. */
export function shiftSource(shift: Shift): DraftSource {
  return {
    clientId: shift.client.id,
    locationId: shift.location.id,
    title: shift.title,
    description: shift.description,
    startTime: timeOfDay(shift.startsAt),
    endTime: timeOfDay(shift.endsAt),
    endIsEstimate: shift.endIsEstimate,
    hourlyRateCents: shift.hourlyRateCents,
    slots: shift.slots,
    qualificationIds: shift.qualifications.map((it) => it.id),
  }
}

const MINUTES_PER_DAY = 24 * 60

function minutesOfDay(time: string) {
  const [hours = 0, minutes = 0] = time.split(':').map(Number)
  return hours * 60 + minutes
}

/** `hh:mm` plus a number of minutes, wrapping past midnight. */
function addMinutes(time: string, minutes: number) {
  const total = (minutesOfDay(time) + minutes) % MINUTES_PER_DAY
  return `${String(Math.floor(total / 60)).padStart(2, '0')}:${String(total % 60).padStart(2, '0')}`
}

/** A draft can be changed any time, a published shift until it starts (ADR 0026). */
export function isEditable(shift: Shift) {
  return (
    shift.status === ShiftStatus.DRAFT ||
    (shift.status === ShiftStatus.PUBLISHED && shift.startsAt.getTime() > Date.now())
  )
}

/** The draft for changing a shift: everything it has, its date included. */
export function editDraftFrom(
  shift: Shift,
  clients: Client[],
  qualifications: Qualification[],
  language: string,
): { draft: ShiftDraft; missing: MissingField[] } {
  const filled = draftFrom(shiftSource(shift), clients, qualifications, language)
  return { ...filled, draft: { ...filled.draft, date: dateOf(shift.startsAt) } }
}

/** What a template gives a new shift: everything but the date. */
export function templateSource(template: ShiftTemplate): DraftSource {
  return {
    clientId: template.clientId,
    locationId: template.locationId,
    title: template.title,
    description: template.description,
    startTime: template.startTime,
    endTime: addMinutes(template.startTime, template.durationMinutes),
    endIsEstimate: template.endIsEstimate,
    hourlyRateCents: template.hourlyRateCents,
    slots: template.slots,
    qualificationIds: [...template.qualificationIds],
  }
}

/** A template request without its name, from values that already passed validation. */
export function sourceToTemplate(source: DraftSource): Omit<ShiftTemplateRequest, 'name'> {
  const length = minutesOfDay(source.endTime) - minutesOfDay(source.startTime)
  return {
    clientId: source.clientId,
    locationId: source.locationId,
    title: source.title,
    ...(source.description && { description: source.description }),
    startTime: source.startTime,
    // An end before the start is on the next day.
    durationMinutes: length > 0 ? length : length + MINUTES_PER_DAY,
    endIsEstimate: source.endIsEstimate,
    hourlyRateCents: source.hourlyRateCents,
    slots: source.slots,
    qualificationIds: new Set(source.qualificationIds),
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
  return localTimes(date, startTime, endTime)
}

/**
 * A day (`yyyy-mm-dd`) with a start and end time (`hh:mm`) as points in time, in the time
 * zone of the browser. An end before the start is on the next day.
 */
export function localTimes(date: string, startTime: string, endTime: string) {
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

/** A template needs everything a shift needs except the date. */
export function validateTemplate(draft: ShiftDraft): DraftErrors {
  // Any date passes, so the date is the one field that cannot be wrong here.
  return validate({ ...draft, date: 'any' })
}

/** The template for a draft that passed `validateTemplate`, without its name. */
export function toTemplateRequest(draft: ShiftDraft): Omit<ShiftTemplateRequest, 'name'> {
  const rate = parseRate(draft.hourlyRate)
  if (rate === null) {
    throw new Error('The draft has not been validated')
  }
  return sourceToTemplate({
    clientId: draft.clientId,
    locationId: draft.locationId,
    title: draft.title.trim(),
    description: draft.description.trim(),
    startTime: draft.startTime,
    endTime: draft.endTime,
    endIsEstimate: draft.endIsEstimate,
    hourlyRateCents: rate,
    slots: Number(draft.slots),
    qualificationIds: draft.qualificationIds,
  })
}

/** The change for a draft that passed `validate`; the status of the shift stays. */
export function toChangeRequest(draft: ShiftDraft): ShiftChangeRequest {
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
  }
}

/** The request for a new shift from a draft that passed `validate`. */
export function toShiftRequest(draft: ShiftDraft, publish: boolean): ShiftRequest {
  return { ...toChangeRequest(draft), publish }
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

/** Where the field errors of a rejected template land on the form. */
export const TEMPLATE_REQUEST_FIELDS: Record<string, DraftField> = {
  ...REQUEST_FIELDS,
  startTime: 'startTime',
  durationMinutes: 'endTime',
}

const SHARED_CODES = new Set<string>([
  'required',
  'invalid_format',
  'invalid_length',
  'before_start',
  'not_found',
  'below_taken',
])

/** The field errors of a `validation_failed` response, placed on the fields of the form. */
export function serverErrors(
  fieldErrors: FieldError[],
  fields: Record<string, DraftField> = REQUEST_FIELDS,
): DraftErrors {
  const errors: DraftErrors = {}
  for (const { field, code } of fieldErrors) {
    const draftField = fields[field]
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
