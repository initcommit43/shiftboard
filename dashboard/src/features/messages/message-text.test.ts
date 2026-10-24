import i18n from 'i18next'
import { describe, expect, it } from 'vitest'

import { MessageType, type SystemEvent } from '@/api/generated'
import { message } from '@/test/fake-api'

import { messagePreview, messageText } from './message-text'

const t = i18n.t.bind(i18n)

function system(event: SystemEvent | undefined, body: string) {
  return message(1, { type: MessageType.SYSTEM, fromWorker: false, body, ...(event && { event }) })
}

describe('messageText', () => {
  it('words the events the dashboard knows', () => {
    expect(messageText(t, system('CLAIM_CONFIRMED', 'Deine Schicht „Lager“ ist bestätigt.'))).toBe(
      'Anfrage bestätigt',
    )
  })

  it('words the waitlist events', () => {
    expect(messageText(t, system('WAITLIST_MOVED_UP_CONFIRMED', 'Du bist nachgerückt.'))).toBe(
      'Von der Warteliste nachgerückt und bestätigt',
    )
  })

  it('shows the body of a shift change, which says what changed', () => {
    const body = 'Die Agentur hat „Service Bankett“ geändert. Zeit: Mi., 7. Jan., 08:00 – ca. 16:00.'
    expect(messageText(t, system('SHIFT_CHANGED', body))).toBe(body)
  })

  it('shows the body of an event newer than the dashboard', () => {
    // The generated client passes event values it does not know through as they are.
    const newer = system('SHIFT_SWAPPED' as SystemEvent, 'Die Agentur hat deine Schicht getauscht.')
    expect(messageText(t, newer)).toBe('Die Agentur hat deine Schicht getauscht.')
    expect(messagePreview(t, newer)).toBe('Die Agentur hat deine Schicht getauscht.')
  })

  it('shows the body of a system message without an event', () => {
    expect(messageText(t, system(undefined, 'Etwas ist passiert.'))).toBe('Etwas ist passiert.')
  })
})
