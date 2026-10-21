import { describe, expect, it } from 'vitest'

import { lastMonth, periodRange } from './period'

describe('hours period', () => {
  it('defaults to the last calendar month, also across the turn of the year', () => {
    expect(lastMonth(new Date(2026, 9, 21))).toEqual({ from: '2026-09-01', to: '2026-09-30' })
    expect(lastMonth(new Date(2027, 0, 5))).toEqual({ from: '2026-12-01', to: '2026-12-31' })
    expect(lastMonth(new Date(2028, 2, 31))).toEqual({ from: '2028-02-01', to: '2028-02-29' })
  })

  it('spans from the start of the first day to the start of the day after the last', () => {
    expect(periodRange('2026-09-01', '2026-09-30')).toEqual({
      from: new Date(2026, 8, 1),
      to: new Date(2026, 9, 1),
    })
    expect(periodRange('2026-09-15', '2026-09-15')).toEqual({
      from: new Date(2026, 8, 15),
      to: new Date(2026, 8, 16),
    })
  })

  it('is no period when a day is missing or the end is before the start', () => {
    expect(periodRange('', '2026-09-30')).toBeNull()
    expect(periodRange('2026-09-30', '2026-09-01')).toBeNull()
    expect(periodRange('gestern', '2026-09-30')).toBeNull()
  })
})
