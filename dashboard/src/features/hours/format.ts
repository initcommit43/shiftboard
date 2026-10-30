import type { TFunction } from 'i18next'

import { known } from '@/api/enums'
import { HoursStatus } from '@/api/generated'

/** The badge each hours status is shown with. */
export const HOURS_STATUS_VARIANT = {
  [HoursStatus.OPEN]: 'open',
  [HoursStatus.APPROVED]: 'confirmed',
} as const

/** The badge and label of an hours status; a status newer than the dashboard shows as unknown. */
export function hoursStatusBadge(t: TFunction, value: HoursStatus) {
  const status = known(HoursStatus, value)
  return status
    ? { variant: HOURS_STATUS_VARIANT[status], label: t(`hours.status.${status}`) }
    : { variant: 'tag' as const, label: t('unknownValue') }
}

/** Worked minutes as hours with two decimals, such as "7,50 Std.". */
export function formatHours(t: TFunction, language: string, minutes: number) {
  const hours = new Intl.NumberFormat(language, {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(minutes / 60)
  return t('hours.amount', { hours })
}

/** Euro cents as the dashboard shows money, such as "123,75 €". */
export function formatMoney(language: string, cents: number) {
  return new Intl.NumberFormat(language, { style: 'currency', currency: 'EUR' }).format(cents / 100)
}

/** A time of day, such as "07:55". */
export function formatTime(language: string, date: Date) {
  return new Intl.DateTimeFormat(language, { hour: '2-digit', minute: '2-digit' }).format(date)
}
