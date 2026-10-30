import { vi } from 'vitest'

import {
  type AgencySettings,
  AgencySettingsToJSON,
  AssignmentStatus,
  CancelledBy,
  type AgencyFeatures,
  AgencyFeaturesToJSON,
  type Client,
  ClientToJSON,
  type ClientUser,
  ClientUserStatus,
  ClientUserToJSON,
  type ClientShiftDetail,
  ClientShiftDetailToJSON,
  ClientShiftToJSON,
  type CurrentUser,
  CurrentUserToJSON,
  type FieldError,
  type HoursEntry,
  HoursEntryToJSON,
  HoursStatus,
  type Conversation,
  type ConversationEvent,
  ConversationEventToJSON,
  ConversationToJSON,
  type Location,
  type Message,
  MessageToJSON,
  MessageType,
  type Qualification,
  QualificationToJSON,
  type Shift,
  type ShiftAssignment,
  ShiftAssignmentToJSON,
  ShiftStatus,
  type ShiftTemplate,
  ShiftTemplateToJSON,
  ShiftToJSON,
  type WaitlistEntry,
  WaitlistEntryToJSON,
  type Worker,
  WorkerStatus,
  WorkerToJSON,
} from '@/api/generated'

export const PASSWORD = 'correct-horse-battery'

export const dispatcher: CurrentUser = {
  id: '0199c3a0-0000-7000-8000-000000000001',
  email: 'anna.berger@example.com',
  role: 'DISPATCHER',
  agency: { id: '0199c3a0-0000-7000-8000-0000000000a1', name: 'Donau Personal' },
}

export function worker(
  number: number,
  firstName: string,
  lastName: string,
  qualifications: string[],
  createdAt: Date,
): Worker {
  return {
    id: `0199c3a0-0000-7000-8000-0000000001${String(number).padStart(2, '0')}`,
    firstName,
    lastName,
    dateOfBirth: new Date(1990 + number, 2, 14),
    email: `${firstName}.${lastName}@example.com`.toLowerCase(),
    phone: `+43 660 55501${String(number).padStart(2, '0')}`,
    status: WorkerStatus.PENDING,
    qualifications: qualifications.map((name, index) => ({
      id: `0199c3a0-0000-7000-8000-00000000${String(number).padStart(2, '0')}q${String(index)}`,
      name,
    })),
    createdAt,
  }
}

export const lena = worker(1, 'Lena', 'Hofer', ['Service', 'Bar'], new Date(2026, 9, 9, 18, 42))
export const jakob = worker(2, 'Jakob', 'Steiner', ['Lager'], new Date(2026, 9, 9, 11, 5))
export const mira = worker(3, 'Mira', 'Aigner', ['Service'], new Date(2026, 9, 8, 20, 17))

export const service: Qualification = {
  id: '0199c3a0-0000-7000-8000-0000000002q1',
  name: 'Service',
}
export const forklift: Qualification = {
  id: '0199c3a0-0000-7000-8000-0000000002q2',
  name: 'Staplerschein',
}

export const zentrallager: Location = {
  id: '0199c3a0-0000-7000-8000-000000000311',
  name: 'Zentrallager Linz',
  address: 'Industriezeile 40, 4020 Linz',
}
export const umschlaglager: Location = {
  id: '0199c3a0-0000-7000-8000-000000000312',
  name: 'Umschlaglager Wels',
  address: 'Terminalstraße 12, 4600 Wels',
}
export const hafenhalleLinz: Location = {
  id: '0199c3a0-0000-7000-8000-000000000321',
  name: 'Hafenhalle',
  address: 'Hafenstraße 9, 4020 Linz',
}

export const hafenhalle: Client = {
  id: '0199c3a0-0000-7000-8000-000000000302',
  name: 'Hafenhalle Events',
  locations: [hafenhalleLinz],
}
export const nordlicht: Client = {
  id: '0199c3a0-0000-7000-8000-000000000301',
  name: 'Nordlicht Logistik',
  locations: [umschlaglager, zentrallager],
}

export function shift(number: number, values: Partial<Shift> & Pick<Shift, 'title'>): Shift {
  return {
    id: `0199c3a0-0000-7000-8000-0000000004${String(number).padStart(2, '0')}`,
    status: ShiftStatus.PUBLISHED,
    client: { id: nordlicht.id, name: nordlicht.name },
    location: zentrallager,
    startsAt: new Date(2026, 9, 15, 8, 0),
    endsAt: new Date(2026, 9, 15, 16, 0),
    endIsEstimate: false,
    hourlyRateCents: 1650,
    slots: 5,
    takenSlots: 0,
    waitingCount: 0,
    qualifications: [],
    createdAt: new Date(2026, 9, 12, 9, 30),
    ...values,
  }
}

export const warehouse = shift(1, {
  title: 'Lagerunterstützung',
  endIsEstimate: true,
  takenSlots: 2,
  qualifications: [forklift],
})
export const gala = shift(2, {
  title: 'Servicekraft Gala',
  status: ShiftStatus.DRAFT,
  client: { id: hafenhalle.id, name: hafenhalle.name },
  location: hafenhalleLinz,
  startsAt: new Date(2026, 9, 16, 18, 0),
  endsAt: new Date(2026, 9, 17, 1, 0),
  hourlyRateCents: 1800,
  slots: 4,
  qualifications: [service],
})
export const inventory = shift(3, {
  title: 'Nachtinventur',
  startsAt: new Date(2026, 9, 19, 6, 0),
  endsAt: new Date(2026, 9, 19, 12, 0),
  slots: 2,
  takenSlots: 2,
  waitingCount: 2,
})

