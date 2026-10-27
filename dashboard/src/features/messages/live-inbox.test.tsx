import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

import { type ConversationChange } from '@/api/generated'
import {
  installFakeApi,
  jakobConversation,
  lenaConversation,
  message,
  problem,
} from '@/test/fake-api'
import { renderApp } from '@/test/render'

import { RECONNECT_MAX_MS } from './inbox-events'
import { POLL_MS } from './queries'

const EVENTS = 'GET /conversations/events'
const INBOX = 'GET /conversations'

describe('live inbox', () => {
  let api: ReturnType<typeof installFakeApi>

  beforeEach(() => {
    api = installFakeApi()
    api.signIn()
  })

  const navigation = () => within(screen.getByRole('navigation', { name: 'Hauptnavigation' }))
  const conversations = async () =>
    within(await screen.findByRole('navigation', { name: 'Unterhaltungen' }))

  async function streamOpen() {
    await waitFor(() => {
      expect(api.openEventStreams).toBe(1)
    })
  }

  it('moves a conversation with a new message to the top with its unread count', async () => {
    renderApp('/messages')
    expect(await (await conversations()).findByRole('link', { name: /Lena Hofer/ })).toBeInTheDocument()
    await streamOpen()

    api.conversations = [
      { ...jakobConversation, lastMessage: message(20, { body: 'Bin zehn Minuten später da.' }), unreadCount: 2 },
      lenaConversation,
    ]
    api.notify({ conversationId: jakobConversation.id, change: 'MESSAGE' })

    const list = await conversations()
    await waitFor(() => {
      expect(list.getAllByRole('link')[0]).toHaveTextContent('Jakob Steiner')
    })
    const jakob = within(list.getByRole('link', { name: /Jakob Steiner/ }))
    expect(jakob.getByText('Bin zehn Minuten später da.')).toBeInTheDocument()
    expect(jakob.getByText('2 ungelesene Nachrichten')).toBeInTheDocument()
    expect(await navigation().findByText('3 ungelesene Nachrichten')).toBeInTheDocument()
  })

  it('adds a new message to the end of the open conversation', async () => {
    renderApp(`/messages/${lenaConversation.id}`)
    await screen.findByRole('list', { name: 'Nachrichtenverlauf' })
    await streamOpen()

    api.messages[lenaConversation.id] = [
      message(20, { body: 'Ich warte beim Haupteingang.' }),
      ...(api.messages[lenaConversation.id] ?? []),
    ]
    // Changes this build does not know reload like a new message.
    api.notify({ conversationId: lenaConversation.id, change: 'TYPING' as ConversationChange })

    const thread = within(screen.getByRole('list', { name: 'Nachrichtenverlauf' }))
    await waitFor(() => {
      expect(thread.getAllByRole('listitem').at(-1)).toHaveTextContent('Ich warte beim Haupteingang.')
    })
  })

  it('clears the unread count when a colleague reads the conversation', async () => {
    renderApp('/messages')
    const lena = within((await conversations()).getByRole('link', { name: /Lena Hofer/ }))
    expect(lena.getByText('1 ungelesene Nachricht')).toBeInTheDocument()
    expect(await navigation().findByText('1 ungelesene Nachricht')).toBeInTheDocument()
    await streamOpen()

    api.conversations = api.conversations.map((it) => ({ ...it, unreadCount: 0 }))
    api.notify({ conversationId: lenaConversation.id, change: 'READ' })

    await waitFor(() => {
      expect(screen.queryByText(/ungelesene Nachricht/)).not.toBeInTheDocument()
    })
    // A read notice reloads the inbox, not a conversation.
    expect(api.calls.some((call) => call.route.endsWith('/messages'))).toBe(false)
  })

  it('ignores comments and other events', async () => {
    renderApp('/messages')
    await conversations()
    await streamOpen()
    const before = api.count(INBOX)

    api.sendEventText(': ping\n\nevent: other\ndata: {}\n\nevent: conversation\ndata: not json\n\n')
    api.notify({ conversationId: lenaConversation.id, change: 'MESSAGE' })

    await waitFor(() => {
      expect(api.count(INBOX)).toBe(before + 1)
    })
  })

  describe('when the stream is down', () => {
    beforeEach(() => {
      vi.useFakeTimers({ shouldAdvanceTime: true })
    })

    afterEach(() => {
      vi.useRealTimers()
    })

    it('polls the inbox until the stream is back, then stops polling', async () => {
      // Attempts at 0, 1, 3, 7 and 15 seconds fail; the one at 31 seconds connects.
      for (let attempt = 0; attempt < 5; attempt++) {
        api.respondOnce(EVENTS, problem(503, 'unavailable'))
      }
      renderApp('/messages')
      await conversations()
      const loaded = api.count(INBOX)

      await vi.advanceTimersByTimeAsync(POLL_MS + 500)
      await waitFor(() => {
        expect(api.count(INBOX)).toBe(loaded + 1)
      })
      expect(api.count(EVENTS)).toBe(5)

      await vi.advanceTimersByTimeAsync(16_000)
      await streamOpen()
      const live = api.count(INBOX)
      await vi.advanceTimersByTimeAsync(2 * POLL_MS)
      expect(api.count(INBOX)).toBe(live)
    })

    it('reconnects with growing pauses after the stream drops and reloads the inbox', async () => {
      renderApp('/messages')
      await conversations()
      await streamOpen()
      const loaded = api.count(INBOX)
      api.respondOnce(EVENTS, new TypeError('network error'))
      api.respondOnce(EVENTS, problem(502, 'bad_gateway'))

      // Attempts 1, 3 and 7 seconds after the drop; the timer also runs with real time, hence the margins.
      api.dropEventStreams()
      await vi.advanceTimersByTimeAsync(500)
      expect(api.count(EVENTS)).toBe(1)
      await vi.advanceTimersByTimeAsync(1_000)
      expect(api.count(EVENTS)).toBe(2)
      await vi.advanceTimersByTimeAsync(1_000)
      expect(api.count(EVENTS)).toBe(2)
      await vi.advanceTimersByTimeAsync(1_000)
      expect(api.count(EVENTS)).toBe(3)
      await vi.advanceTimersByTimeAsync(3_000)
      expect(api.count(EVENTS)).toBe(3)
      await vi.advanceTimersByTimeAsync(1_000)
      await streamOpen()
      expect(api.count(EVENTS)).toBe(4)

      // Notices sent while it was down are lost, so the inbox reloads.
      await waitFor(() => {
        expect(api.count(INBOX)).toBe(loaded + 1)
      })
    })

    it('waits at most the cap between attempts', async () => {
      for (let attempt = 0; attempt < 10; attempt++) {
        api.respondOnce(EVENTS, problem(503, 'unavailable'))
      }
      renderApp('/messages')
      await conversations()

      // 1 + 2 + 4 + 8 + 16 seconds, then the cap; with margins, as the timer also runs with real time.
      await vi.advanceTimersByTimeAsync(31_500)
      expect(api.count(EVENTS)).toBe(6)
      await vi.advanceTimersByTimeAsync(RECONNECT_MAX_MS - 1_000)
      expect(api.count(EVENTS)).toBe(6)
      await vi.advanceTimersByTimeAsync(1_000)
      expect(api.count(EVENTS)).toBe(7)
    })

    it('refreshes an expired token and reconnects', async () => {
      renderApp('/messages')
      await conversations()
      await streamOpen()
      const refreshes = api.count('POST /auth/refresh')

      api.expireAccessToken()
      api.dropEventStreams()
      await vi.advanceTimersByTimeAsync(1_000)

      await streamOpen()
      expect(api.count('POST /auth/refresh')).toBe(refreshes + 1)
      expect(api.count(EVENTS)).toBe(3)
    })

    it('stops trying when the stream is forbidden and keeps polling', async () => {
      api.respondOnce(EVENTS, problem(403, 'forbidden'))
      renderApp('/messages')
      await conversations()
      const loaded = api.count(INBOX)

      await vi.advanceTimersByTimeAsync(4 * POLL_MS)

      expect(api.count(EVENTS)).toBe(1)
      await waitFor(() => {
        expect(api.count(INBOX)).toBe(loaded + 4)
      })
    })
  })

  it('closes the stream on logout', async () => {
    const user = userEvent.setup()
    renderApp('/messages')
    await conversations()
    await streamOpen()

    await user.click(screen.getByRole('button', { name: 'Benutzermenü' }))
    await user.click(await screen.findByRole('menuitem', { name: 'Abmelden' }))
    expect(await screen.findByRole('heading', { name: 'Anmelden' })).toBeInTheDocument()

    await waitFor(() => {
      expect(api.openEventStreams).toBe(0)
    })
  })
})
