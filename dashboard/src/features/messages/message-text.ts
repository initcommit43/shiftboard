import type { TFunction } from 'i18next'

import { type Message, MessageType } from '@/api/generated'

/** What a message says: system messages are worded from their event, the rest is their text. */
export function messageText(t: TFunction, message: Message) {
  if (message.type === MessageType.SYSTEM && message.event) {
    return t(`messages.events.${message.event}`)
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