export const morningTemplate: ShiftTemplate = {
  id: '0199c3a0-0000-7000-8000-000000000701',
  name: 'Lager Frühschicht',
  clientId: nordlicht.id,
  locationId: zentrallager.id,
  title: 'Lagerunterstützung',
  description: 'Sicherheitsschuhe mitbringen.',
  startTime: '06:00',
  durationMinutes: 480,
  endIsEstimate: false,
  hourlyRateCents: 1650,
  slots: 3,
  qualificationIds: new Set([forklift.id]),
  createdAt: new Date(2026, 9, 12, 9, 0),
}
export const nightTemplate: ShiftTemplate = {
  id: '0199c3a0-0000-7000-8000-000000000702',
  name: 'Gala Nachtservice',
  clientId: hafenhalle.id,
  locationId: hafenhalleLinz.id,
  title: 'Servicekraft Gala',
  startTime: '22:00',
  durationMinutes: 420,
  endIsEstimate: true,
  hourlyRateCents: 1850,
  slots: 6,
  qualificationIds: new Set([service.id]),
  createdAt: new Date(2026, 9, 12, 9, 5),
}

export function assignment(
  number: number,
  person: Worker,
  values: Partial<ShiftAssignment> = {},
): ShiftAssignment {
  return {
    id: `0199c3a0-0000-7000-8000-0000000005${String(number).padStart(2, '0')}`,
    status: AssignmentStatus.PENDING,
    worker: {
      id: person.id,
      firstName: person.firstName,
      lastName: person.lastName,
      phone: person.phone,
    },
    claimedAt: new Date(2026, 9, 12, 10, number),
    ...values,
  }
}

export function waitlistEntry(number: number, person: Worker, position: number): WaitlistEntry {
  return {
    id: `0199c3a0-0000-7000-8000-0000000008${String(number).padStart(2, '0')}`,
    position,
    worker: {
      id: person.id,
      firstName: person.firstName,
      lastName: person.lastName,
      phone: person.phone,
    },
    joinedAt: new Date(2026, 9, 13, 8, number),
  }
}

export function clientUser(
  number: number,
  firstName: string,
  lastName: string,
  status: ClientUserStatus,
): ClientUser {
  return {
    id: `0199c3a0-0000-7000-8000-0000000009${String(number).padStart(2, '0')}`,
    firstName,
    lastName,
    email: `${firstName}.${lastName}@nordlicht.example`.toLowerCase(),
    status,
  }
}

/** Portal users of Nordlicht Logistik, sorted by last name as the API sends them. */
export const petra = clientUser(1, 'Petra', 'Lindner', ClientUserStatus.ACTIVE)
export const tobias = clientUser(2, 'Tobias', 'Wallner', ClientUserStatus.INVITED)

/** Until when a setup code issued by the fake works. */
export const SETUP_EXPIRES_AT = new Date(2026, 9, 22, 14, 30)

/** A client user as the session knows them after logging in. */
export function asCurrentUser(user: ClientUser, client: Client = nordlicht): CurrentUser {
  return {
    id: user.id,
    email: user.email,
    role: 'CLIENT',
    agency: dispatcher.agency,
    client: { id: client.id, name: client.name },
  }
}

/** Petra at Nordlicht Logistik, logged in to the client portal. */
export const clientContact = asCurrentUser(petra)

export function clientShift(
  number: number,
  values: Partial<ClientShiftDetail> & Pick<ClientShiftDetail, 'title'>,
): ClientShiftDetail {
  return {
    id: `0199c3a0-0000-7000-8000-0000000010${String(number).padStart(2, '0')}`,
    status: ShiftStatus.PUBLISHED,
    location: zentrallager,
    startsAt: new Date(2026, 9, 15, 8, 0),
    endsAt: new Date(2026, 9, 15, 16, 0),
    endIsEstimate: false,
    slots: 5,
    confirmedCount: 0,
    description: '',
    confirmedWorkers: [],
    ...values,
  }
}

/** Nordlicht's shifts as its portal shows them: names of confirmed workers only. */
export const portalWarehouse = clientShift(1, {
  title: 'Lagerunterstützung',
  endIsEstimate: true,
  confirmedCount: 4,
  description: 'Sicherheitsschuhe mitbringen. Treffpunkt ist Tor 3.',
  confirmedWorkers: [
    { firstName: 'Mira', lastName: 'Aigner' },
    { firstName: 'Lena', lastName: 'Hofer' },
    { firstName: 'Sophie', lastName: 'Huber' },
    { firstName: 'Jakob', lastName: 'Steiner' },
  ],
})
export const portalInventory = clientShift(2, {
  title: 'Nachtinventur',
  location: umschlaglager,
  startsAt: new Date(2026, 9, 19, 22, 0),
  endsAt: new Date(2026, 9, 20, 6, 0),
  slots: 2,
  confirmedCount: 2,
  confirmedWorkers: [
    { firstName: 'Lena', lastName: 'Hofer' },
    { firstName: 'Jakob', lastName: 'Steiner' },
  ],
})
export const portalUnloading = clientShift(3, {
  title: 'Wareneingang',
  status: ShiftStatus.CANCELLED,
  startsAt: new Date(2026, 9, 21, 6, 0),
  endsAt: new Date(2026, 9, 21, 12, 0),
  slots: 3,
})
export const portalNewYear = clientShift(4, {
  title: 'Inventur Jahresende',
  startsAt: new Date(2026, 11, 30, 7, 0),
  endsAt: new Date(2026, 11, 30, 15, 0),
  slots: 3,
})
export const portalFair = clientShift(5, {
  title: 'Messeaufbau',
  status: ShiftStatus.COMPLETED,
  startsAt: new Date(2026, 9, 8, 7, 0),
  endsAt: new Date(2026, 9, 8, 15, 0),
  slots: 1,
  confirmedCount: 1,
  confirmedWorkers: [{ firstName: 'Jakob', lastName: 'Steiner' }],
})

export const lastWeek = shift(4, {
  title: 'Messeaufbau',
  status: ShiftStatus.COMPLETED,
  startsAt: new Date(2026, 9, 8, 7, 0),
  endsAt: new Date(2026, 9, 8, 15, 0),
  takenSlots: 1,
})

export function message(number: number, values: Partial<Message> & Pick<Message, 'body'>): Message {
  return {
    id: `0199c3a0-0000-7000-8000-0000000006${String(number).padStart(2, '0')}`,
    type: MessageType.TEXT,
    fromWorker: true,
    createdAt: new Date(2026, 9, 12, 9, number),
    ...values,
  }
}

