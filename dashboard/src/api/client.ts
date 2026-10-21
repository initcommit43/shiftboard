import { ApiError } from './errors'
import {
  AssignmentsApi,
  AuthApi,
  ClientsApi,
  Configuration,
  MessagesApi,
  type Middleware,
  ProblemFromJSON,
  SettingsApi,
  ShiftsApi,
  WorkersApi,
} from './generated'
import { clearTokens, getAccessToken, getRefreshToken, setTokens } from './tokens'

const sessionExpiredListeners = new Set<() => void>()

/** Calls the listener when the session ended because it could not be refreshed. */
export function onSessionExpired(listener: () => void) {
  sessionExpiredListeners.add(listener)
  return () => {
    sessionExpiredListeners.delete(listener)
  }
}

let refreshing: Promise<boolean> | null = null

/**
 * Exchanges the refresh token for a new token pair. Refresh tokens are single
 * use, so concurrent callers share one request. Resolves to false, with the
 * tokens cleared, when the session cannot be continued.
 */
export function refreshTokens(): Promise<boolean> {
  refreshing ??= exchangeRefreshToken().finally(() => {
    refreshing = null
  })
  return refreshing
}

async function exchangeRefreshToken() {
  const refreshToken = getRefreshToken()
  if (!refreshToken) {
    return false
  }
  try {
    const tokens = await authApi.refreshToken({ refreshTokenRequest: { refreshToken } })
    // A logout while the request was running wins.
    if (getRefreshToken() !== refreshToken) {
      return false
    }
    setTokens(tokens)
    return true
  } catch {
    if (getRefreshToken() === refreshToken) {
      clearTokens()
    }
    return false
  }
}

function isAuthEndpoint(url: string) {
  return new URL(url, window.location.origin).pathname.includes('/auth/')
}

/** On 401, refreshes the tokens once and repeats the request with the new access token. */
const refreshOnUnauthorized: Middleware = {
  async post({ url, init, response }) {
    if (response.status !== 401 || isAuthEndpoint(url)) {
      return undefined
    }
    const headers = new Headers(init.headers)
    const current = getAccessToken()
    // If the token has changed since the request was sent, another request has
    // refreshed already and the new token is reused.
    if (!current || headers.get('Authorization') === `Bearer ${current}`) {
      if (!(await refreshTokens())) {
        sessionExpiredListeners.forEach((listener) => {
          listener()
        })
        return undefined
      }
    }
    const accessToken = getAccessToken()
    if (!accessToken) {
      return undefined
    }
    headers.set('Authorization', `Bearer ${accessToken}`)
    return fetch(url, { ...init, headers })
  },
}

/** Turns every error response into an ApiError that carries the problem code. */
const throwApiError: Middleware = {
  async post({ response }) {
    if (response.ok) {
      return undefined
    }
    const problem = await response
      .json()
      .then((json) => ProblemFromJSON(json))
      .catch(() => undefined)
    throw new ApiError(response.status, problem?.code, problem?.errors)
  },
}

const configuration = new Configuration({
  basePath: import.meta.env.VITE_API_BASE_URL ?? '/api/v1',
  accessToken: () => getAccessToken() ?? '',
  middleware: [refreshOnUnauthorized, throwApiError],
})

export const assignmentsApi = new AssignmentsApi(configuration)
export const authApi = new AuthApi(configuration)
export const clientsApi = new ClientsApi(configuration)
export const messagesApi = new MessagesApi(configuration)
export const settingsApi = new SettingsApi(configuration)
export const shiftsApi = new ShiftsApi(configuration)
export const workersApi = new WorkersApi(configuration)
