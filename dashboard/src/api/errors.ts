import type { TFunction } from 'i18next'

import de from '@/i18n/locales/de.json'

import { FetchError } from './generated'

/** An error response of the API, reduced to its status and the problem `code`. */
export class ApiError extends Error {
  override name = 'ApiError'
  readonly status: number
  readonly code: string | undefined

  constructor(status: number, code: string | undefined) {
    super(`API responded with ${String(status)}${code ? ` (${code})` : ''}`)
    this.status = status
    this.code = code
  }
}

type ErrorKey = keyof typeof de.errors

function isErrorKey(code: string | undefined): code is ErrorKey {
  return code !== undefined && code in de.errors
}

/**
 * The localized message for a failed API call. Problem codes map to the
 * `errors.<code>` translations; anything unknown gets the generic message.
 */
export function errorMessage(t: TFunction, error: unknown): string {
  if (error instanceof FetchError) {
    return t('errors.network')
  }
  const code = error instanceof ApiError ? error.code : undefined
  return t(`errors.${isErrorKey(code) ? code : 'unknown'}`)
}
