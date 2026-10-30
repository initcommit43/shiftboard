import i18n from 'i18next'
import { describe, expect, it } from 'vitest'

import { ShiftStatus } from '@/api/generated'

import { statusBadge } from './format'

const t = i18n.t.bind(i18n)

describe('statusBadge', () => {
  it('shows a known status with its badge', () => {
    expect(statusBadge(t, ShiftStatus.PUBLISHED)).toEqual({ variant: 'open', label: 'Veröffentlicht' })
  })

  it('shows a status newer than the dashboard as unknown', () => {
    expect(statusBadge(t, 'ARCHIVED' as ShiftStatus)).toEqual({ variant: 'tag', label: 'Unbekannt' })
  })
})
