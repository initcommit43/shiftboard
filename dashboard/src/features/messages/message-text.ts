import type { TFunction } from 'i18next'

import { type Message, MessageType, SystemEvent } from '@/api/generated'

/**
 * The events the dashboard words itself. Any other event shows its body: a shift change,
 * whose body says what changed, and any event newer than the dashboard (ADR 0030).
 */
const EVENT_TEXT = {
  [SystemEvent.CLAIM_CONFIRMED]: 'messages.events.CLAIM_CONFIRMED',
  [SystemEvent.CLAIM_REJECTED]: 'messages.events.CLAIM_REJECTED',
  [SystemEvent.CLAIM_CANCELLED_BY_WORKER]: 'messages.events.CLAIM_CANCELLED_BY_WORKER',
  [SystemEvent.REMOVED_BY_AGENCY]: 'messages.events.REMOVED_BY_AGENCY',
  [SystemEvent.SHIFT_CANCELLED]: 'messages.events.SHIFT_CANCELLED',
  [SystemEvent.WAITLIST_MOVED_UP]: 'messages.events.WAITLIST_MOVED_UP',
  [SystemEvent.WAITLIST_MOVED_UP_CONFIRMED]: 'messages.events.WAITLIST_MOVED_UP_CONFIRMED',
  [SystemEvent.WAITLIST_REMOVED_BY_AGENCY]: 'messages.events.WAITLIST_REMOVED_BY_AGENCY',
  [SystemEvent.WAITLIST_SKIPPED]: 'messages.events.WAITLIST_SKIPPED',
} as const

function isWorded(event: string): event is keyof typeof EVENT_TEXT {
  return Object.hasOwn(EVENT_TEXT, event)
}

/** What a message says: system messages are worded from their event where the dashboard knows it, the rest is their text. */
export function messageText(t: TFunction, message: Message) {
  if (message.type === MessageType.SYSTEM && message.event && isWorded(message.event)) {
    return t(EVENT_TEXT[message.event])
  }
  return message.body
}

/** One line for the inbox, with who wrote it. */
export function messagePreview(t: TFunction, message: Message) {
  const text = messageText(t, message)
  if (message.type === MessageType.SYSTEM) {
    return text
  }
  return message.fromWorker ? text : t('messages.you', { text })
}
