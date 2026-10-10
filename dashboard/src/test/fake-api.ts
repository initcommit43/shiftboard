import { vi } from 'vitest'

import {
  type CurrentUser,
  CurrentUserToJSON,
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

export function problem(status: number, code: string) {
  return new Response(JSON.stringify({ type: 'about:blank', title: code, status, code }), {
    status,
    headers: { 'Content-Type': 'application/problem+json' },
  })
}

const STORAGE_KEY = 'shiftboard.refreshToken'

/**
 * Replaces `fetch` with an in-memory API that behaves like the contract:
 * rotating single-use refresh tokens, bearer checks and the pending workers.
 */
export function installFakeApi() {
  let generation = 0
  let accessToken: string | null = null
  let refreshToken: string | null = null
  const overrides = new Map<string, Reply[]>()

  const api = {
    calls: [] as Call[],
    pending: [lena, jakob, mira],

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

  function respond(route: string, url: URL, body: unknown, authorization: string | null) {
    if (route === 'POST /auth/login') {
      const { email, password, client } = body as Record<string, string>
      if (client !== 'DASHBOARD') {
        return problem(403, 'wrong_client')
      }
      return email === dispatcher.email && password === PASSWORD
        ? json(issueTokens())
        : problem(401, 'invalid_credentials')
    }
    if (route === 'POST /auth/refresh') {
      const sent = (body as Record<string, string>)['refreshToken']
      return refreshToken !== null && sent === refreshToken
        ? json(issueTokens())
        : problem(401, 'invalid_refresh_token')
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
      return json(CurrentUserToJSON(dispatcher))
    }
    if (route === 'GET /workers') {
      const page = Number(url.searchParams.get('page'))
      const size = Number(url.searchParams.get('size'))
      return json({
        content: api.pending.slice(page * size, (page + 1) * size).map((it) => WorkerToJSON(it)),
        page,
        size,
        totalElements: api.pending.length,
        totalPages: Math.ceil(api.pending.length / size),
      })
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

      const override = overrides.get(route)?.shift()
      if (override instanceof Error) {
        return Promise.reject(override)
      }
      return Promise.resolve(
        override ?? respond(route, url, body, new Headers(init?.headers).get('Authorization')),
      )
    }),
  )

  return api
}
