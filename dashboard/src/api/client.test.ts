import { beforeEach, describe, expect, it, vi } from 'vitest'

import { installFakeApi, problem } from '@/test/fake-api'

import { authApi, onSessionExpired, workersApi } from './client'
import { ApiError } from './errors'
import { FetchError } from './generated'
import { getAccessToken, getRefreshToken, setTokens } from './tokens'

describe('API client', () => {
  let api: ReturnType<typeof installFakeApi>

  /** Logs in against the fake API, so that client and server agree on the tokens. */
  async function signIn() {
    api.signIn()
    setTokens(await authApi.refreshToken({ refreshTokenRequest: { refreshToken: 'refresh-1' } }))
    api.calls.length = 0
  }

  beforeEach(() => {
    api = installFakeApi()
  })

  it('sends the access token and returns the response', async () => {
    await signIn()

    const page = await workersApi.listWorkers({ status: 'PENDING' })

    expect(page.totalElements).toBe(3)
    expect(api.calls.map((call) => call.route)).toEqual(['GET /workers'])
  })

  it('refreshes once on 401 and repeats the request with the new token', async () => {
    await signIn()
    api.expireAccessToken()

    const page = await workersApi.listWorkers({ status: 'PENDING' })

    expect(page.totalElements).toBe(3)
    expect(api.calls.map((call) => call.route)).toEqual([
      'GET /workers',
      'POST /auth/refresh',
      'GET /workers',
    ])
    expect(getAccessToken()).toBe('access-3')
    expect(getRefreshToken()).toBe('refresh-3')
  })

  it('shares a single refresh between concurrent requests', async () => {
    await signIn()
    api.expireAccessToken()

    const pages = await Promise.all([
      workersApi.listWorkers({ status: 'PENDING' }),
      workersApi.listWorkers({ status: 'PENDING', page: 1 }),
      authApi.getCurrentUser(),
    ])

    expect(pages).toHaveLength(3)
    expect(api.count('POST /auth/refresh')).toBe(1)
  })

  it('reuses a token that another request has refreshed in the meantime', async () => {
    await signIn()
    api.expireAccessToken()
    let releaseStale: (response: Response) => void = () => undefined
    api.respondOnce(
      'GET /me',
      new Promise<Response>((resolve) => {
        releaseStale = resolve
      }),
    )

    const slow = authApi.getCurrentUser()
    await workersApi.listWorkers({ status: 'PENDING' })
    releaseStale(problem(401, 'unauthenticated'))

    await expect(slow).resolves.toMatchObject({ email: 'anna.berger@example.com' })
    expect(api.count('POST /auth/refresh')).toBe(1)
  })

  it('ends the session when the refresh fails', async () => {
    await signIn()
    api.revokeSession()
    const expired = vi.fn()
    const unsubscribe = onSessionExpired(expired)

    await expect(workersApi.listWorkers({ status: 'PENDING' })).rejects.toMatchObject({
      status: 401,
    })

    expect(expired).toHaveBeenCalledOnce()
    expect(getAccessToken()).toBeNull()
    expect(getRefreshToken()).toBeNull()
    expect(api.count('GET /workers')).toBe(1)
    unsubscribe()
  })

  it('does not refresh for auth endpoints', async () => {
    await signIn()

    await expect(
      authApi.login({
        loginRequest: { email: 'anna.berger@example.com', password: 'wrong', client: 'DASHBOARD' },
      }),
    ).rejects.toMatchObject({ status: 401, code: 'invalid_credentials' })

    expect(api.count('POST /auth/refresh')).toBe(0)
  })

  it('turns problem responses into an ApiError with the code', async () => {
    await signIn()
    api.respondOnce('POST /workers/unknown/approve', problem(404, 'worker_not_found'))

    const error: unknown = await workersApi.approveWorker({ workerId: 'unknown' }).catch(
      (caught: unknown) => caught,
    )

    expect(error).toBeInstanceOf(ApiError)
    expect(error).toMatchObject({ status: 404, code: 'worker_not_found' })
  })

  it('leaves failed connections as FetchError', async () => {
    await signIn()
    api.respondOnce('GET /workers', new TypeError('Failed to fetch'))

    await expect(workersApi.listWorkers()).rejects.toBeInstanceOf(FetchError)
  })
})