export const lenaConversation: Conversation = {
  id: '0199c3a0-0000-7000-8000-000000000701',
  worker: { id: lena.id, firstName: lena.firstName, lastName: lena.lastName },
  lastMessage: message(3, { body: 'Gibt es einen Parkplatz?' }),
  unreadCount: 1,
}

export const jakobConversation: Conversation = {
  id: '0199c3a0-0000-7000-8000-000000000702',
  worker: { id: jakob.id, firstName: jakob.firstName, lastName: jakob.lastName },
  lastMessage: message(2, { body: 'Danke!', fromWorker: false, senderName: 'Anna Berger' }),
  unreadCount: 0,
}

interface Call {
  route: string
  body: unknown
}

type Reply = Response | Promise<Response> | Error

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  })
}

export function problem(status: number, code: string, errors?: FieldError[]) {
  return new Response(JSON.stringify({ type: 'about:blank', title: code, status, code, errors }), {
    status,
    headers: { 'Content-Type': 'application/problem+json' },
  })
}

const STORAGE_KEY = 'shiftboard.refreshToken'

/**
 * Replaces `fetch` with an in-memory API that behaves like the contract:
 * rotating single-use refresh tokens, bearer checks, the pending workers and
 * the shifts with what their form offers to choose from.
 */
export function installFakeApi() {
  let generation = 0
  let accessToken: string | null = null
  let refreshToken: string | null = null
  const overrides = new Map<string, Reply[]>()
  const queries: { route: string; query: URLSearchParams }[] = []
  const encoder = new TextEncoder()
  let eventStreams: ReadableStreamDefaultController<Uint8Array>[] = []

  const api = {
    calls: [] as Call[],
    pending: [lena, jakob, mira],
    clients: [hafenhalle, nordlicht],
    qualifications: [service, forklift],
    shifts: [warehouse, gala, inventory],
    pastShifts: [lastWeek],
    /** Sorted by name, as the API sends them. */
    templates: [nightTemplate, morningTemplate],
    /** The claims per shift id, oldest first. */
    assignments: {
      [warehouse.id]: [
        assignment(1, lena),
        assignment(2, jakob, { status: AssignmentStatus.CONFIRMED, decidedAt: new Date(2026, 9, 12, 12, 0) }),
        assignment(3, mira, {
          status: AssignmentStatus.CANCELLED,
          cancelledBy: CancelledBy.AGENCY,
          reason: 'Doppelt gebucht',
          decidedAt: new Date(2026, 9, 12, 13, 0),
        }),
      ],
      [lastWeek.id]: [
        assignment(4, jakob, { status: AssignmentStatus.COMPLETED, decidedAt: new Date(2026, 9, 8, 15, 1) }),
      ],
    } as Record<string, ShiftAssignment[]>,
    /** The waitlist per shift id, in line order. */
    waitlists: {
      [inventory.id]: [waitlistEntry(1, lena, 1), waitlistEntry(2, mira, 2)],
    } as Record<string, WaitlistEntry[]>,
    settings: { autoConfirm: false, cancellationDeadlineHours: 24, waitlist: false } as AgencySettings,
    features: { contactButton: false, checkIn: false, clientPortal: false } as AgencyFeatures,
    conversations: [lenaConversation, jakobConversation],
    /** The messages per conversation id, newest first as the API sends them. */
    messages: {
      [lenaConversation.id]: [
        message(3, { body: 'Gibt es einen Parkplatz?', shift: { id: warehouse.id, title: warehouse.title, startsAt: warehouse.startsAt } }),
        message(2, { body: '', type: MessageType.SYSTEM, event: 'CLAIM_CONFIRMED', fromWorker: false }),
        message(1, { body: 'Bitte Sicherheitsschuhe mitbringen.', type: MessageType.BROADCAST, fromWorker: false, senderName: 'Anna Berger' }),
      ],
      [jakobConversation.id]: [jakobConversation.lastMessage],
    } as Record<string, Message[]>,
    user: dispatcher,
    /** The portal users per client id. */
    clientUsers: {
      [nordlicht.id]: [petra, tobias],
    } as Record<string, ClientUser[]>,
    /** The open setup codes, each with the user it belongs to. */
    setupCodes: {
      'tobias-first-code': { clientId: nordlicht.id, userId: tobias.id },
    } as Record<string, { clientId: string; userId: string }>,
    /** What the logged-in client user's portal lists, earliest first. */
    clientShifts: [portalWarehouse, portalInventory, portalUnloading, portalNewYear],
    /** The client's ended shifts, latest first. */
    pastClientShifts: [portalFair],

    /** The query parameters of each request to a route, oldest first. */
    queries(route: string) {
      return queries.filter((it) => it.route === route).map((it) => it.query)
    },
    /** Number of requests to a route such as `POST /auth/refresh`. */
    count(route: string) {
      return api.calls.filter((call) => call.route === route).length
    },
    /** Answers the next request to the route with the given response, or fails it with the error. */
    respondOnce(route: string, reply: Reply) {
      overrides.set(route, [...(overrides.get(route) ?? []), reply])
    },
    /** Stores a valid refresh token, as left behind by an earlier login. */
    signIn() {
      localStorage.setItem(STORAGE_KEY, issueTokens().refreshToken)
    },
    /** Number of open event streams. */
    get openEventStreams() {
      return eventStreams.length
    },
    /** Sends raw text, such as `: ping` or a whole event, down every open event stream. */
    sendEventText(text: string) {
      eventStreams.forEach((stream) => {
        stream.enqueue(encoder.encode(text))
      })
    },
    /** Sends a `conversation` notice down every open event stream. */
    notify(notice: ConversationEvent) {
      api.sendEventText(`event: conversation
data: ${JSON.stringify(ConversationEventToJSON(notice))}

`)
    },
    /** The connections of the open event streams drop. */
    dropEventStreams() {
      const dropped = eventStreams
      eventStreams = []
      dropped.forEach((stream) => {
        stream.error(new TypeError('network error'))
      })
    },
    /** The access token expires; the refresh token stays valid. */
    expireAccessToken() {
      accessToken = null
    },
    /** The server forgets the session, as after a logout on another device. */
    revokeSession() {
      accessToken = null
      refreshToken = null
    },
  }

  function issueTokens() {
    generation += 1
    accessToken = `access-${String(generation)}`
    refreshToken = `refresh-${String(generation)}`
    return { accessToken, refreshToken, expiresIn: 900 }
  }

  function page<T>(url: URL, items: T[], toJSON: (item: T) => unknown) {
    const page = Number(url.searchParams.get('page'))
    const size = Number(url.searchParams.get('size'))
    return json({
      content: items.slice(page * size, (page + 1) * size).map((it) => toJSON(it)),
      page,
      size,
      totalElements: items.length,
      totalPages: Math.ceil(items.length / size),
    })
  }

  function createShift(body: Record<string, unknown>) {
    const client = api.clients.find((it) => it.id === body['clientId'])
    const location = client?.locations.find((it) => it.id === body['locationId'])
    if (!client || !location) {
      return problem(400, 'validation_failed', [
        { field: client ? 'locationId' : 'clientId', code: 'not_found' },
      ])
    }
    const created = shift(api.shifts.length + 1, {
      title: body['title'] as string,
      status: body['publish'] === true ? ShiftStatus.PUBLISHED : ShiftStatus.DRAFT,
      client: { id: client.id, name: client.name },
      location,
      startsAt: new Date(body['startsAt'] as string),
      endsAt: new Date(body['endsAt'] as string),
      endIsEstimate: body['endIsEstimate'] === true,
      hourlyRateCents: body['hourlyRateCents'] as number,
      slots: body['slots'] as number,
      qualifications: api.qualifications.filter((it) =>
        (body['qualificationIds'] as string[]).includes(it.id),
      ),
    })
    api.shifts = [...api.shifts, created].sort(
      (a, b) => a.startsAt.getTime() - b.startsAt.getTime(),
    )
    return json(ShiftToJSON(created), 201)
  }

  function updateShift(shiftId: string, body: Record<string, unknown>) {
    const found = api.shifts.find((it) => it.id === shiftId)
    if (!found) {
      return problem(404, 'shift_not_found')
    }
    if (found.status !== ShiftStatus.DRAFT && found.status !== ShiftStatus.PUBLISHED) {
      return problem(409, 'shift_not_editable')
    }
    const client = api.clients.find((it) => it.id === body['clientId'])
    const location = client?.locations.find((it) => it.id === body['locationId'])
    if (!client || !location) {
      return problem(400, 'validation_failed', [
        { field: client ? 'locationId' : 'clientId', code: 'not_found' },
      ])
    }
    if ((body['slots'] as number) < found.takenSlots) {
      return problem(400, 'validation_failed', [{ field: 'slots', code: 'below_taken' }])
    }
    const updated: Shift = {
      ...found,
      title: body['title'] as string,
      client: { id: client.id, name: client.name },
      location,
      startsAt: new Date(body['startsAt'] as string),
      endsAt: new Date(body['endsAt'] as string),
      endIsEstimate: body['endIsEstimate'] === true,
      hourlyRateCents: body['hourlyRateCents'] as number,
      slots: body['slots'] as number,
      qualifications: api.qualifications.filter((it) =>
        (body['qualificationIds'] as string[]).includes(it.id),
      ),
    }
    // Absent removes the description.
    if (typeof body['description'] === 'string') {
      updated.description = body['description']
    } else {
      delete updated.description
    }
    api.shifts = api.shifts.map((it) => (it === found ? updated : it))
    return json(ShiftToJSON(updated))
  }

  // Ids of new templates follow the two the fake starts with.
  let templateNumber = 2

  function templateFrom(body: Record<string, unknown>) {
    return {
      name: body['name'] as string,
      clientId: body['clientId'] as string,
      locationId: body['locationId'] as string,
      title: body['title'] as string,
      ...(typeof body['description'] === 'string' && { description: body['description'] }),
      startTime: body['startTime'] as string,
      durationMinutes: body['durationMinutes'] as number,
      endIsEstimate: body['endIsEstimate'] === true,
      hourlyRateCents: body['hourlyRateCents'] as number,
      slots: body['slots'] as number,
      qualificationIds: new Set(body['qualificationIds'] as string[]),
    }
  }

  function sortTemplates(templates: ShiftTemplate[]) {
    return templates.sort((a, b) => a.name.localeCompare(b.name, 'de', { sensitivity: 'base' }))
  }

  function createTemplate(body: Record<string, unknown>) {
    const name = body['name'] as string
    if (api.templates.some((it) => it.name.toLowerCase() === name.toLowerCase())) {
      return problem(409, 'template_name_taken')
    }
    templateNumber += 1
    const created: ShiftTemplate = {
      ...templateFrom(body),
      id: `0199c3a0-0000-7000-8000-0000000007${String(templateNumber).padStart(2, '0')}`,
      createdAt: new Date(2026, 9, 14, 12, 0),
    }
    api.templates = sortTemplates([...api.templates, created])
    return json(ShiftTemplateToJSON(created), 201)
  }

  function updateTemplate(template: ShiftTemplate, body: Record<string, unknown>) {
    const name = body['name'] as string
    if (api.templates.some((it) => it !== template && it.name.toLowerCase() === name.toLowerCase())) {
      return problem(409, 'template_name_taken')
    }
    const updated: ShiftTemplate = { ...templateFrom(body), id: template.id, createdAt: template.createdAt }
    api.templates = sortTemplates(api.templates.map((it) => (it === template ? updated : it)))
    return json(ShiftTemplateToJSON(updated))
  }

  function allShifts() {
    return [...api.shifts, ...api.pastShifts]
  }

  function replaceShift(next: Shift) {
    api.shifts = api.shifts.map((it) => (it.id === next.id ? next : it))
    api.pastShifts = api.pastShifts.map((it) => (it.id === next.id ? next : it))
  }

  function shiftAction(
    url: URL,
    shiftId: string,
    sub: string | undefined,
    assignmentId: string | undefined,
    action: string | undefined,
    body: unknown,
  ) {
    const found = allShifts().find((it) => it.id === shiftId)
    if (!found) {
      return problem(404, 'shift_not_found')
    }
    if (sub === undefined) {
      return json(ShiftToJSON(found))
    }
    const claims = api.assignments[shiftId] ?? []
    if (sub === '/cancel') {
      if (found.status !== ShiftStatus.DRAFT && found.status !== ShiftStatus.PUBLISHED) {
        return problem(409, 'shift_not_cancellable')
      }
      const cancelled = { ...found, status: ShiftStatus.CANCELLED, takenSlots: 0, waitingCount: 0 }
      replaceShift(cancelled)
      api.waitlists[shiftId] = []
      api.assignments[shiftId] = claims.map((it) =>
        it.status === AssignmentStatus.PENDING || it.status === AssignmentStatus.CONFIRMED
          ? { ...it, status: AssignmentStatus.CANCELLED, cancelledBy: CancelledBy.AGENCY }
          : it,
      )
      return json(ShiftToJSON(cancelled))
    }
    if (sub === '/assignments' && assignmentId === undefined) {
      return page(url, claims, ShiftAssignmentToJSON)
    }
    const claim = claims.find((it) => it.id === assignmentId)
    if (!claim) {
      return problem(404, 'assignment_not_found')
    }
    const holding =
      claim.status === AssignmentStatus.PENDING || claim.status === AssignmentStatus.CONFIRMED
    let next: ShiftAssignment
    let freesSpot = false
    if (action === 'approve' || action === 'reject') {
      if (claim.status !== AssignmentStatus.PENDING) {
        return problem(409, 'assignment_not_pending')
      }
      next = {
        ...claim,
        status: action === 'approve' ? AssignmentStatus.CONFIRMED : AssignmentStatus.REJECTED,
      }
      freesSpot = action === 'reject'
    } else if (action === 'remove') {
      const reason = ((body as Record<string, string>)['reason'] ?? '').trim()
      if (!reason) {
        return problem(400, 'validation_failed', [{ field: 'reason', code: 'required' }])
      }
      if (!holding) {
        return problem(409, 'assignment_not_active')
      }
      next = { ...claim, status: AssignmentStatus.CANCELLED, cancelledBy: CancelledBy.AGENCY, reason }
      freesSpot = true
    } else if (action === 'no-show') {
      if (claim.status !== AssignmentStatus.COMPLETED) {
        return problem(409, 'assignment_not_completed')
      }
      if (claim.checkedInAt || claim.hours) {
        return problem(409, 'worker_attended')
      }
      next = { ...claim, status: AssignmentStatus.NO_SHOW }
    } else {
      return problem(404, 'not_found')
    }
    next = { ...next, decidedAt: new Date(2026, 9, 13, 9, 0) }
    api.assignments[shiftId] = claims.map((it) => (it === claim ? next : it))
    if (freesSpot) {
      replaceShift({ ...found, takenSlots: found.takenSlots - 1 })
      moveUp(shiftId)
    }
    return json(ShiftAssignmentToJSON(next))
  }

  // Ids of claims made by moving up follow the fixtures.
  let movedUpNumber = 50

  /**
   * A freed spot goes to the first in line, as a request or confirmed right away (ADR 0029).
   * The fake leaves out the cancellation deadline and overlaps.
   */
  function moveUp(shiftId: string) {
    const [first, ...rest] = api.waitlists[shiftId] ?? []
    const found = allShifts().find((it) => it.id === shiftId)
    if (!first || !found) {
      return
    }
    movedUpNumber += 1
    const claim: ShiftAssignment = {
      id: `0199c3a0-0000-7000-8000-0000000005${String(movedUpNumber)}`,
      status: api.settings.autoConfirm ? AssignmentStatus.CONFIRMED : AssignmentStatus.PENDING,
      worker: first.worker,
      claimedAt: new Date(2026, 9, 13, 9, 0),
    }
    api.assignments[shiftId] = [...(api.assignments[shiftId] ?? []), claim]
    api.waitlists[shiftId] = rest.map((it, index) => ({ ...it, position: index + 1 }))
    replaceShift({ ...found, takenSlots: found.takenSlots + 1, waitingCount: found.waitingCount - 1 })
  }

  /** The line of a shift; taking someone off closes the gap and keeps the order of the others. */
  function waitlistAction(url: URL, method: string, shiftId: string, entryId: string | undefined) {
    const found = allShifts().find((it) => it.id === shiftId)
    if (!found) {
      return problem(404, 'shift_not_found')
    }
    const line = api.waitlists[shiftId] ?? []
    if (method === 'GET' && entryId === undefined) {
      return page(url, line, WaitlistEntryToJSON)
    }
    if (method !== 'DELETE' || entryId === undefined) {
      return problem(404, 'not_found')
    }
    if (!line.some((it) => it.id === entryId)) {
      return problem(404, 'waitlist_entry_not_found')
    }
    api.waitlists[shiftId] = line
      .filter((it) => it.id !== entryId)
      .map((it, index) => ({ ...it, position: index + 1 }))
    replaceShift({ ...found, waitingCount: found.waitingCount - 1 })
    return new Response(null, { status: 204 })
  }

  function hasWorked(claim: ShiftAssignment) {
    return claim.status === AssignmentStatus.CONFIRMED || claim.status === AssignmentStatus.COMPLETED
  }

  function approveHours(shiftId: string, assignmentId: string, body: Record<string, unknown>) {
    const found = allShifts().find((it) => it.id === shiftId)
    if (!found) {
      return problem(404, 'shift_not_found')
    }
    const claims = api.assignments[shiftId] ?? []
    const claim = claims.find((it) => it.id === assignmentId)
    if (!claim) {
      return problem(404, 'assignment_not_found')
    }
    if (found.startsAt.getTime() > Date.now()) {
      return problem(409, 'shift_not_started')
    }
    if (!hasWorked(claim)) {
      return problem(409, 'assignment_not_worked')
    }
    const startedAt = new Date(body['startedAt'] as string)
    const endedAt = new Date(body['endedAt'] as string)
    const breakMinutes = body['breakMinutes'] as number
    const minutes = (endedAt.getTime() - startedAt.getTime()) / 60000
    if (minutes <= 0) {
      return problem(400, 'validation_failed', [{ field: 'endedAt', code: 'before_start' }])
    }
    if (minutes > 24 * 60) {
      return problem(400, 'validation_failed', [{ field: 'endedAt', code: 'too_long' }])
    }
    if (breakMinutes >= minutes) {
      return problem(400, 'validation_failed', [{ field: 'breakMinutes', code: 'too_long' }])
    }
    const workedMinutes = minutes - breakMinutes
    const next: ShiftAssignment = {
      ...claim,
      hours: {
        startedAt,
        endedAt,
        breakMinutes,
        workedMinutes,
        grossCents: Math.round((workedMinutes * found.hourlyRateCents) / 60),
        approvedAt: new Date(2026, 9, 20, 10, 0),
      },
    }
    api.assignments[shiftId] = claims.map((it) => (it === claim ? next : it))
    return json(ShiftAssignmentToJSON(next))
  }

  /** One entry per worker who held a confirmed spot on a started shift starting in [from, to). */
  function listHours(url: URL) {
    const from = new Date(url.searchParams.get('from') ?? '').getTime()
    const to = new Date(url.searchParams.get('to') ?? '').getTime()
    if (!(to > from)) {
      return problem(400, 'validation_failed', [{ field: 'to', code: 'before_start' }])
    }
    const entries: HoursEntry[] = allShifts()
      .filter(
        (it) =>
          it.startsAt.getTime() >= from &&
          it.startsAt.getTime() < to &&
          it.startsAt.getTime() <= Date.now(),
      )
      .sort((a, b) => a.startsAt.getTime() - b.startsAt.getTime())
      .flatMap((it) =>
        (api.assignments[it.id] ?? []).filter(hasWorked).map((claim) => ({
          assignmentId: claim.id,
          status: claim.hours ? HoursStatus.APPROVED : HoursStatus.OPEN,
          shift: {
            id: it.id,
            title: it.title,
            startsAt: it.startsAt,
            endsAt: it.endsAt,
            hourlyRateCents: it.hourlyRateCents,
            client: it.client,
            location: it.location,
          },
          worker: claim.worker,
          ...(claim.checkedInAt && { checkedInAt: claim.checkedInAt }),
          ...(claim.checkedOutAt && { checkedOutAt: claim.checkedOutAt }),
          ...(claim.hours && { hours: claim.hours }),
        })),
      )
    return page(url, entries, HoursEntryToJSON)
  }

  // Setup codes issued by the fake are numbered.
  let setupNumber = 0

  function issueSetupCode(clientId: string, user: ClientUser) {
    for (const [code, owner] of Object.entries(api.setupCodes)) {
      if (owner.userId === user.id) {
        // eslint-disable-next-line @typescript-eslint/no-dynamic-delete -- the codes are a lookup table
        delete api.setupCodes[code]
      }
    }
    setupNumber += 1
    const setupCode = `setup-code-${String(setupNumber)}`
    api.setupCodes[setupCode] = { clientId, userId: user.id }
    return { user: ClientUserToJSON(user), setupCode, expiresAt: SETUP_EXPIRES_AT.toISOString() }
  }

  function inviteClientUser(clientId: string, body: Record<string, string>) {
    if (!api.features.clientPortal) {
      return problem(403, 'client_portal_off')
    }
    const errors: FieldError[] = []
    for (const field of ['firstName', 'lastName', 'email']) {
      if (!body[field]?.trim()) {
        errors.push({ field, code: 'required' })
      }
    }
    if (body['email'] && !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(body['email'])) {
      errors.push({ field: 'email', code: 'invalid_format' })
    }
    if (errors.length > 0) {
      return problem(400, 'validation_failed', errors)
    }
    const email = (body['email'] ?? '').toLowerCase()
    const everyone = Object.values(api.clientUsers).flat()
    if (email === api.user.email || everyone.some((it) => it.email === email)) {
      return problem(409, 'email_already_registered')
    }
    const created: ClientUser = {
      ...clientUser(everyone.length + 10, body['firstName'] ?? '', body['lastName'] ?? '', ClientUserStatus.INVITED),
      email,
    }
    api.clientUsers[clientId] = [...(api.clientUsers[clientId] ?? []), created].sort((a, b) =>
      `${a.lastName} ${a.firstName}`.localeCompare(`${b.lastName} ${b.firstName}`, 'de'),
    )
    return json(issueSetupCode(clientId, created), 201)
  }

  function clientUserAction(clientId: string, userId: string, action: string) {
    const users = api.clientUsers[clientId] ?? []
    const found = users.find((it) => it.id === userId)
    if (!found) {
      return problem(404, 'client_user_not_found')
    }
    if (action === 'setup-link') {
      if (!api.features.clientPortal) {
        return problem(403, 'client_portal_off')
      }
      if (found.status !== ClientUserStatus.INVITED) {
        return problem(409, 'client_user_not_invited')
      }
      return json(issueSetupCode(clientId, found))
    }
    const deactivated = { ...found, status: ClientUserStatus.DEACTIVATED }
    api.clientUsers[clientId] = users.map((it) => (it === found ? deactivated : it))
    for (const [code, owner] of Object.entries(api.setupCodes)) {
      if (owner.userId === userId) {
        // eslint-disable-next-line @typescript-eslint/no-dynamic-delete -- the codes are a lookup table
        delete api.setupCodes[code]
      }
    }
    return json(ClientUserToJSON(deactivated))
  }

  /** Why the signed-in client user may not log in, if they may not. Staff are never blocked. */
  function clientUserBlocked() {
    if (api.user.role !== 'CLIENT') {
      return undefined
    }
    if (!api.features.clientPortal) {
      return problem(403, 'client_portal_off')
    }
    const account = Object.values(api.clientUsers)
      .flat()
      .find((it) => it.id === api.user.id)
    return account?.status === ClientUserStatus.DEACTIVATED
      ? problem(403, 'account_deactivated')
      : undefined
  }

  function clientSetup(method: string, setupCode: string, body: unknown) {
    if (!api.features.clientPortal) {
      return problem(403, 'client_portal_off')
    }
    const owner = api.setupCodes[setupCode]
    const users = owner ? (api.clientUsers[owner.clientId] ?? []) : []
    const invited = users.find((it) => it.id === owner?.userId)
    const client = api.clients.find((it) => it.id === owner?.clientId)
    if (!owner || !invited || !client) {
      return problem(404, 'setup_code_invalid')
    }
    if (method === 'GET') {
      return json({
        firstName: invited.firstName,
        email: invited.email,
        clientName: client.name,
        agencyName: dispatcher.agency.name,
      })
    }
    const password = (body as Record<string, string>)['password'] ?? ''
    if (password.length < 8) {
      return problem(400, 'validation_failed', [{ field: 'password', code: 'invalid_length' }])
    }
    // eslint-disable-next-line @typescript-eslint/no-dynamic-delete -- the codes are a lookup table
    delete api.setupCodes[setupCode]
    const active = { ...invited, status: ClientUserStatus.ACTIVE }
    api.clientUsers[owner.clientId] = users.map((it) => (it === invited ? active : it))
    api.user = asCurrentUser(active, client)
    return json(issueTokens())
  }

  function clientShiftsRoute(route: string, url: URL) {
    if (api.user.role !== 'CLIENT') {
      return problem(403, 'forbidden')
    }
    if (route === 'GET /client/shifts') {
      const past = url.searchParams.get('period') === 'PAST'
      return page(url, past ? api.pastClientShifts : api.clientShifts, ClientShiftToJSON)
    }
    const shiftId = route.replace('GET /client/shifts/', '')
    const found = [...api.clientShifts, ...api.pastClientShifts].find((it) => it.id === shiftId)
    return found ? json(ClientShiftDetailToJSON(found)) : problem(404, 'shift_not_found')
  }

  /** An event stream that stays open until it is dropped or the request is aborted. */
  function eventStream(signal: AbortSignal | null | undefined) {
    let controller: ReadableStreamDefaultController<Uint8Array> | undefined
    const close = () => {
      eventStreams = eventStreams.filter((it) => it !== controller)
    }
    const body = new ReadableStream<Uint8Array>({
      start(it) {
        controller = it
        eventStreams.push(it)
        signal?.addEventListener('abort', () => {
          close()
          it.error(new DOMException('aborted', 'AbortError'))
        })
      },
      cancel: close,
    })
    return new Response(body, { headers: { 'Content-Type': 'text/event-stream' } })
  }

  function respond(
    route: string,
    url: URL,
    body: unknown,
    authorization: string | null,
    signal: AbortSignal | null | undefined,
  ) {
    if (route === 'POST /auth/login') {
      const { email, password, client } = body as Record<string, string>
      if (client !== 'DASHBOARD') {
        return problem(403, 'wrong_client')
      }
      if (email !== api.user.email || password !== PASSWORD) {
        return problem(401, 'invalid_credentials')
      }
      const blocked = clientUserBlocked()
      return blocked ?? json(issueTokens())
    }
    const setupRoute = /^(GET|POST) \/client-setup\/([^/]+)$/.exec(route)
    if (setupRoute) {
      return clientSetup(setupRoute[1] ?? '', decodeURIComponent(setupRoute[2] ?? ''), body)
    }
    if (route === 'POST /auth/refresh') {
      const sent = (body as Record<string, string>)['refreshToken']
      if (refreshToken === null || sent !== refreshToken) {
        return problem(401, 'invalid_refresh_token')
      }
      // Deactivating revokes the refresh tokens; switching the portal off keeps them but refuses them.
      return api.user.role === 'CLIENT' && !api.features.clientPortal
        ? problem(403, 'client_portal_off')
        : json(issueTokens())
    }
    if (route === 'POST /auth/logout') {
      accessToken = null
      refreshToken = null
      return new Response(null, { status: 204 })
    }
    if (accessToken === null || authorization !== `Bearer ${accessToken}`) {
      return problem(401, 'unauthenticated')
    }
    if (route === 'GET /me') {
      return json(CurrentUserToJSON(api.user))
    }
    if (/^GET \/client\/shifts(\/[^/]+)?$/.test(route)) {
      return clientShiftsRoute(route, url)
    }
    // Client users reach nothing of the agency's API (ADR 0032).
    if (api.user.role === 'CLIENT') {
      return problem(403, 'forbidden')
    }
    if (route === 'GET /workers') {
      return page(url, api.pending, WorkerToJSON)
    }
    if (route === 'GET /clients') {
      return page(url, api.clients, ClientToJSON)
    }
    const clientUsersRoute = /^(GET|POST) \/clients\/([^/]+)\/users$/.exec(route)
    if (clientUsersRoute) {
      const clientId = clientUsersRoute[2] ?? ''
      if (!api.clients.some((it) => it.id === clientId)) {
        return problem(404, 'client_not_found')
      }
      return clientUsersRoute[1] === 'GET'
        ? json((api.clientUsers[clientId] ?? []).map((it) => ClientUserToJSON(it)))
        : inviteClientUser(clientId, body as Record<string, string>)
    }
    const clientUserRoute = /^POST \/clients\/([^/]+)\/users\/([^/]+)\/(setup-link|deactivate)$/.exec(route)
    if (clientUserRoute) {
      return clientUserAction(clientUserRoute[1] ?? '', clientUserRoute[2] ?? '', clientUserRoute[3] ?? '')
    }
    if (route === 'GET /qualifications') {
      return page(url, api.qualifications, QualificationToJSON)
    }
    if (route === 'GET /shift-templates') {
      return page(url, api.templates, ShiftTemplateToJSON)
    }
    if (route === 'POST /shift-templates') {
      return createTemplate(body as Record<string, unknown>)
    }
    const templateRoute = /^(PUT|DELETE) \/shift-templates\/([^/]+)$/.exec(route)
    if (templateRoute) {
      const id = templateRoute[2] ?? ''
      const found = api.templates.find((it) => it.id === id)
      if (!found) {
        return problem(404, 'template_not_found')
      }
      if (templateRoute[1] === 'DELETE') {
        api.templates = api.templates.filter((it) => it !== found)
        return new Response(null, { status: 204 })
      }
      return updateTemplate(found, body as Record<string, unknown>)
    }
    if (route === 'GET /shifts') {
      const past = url.searchParams.get('period') === 'PAST'
      return page(url, past ? api.pastShifts : api.shifts, ShiftToJSON)
    }
    if (route === 'GET /agency/features') {
      return json(AgencyFeaturesToJSON(api.features))
    }
    if (route === 'PUT /agency/features') {
      if (api.user.role !== 'ADMIN') {
        return problem(403, 'forbidden')
      }
      api.features = body as AgencyFeatures
      return json(AgencyFeaturesToJSON(api.features))
    }
    if (route === 'GET /conversations/events') {
      return eventStream(signal)
    }
    if (route === 'GET /conversations') {
      return page(url, api.conversations, ConversationToJSON)
    }
    if (route === 'GET /conversations/unread-count') {
      return json({ unreadCount: api.conversations.reduce((sum, it) => sum + it.unreadCount, 0) })
    }
    const conversationRoute = /^(GET|POST) \/conversations\/([^/]+)\/messages$/.exec(route)
    if (conversationRoute) {
      const id = conversationRoute[2] ?? ''
      const thread = api.messages[id]
      if (!thread) {
        return problem(404, 'conversation_not_found')
      }
      if (conversationRoute[1] === 'GET') {
        api.conversations = api.conversations.map((it) => (it.id === id ? { ...it, unreadCount: 0 } : it))
        return page(url, thread, MessageToJSON)
      }
      const sent = message(thread.length + 10, {
        body: (body as Record<string, string>)['body'] ?? '',
        fromWorker: false,
        senderName: 'Anna Berger',
      })
      api.messages[id] = [sent, ...thread]
      return json(MessageToJSON(sent), 201)
    }
    const broadcastRoute = /^POST \/shifts\/([^/]+)\/broadcast$/.exec(route)
    if (broadcastRoute) {
      const confirmed = (api.assignments[broadcastRoute[1] ?? ''] ?? []).filter(
        (it) => it.status === AssignmentStatus.CONFIRMED,
      ).length
      return confirmed === 0 ? problem(409, 'no_recipients') : json({ recipients: confirmed }, 201)
    }
    if (route === 'GET /agency/settings') {
      return json(AgencySettingsToJSON(api.settings))
    }
    if (route === 'PUT /agency/settings') {
      if (api.user.role !== 'ADMIN') {
        return problem(403, 'forbidden')
      }
      api.settings = body as AgencySettings
      return json(AgencySettingsToJSON(api.settings))
    }
    if (route === 'GET /hours') {
      return listHours(url)
    }
    const hoursRoute = /^PUT \/shifts\/([^/]+)\/assignments\/([^/]+)\/hours$/.exec(route)
    if (hoursRoute) {
      return approveHours(hoursRoute[1] ?? '', hoursRoute[2] ?? '', body as Record<string, unknown>)
    }
    const waitlistRoute = /^(GET|DELETE) \/shifts\/([^/]+)\/waitlist(?:\/([^/]+))?$/.exec(route)
    if (waitlistRoute) {
      return waitlistAction(url, waitlistRoute[1] ?? '', waitlistRoute[2] ?? '', waitlistRoute[3])
    }
    const shiftUpdate = /^PUT \/shifts\/([^/]+)$/.exec(route)
    if (shiftUpdate) {
      return updateShift(shiftUpdate[1] ?? '', body as Record<string, unknown>)
    }
    const shiftRoute = /^(GET|POST) \/shifts\/([^/]+)(\/[a-z-]+)?(?:\/([^/]+)\/([a-z-]+))?$/.exec(route)
    if (shiftRoute && shiftRoute[3] !== '/publish') {
      return shiftAction(url, shiftRoute[2] ?? '', shiftRoute[3], shiftRoute[4], shiftRoute[5], body)
    }
    if (route === 'POST /shifts') {
      return createShift(body as Record<string, unknown>)
    }
    const publication = /^POST \/shifts\/([^/]+)\/publish$/.exec(route)
    if (publication) {
      const draft = api.shifts.find((it) => it.id === publication[1])
      if (!draft) {
        return problem(404, 'shift_not_found')
      }
      if (draft.status !== ShiftStatus.DRAFT) {
        return problem(409, 'shift_not_draft')
      }
      const published = { ...draft, status: ShiftStatus.PUBLISHED }
      api.shifts = api.shifts.map((it) => (it === draft ? published : it))
      return json(ShiftToJSON(published))
    }
    const decision = /^POST \/workers\/([^/]+)\/(approve|reject)$/.exec(route)
    if (decision) {
      const decided = api.pending.find((it) => it.id === decision[1])
      if (!decided) {
        return problem(409, 'worker_not_pending')
      }
      api.pending = api.pending.filter((it) => it !== decided)
      const status = decision[2] === 'approve' ? WorkerStatus.ACTIVE : WorkerStatus.INACTIVE
      return json(WorkerToJSON({ ...decided, status }))
    }
    return problem(404, 'not_found')
  }

  vi.stubGlobal(
    'fetch',
    vi.fn<typeof fetch>((input, init) => {
      const url = new URL(input as string, 'http://localhost')
      const route = `${init?.method ?? 'GET'} ${url.pathname.replace('/api/v1', '')}`
      const body: unknown = typeof init?.body === 'string' ? JSON.parse(init.body) : undefined
      api.calls.push({ route, body })
      queries.push({ route, query: url.searchParams })

      const override = overrides.get(route)?.shift()
      if (override instanceof Error) {
        return Promise.reject(override)
      }
      return Promise.resolve(
        override ?? respond(route, url, body, new Headers(init?.headers).get('Authorization'), init?.signal),
      )
    }),
  )

  return api
}
