import type { TFunction } from 'i18next'

import de from '@/i18n/locales/de.json'

import { type FieldError, FetchError } from './generated'

/**
 * An error response of the API, reduced to its status, the problem `code` and
 * the field errors of a `validation_failed`.
 */
export class ApiError extends Error {
  override name = 'ApiError'
  readonly status: number
  readonly code: string | undefined
  readonly fieldErrors: FieldError[]

  constructor(status: number, code: string | undefined, fieldErrors: FieldError[] = []) {
    super(`API responded with ${String(status)}${code ? ` (${code})` : ''}`)
    this.status = status
    this.code = code
    this.fieldErrors = fieldErrors
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
