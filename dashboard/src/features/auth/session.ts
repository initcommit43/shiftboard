import { authApi, onSessionExpired, refreshTokens } from '@/api/client'
import { ClientType, type CurrentUser } from '@/api/generated'
import { clearTokens, getRefreshToken, setTokens } from '@/api/tokens'

let user: CurrentUser | null = null
let restoring: Promise<CurrentUser | null> | null = null

onSessionExpired(() => {
  user = null
})

/**
 * The signed-in user, or null. After a page load the session is restored from
 * the stored refresh token first; concurrent callers share that attempt.
 */
export function loadSession(): Promise<CurrentUser | null> {
  if (user) {
    return Promise.resolve(user)
  }
  restoring ??= restoreSession().finally(() => {
    restoring = null
  })
  return restoring
}

async function restoreSession() {
  if (!(await refreshTokens())) {
    return null
  }
  try {
    user = await authApi.getCurrentUser()
  } catch {
    return null
  }
  return user
}

export async function login(email: string, password: string) {
  const tokens = await authApi.login({
    loginRequest: { email, password, client: ClientType.DASHBOARD },
  })
  setTokens(tokens)
  try {
    user = await authApi.getCurrentUser()
  } catch (error) {
    clearTokens()
    throw error
  }
}

/** Ends the session on this device. Revoking the refresh token on the server is best effort. */
export function logout() {
  const refreshToken = getRefreshToken()
  user = null
  clearTokens()
  if (refreshToken) {
    void authApi.logout({ refreshTokenRequest: { refreshToken } }).catch(() => undefined)
  }
}
