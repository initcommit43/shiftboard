import type { TFunction } from 'i18next'

function sameDay(a: Date, b: Date) {
  return (
    a.getFullYear() === b.getFullYear() &&
    a.getMonth() === b.getMonth() &&
    a.getDate() === b.getDate()
  )
}

/** The day a shift starts on, such as "Do., 15.10.2026". */
export function formatShiftDate(startsAt: Date, language: string) {
  return new Intl.DateTimeFormat(language, {
    weekday: 'short',
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
  }).format(startsAt)
}

/**
 * Start and end time of a shift, such as "08:00 – ca. 16:00". An end on
 * another day carries its weekday: "22:00 – Fr., 06:00".
 */
export function formatShiftTime(
  t: TFunction,
  language: string,
  { startsAt, endsAt, endIsEstimate }: { startsAt: Date; endsAt: Date; endIsEstimate: boolean },
) {
  const time = new Intl.DateTimeFormat(language, { hour: '2-digit', minute: '2-digit' })
  const endTime = sameDay(startsAt, endsAt)
    ? time.format(endsAt)
    : new Intl.DateTimeFormat(language, {
        weekday: 'short',
        hour: '2-digit',
        minute: '2-digit',
      }).format(endsAt)

  return t('shifts.time.range', {
    start: time.format(startsAt),
    end: endIsEstimate ? t('shifts.time.estimated', { time: endTime }) : endTime,
  })
}
