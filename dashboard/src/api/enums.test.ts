import { describe, expect, it } from 'vitest'

import { known } from './enums'
import { ShiftStatus } from './generated'

describe('known', () => {
  it('passes values this build knows', () => {
    expect(known(ShiftStatus, ShiftStatus.PUBLISHED)).toBe(ShiftStatus.PUBLISHED)
  })

  it('turns values newer than this build into undefined', () => {
    // The generated client passes values it does not know through as they are.
    expect(known(ShiftStatus, 'ARCHIVED')).toBeUndefined()
    expect(known(ShiftStatus, ShiftStatus.unknown_default_open_api)).toBeUndefined()
    expect(known(ShiftStatus, undefined)).toBeUndefined()
  })
})
