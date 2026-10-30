import userEvent, { type UserEvent } from '@testing-library/user-event'

/**
 * A user for forms with a lot of typing. By default user-event waits for a timer between
 * keystrokes; on a busy machine every wait queues behind other work, and a form that is
 * typed out key by key overruns the test timeout. Without the wait the keystrokes still
 * fire every event, one after the other.
 */
export function typingUser() {
  return userEvent.setup({ delay: null })
}

/**
 * Puts a whole value into an empty field at once, as pasting or autofill would. Typing it
 * key by key fires five events and renders the form once per character; use `user.type`
 * where what happens per key is under test.
 */
export async function enter(user: UserEvent, field: HTMLElement, value: string) {
  await user.click(field)
  await user.paste(value)
}
