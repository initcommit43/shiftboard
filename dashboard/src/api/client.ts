import { ApiError } from './errors'
import {
  AssignmentsApi,
  AuthApi,
  ClientsApi,
  Configuration,
  HoursApi,
  MessagesApi,
  type Middleware,
  ProblemFromJSON,
  SettingsApi,
  ShiftsApi,
  ShiftTemplatesApi,
  WaitlistApi,
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

/**
 * After a 401 for a request sent with the given Authorization header: refreshes
 * the tokens, unless another request has refreshed them since, and tells the
 * session-expired listeners when the session cannot be continued. Resolves to
 * true when there is an access token to repeat the request with.
 */
export async function renewAccessToken(sentAuthorization: string | null): Promise<boolean> {
  const current = getAccessToken()
  if (!current || sentAuthorization === `Bearer ${current}`) {
    if (!(await refreshTokens())) {
      sessionExpiredListeners.forEach((listener) => {
        listener()
      })
      return false
    }
  }
  return getAccessToken() !== null
}

/** On 401, refreshes the tokens once and repeats the request with the new access token. */
const refreshOnUnauthorized: Middleware = {
  async post({ url, init, response }) {
    if (response.status !== 401 || isAuthEndpoint(url)) {
      return undefined
    }
    const headers = new Headers(init.headers)
    if (!(await renewAccessToken(headers.get('Authorization')))) {
      return undefined
    }
    headers.set('Authorization', `Bearer ${getAccessToken() ?? ''}`)
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

/** Where the API lives, for requests the generated client cannot make, such as event streams. */
export const apiBasePath = import.meta.env.VITE_API_BASE_URL ?? '/api/v1'

const configuration = new Configuration({
  basePath: apiBasePath,
  accessToken: () => getAccessToken() ?? '',
  middleware: [refreshOnUnauthorized, throwApiError],
})

export const assignmentsApi = new AssignmentsApi(configuration)
export const authApi = new AuthApi(configuration)
export const clientsApi = new ClientsApi(configuration)
export const hoursApi = new HoursApi(configuration)
export const messagesApi = new MessagesApi(configuration)
export const settingsApi = new SettingsApi(configuration)
export const shiftsApi = new ShiftsApi(configuration)
export const shiftTemplatesApi = new ShiftTemplatesApi(configuration)
export const waitlistApi = new WaitlistApi(configuration)
export const workersApi = new WorkersApi(configuration)
