import { dateOf } from '@/features/shifts/shift-draft'

const DAY = /^\d{4}-\d{2}-\d{2}$/

/** The calendar month before the one of `now`, as its first and last day (`yyyy-mm-dd`). */
export function lastMonth(now: Date) {
  return {
    from: dateOf(new Date(now.getFullYear(), now.getMonth() - 1, 1)),
    // Day 0 of a month is the last day of the month before.
    to: dateOf(new Date(now.getFullYear(), now.getMonth(), 0)),
  }
}

/**
 * The points in time a period of days spans, in the time zone of the browser: from the start
 * of its first day up to the start of the day after its last. Null when it is not a period.
 */
export function periodRange(from: string, to: string) {
  if (!DAY.test(from) || !DAY.test(to) || to < from) {
    return null
  }
  const end = new Date(`${to}T00:00`)
  end.setDate(end.getDate() + 1)
  return { from: new Date(`${from}T00:00`), to: end }
}
