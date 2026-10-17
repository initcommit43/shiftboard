import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it } from 'vitest'

import { AssignmentStatus } from '@/api/generated'
import {
  installFakeApi,
  lenaConversation,
  problem,
  warehouse,
} from '@/test/fake-api'
import { renderApp } from '@/test/render'

describe('messages', () => {
  let api: ReturnType<typeof installFakeApi>

  beforeEach(() => {
    api = installFakeApi()
    api.signIn()
  })

  const navigation = () => within(screen.getByRole('navigation', { name: 'Hauptnavigation' }))

  it('lists the conversations with the latest message and unread counts', async () => {
    renderApp('/messages')

    const list = within(await screen.findByRole('navigation', { name: 'Unterhaltungen' }))
    const links = list.getAllByRole('link')
    expect(links.map((it) => within(it).getAllByText(/\w/)[1]?.textContent)).toEqual([
      'Lena Hofer',
      'Jakob Steiner',
    ])
    const lena = within(list.getByRole('link', { name: /Lena Hofer/ }))
    expect(lena.getByText('Gibt es einen Parkplatz?')).toBeInTheDocument()
    expect(lena.getByText('1 ungelesene Nachricht')).toBeInTheDocument()
    expect(within(list.getByRole('link', { name: /Jakob Steiner/ })).getByText('Ihr: Danke!')).toBeInTheDocument()
    expect(await navigation().findByText('1 ungelesene Nachricht')).toBeInTheDocument()
    expect(screen.getByRole('heading', { name: 'Wähle eine Unterhaltung' })).toBeInTheDocument()
  })

  it('opens a conversation, marks it read and shows system messages and broadcasts apart', async () => {
    const user = userEvent.setup()
    renderApp('/messages')

    await user.click(await screen.findByRole('link', { name: /Lena Hofer/ }))

    const thread = within(await screen.findByRole('list', { name: 'Nachrichtenverlauf' }))
    const items = thread.getAllByRole('listitem')
    // Oldest first, as a chat reads.
    expect(items[0]).toHaveTextContent('An alle Bestätigten')
    expect(items[0]).toHaveTextContent('Bitte Sicherheitsschuhe mitbringen.')
    expect(items[1]).toHaveTextContent('Anfrage bestätigt')
    expect(items[2]).toHaveTextContent('Gibt es einen Parkplatz?')
    expect(thread.getByRole('link', { name: /Lagerunterstützung/ })).toHaveAttribute(
      'href',
      `/shifts/${warehouse.id}`,
    )
    expect(screen.getByRole('heading', { name: 'Lena Hofer' })).toBeInTheDocument()
    await waitFor(() => {
      expect(navigation().queryByText(/ungelesene Nachricht/)).not.toBeInTheDocument()
    })
  })

  it('answers a worker', async () => {
    const user = userEvent.setup()
    renderApp(`/messages/${lenaConversation.id}`)

    const reply = await screen.findByLabelText('Antwort')
    expect(screen.getByRole('button', { name: 'Senden' })).toBeDisabled()
    await user.type(reply, 'Ja, hinter Halle 2.')
    await user.click(screen.getByRole('button', { name: 'Senden' }))

    expect(await screen.findByText('Ja, hinter Halle 2.')).toBeInTheDocument()
    expect(reply).toHaveValue('')
    expect(api.calls.find((call) => call.route.startsWith('POST /conversations'))?.body).toEqual({
      body: 'Ja, hinter Halle 2.',
    })
  })

  it('shows an empty state without conversations', async () => {
    api.conversations = []
    renderApp('/messages')

    expect(await screen.findByRole('heading', { name: 'Noch keine Nachrichten' })).toBeInTheDocument()
  })

  it('shows an error and recovers on retry', async () => {
    const user = userEvent.setup()
    api.respondOnce('GET /conversations', problem(500, 'internal_error'))
    renderApp('/messages')

    await user.click(await screen.findByRole('button', { name: 'Erneut versuchen' }))

    expect(await screen.findByRole('link', { name: /Lena Hofer/ })).toBeInTheDocument()
  })
})

describe('broadcast', () => {
  let api: ReturnType<typeof installFakeApi>

  beforeEach(() => {
    api = installFakeApi()
    api.signIn()
  })

  it('messages the confirmed workers of a shift', async () => {
    const user = userEvent.setup()
    renderApp(`/shifts/${warehouse.id}`)

    await user.click(await screen.findByRole('button', { name: 'Nachricht an Bestätigte' }))
    const dialog = within(await screen.findByRole('alertdialog'))
    expect(dialog.getByText(/Die bestätigte Person bekommt die Nachricht/)).toBeInTheDocument()
    await user.type(dialog.getByLabelText('Nachricht'), 'Treffpunkt ist heute Tor 5.')
    await user.click(dialog.getByRole('button', { name: 'Senden' }))

    expect(await screen.findByText('Nachricht an 1 Person gesendet')).toBeInTheDocument()
    expect(api.calls.find((call) => call.route.endsWith('/broadcast'))?.body).toEqual({
      body: 'Treffpunkt ist heute Tor 5.',
    })
  })

  it('is not offered while nobody is confirmed', async () => {
    api.assignments[warehouse.id] = (api.assignments[warehouse.id] ?? []).filter(
      (it) => it.status !== AssignmentStatus.CONFIRMED,
    )
    renderApp(`/shifts/${warehouse.id}`)

    expect(await screen.findByText('Eingeteilt und Verlauf')).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Nachricht an Bestätigte' })).not.toBeInTheDocument()
  })
})
