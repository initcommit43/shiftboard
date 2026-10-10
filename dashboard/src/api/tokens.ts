import type { TokenResponse } from './generated'

const STORAGE_KEY = 'shiftboard.refreshToken'

// The access token lives in memory only. The refresh token is kept in
// localStorage so that a reload does not end the session.
let accessToken: string | null = null

export function getAccessToken() {
  return accessToken
}

export function getRefreshToken() {
  return localStorage.getItem(STORAGE_KEY)
}

export function setTokens(tokens: TokenResponse) {
  accessToken = tokens.accessToken
  localStorage.setItem(STORAGE_KEY, tokens.refreshToken)
}

export function clearTokens() {
  accessToken = null
  localStorage.removeItem(STORAGE_KEY)
}
