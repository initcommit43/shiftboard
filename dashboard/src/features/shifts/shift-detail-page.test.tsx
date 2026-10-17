import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it } from 'vitest'

import { AssignmentStatus } from '@/api/generated'
import { gala, installFakeApi, lastWeek, problem, warehouse } from '@/test/fake-api'
import { renderApp } from '@/test/render'

describe('shift detail', () => {
  let api: ReturnType<typeof installFakeApi>

  beforeEach(() => {
    api = installFakeApi()
    api.signIn()
  })

  function section(name: RegExp) {
    return within(screen.getByRole('region', { name }))
  }

  it('opens from the list and shows the shift with its facts', async () => {
    const user = userEvent.setup()
    renderApp('/shifts')

    await user.click(await screen.findByRole('link', { name: 'Lagerunterstützung' }))

    expect(await screen.findByRole('heading', { name: 'Lagerunterstützung', level: 1 })).toBeInTheDocument()
    expect(screen.getByText('Nordlicht Logistik · Zentrallager Linz, Industriezeile 40, 4020 Linz')).toBeInTheDocument()
    expect(screen.getByText('08:00 – ca. 16:00')).toBeInTheDocument()
    expect(screen.getByText('2 von 5')).toBeInTheDocument()
    expect(screen.getByText('16,50 €')).toBeInTheDocument()
  })

  it('lists pending requests oldest first and everyone else with what became of them', async () => {
    renderApp(`/shifts/${warehouse.id}`)

    const pending = within(await screen.findByRole('region', { name: /1 offene Anfrage/ }))
    expect(pending.getByText('Lena Hofer')).toBeInTheDocument()
    expect(pending.getByText('+43 660 5550101')).toBeInTheDocument()
    expect(pending.getByRole('button', { name: 'Lena Hofer bestätigen' })).toBeEnabled()
    expect(pending.getByRole('button', { name: 'Lena Hofer ablehnen' })).toBeEnabled()

    const team = section(/Eingeteilt und Verlauf/)
    const jakob = within(team.getByRole('row', { name: /Jakob Steiner/ }))
    expect(jakob.getByText('Bestätigt')).toBeInTheDocument()
    expect(jakob.getByRole('button', { name: 'Jakob Steiner entfernen' })).toBeInTheDocument()
    const mira = within(team.getByRole('row', { name: /Mira Aigner/ }))
    expect(mira.getByText('Entfernt')).toBeInTheDocument()
    expect(mira.getByText('Grund: Doppelt gebucht')).toBeInTheDocument()
    expect(mira.queryByRole('button')).not.toBeInTheDocument()
  })

  it('shows empty states when nobody has claimed the shift', async () => {
    renderApp(`/shifts/${gala.id}`)

    expect(await screen.findByText(/Keine offenen Anfragen/)).toBeInTheDocument()
    expect(screen.getByText('Noch niemand eingeteilt.')).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Veröffentlichen' })).toBeInTheDocument()
  })

  it('approves a request and moves it to the team', async () => {
    const user = userEvent.setup()
    renderApp(`/shifts/${warehouse.id}`)

    await user.click(await screen.findByRole('button', { name: 'Lena Hofer bestätigen' }))

    expect(await screen.findByText('Lena Hofer ist bestätigt')).toBeInTheDocument()
    await waitFor(() => {
      expect(screen.getByRole('region', { name: 'Offene Anfragen' })).toBeInTheDocument()
    })
    expect(within(section(/Eingeteilt/).getByRole('row', { name: /Lena Hofer/ })).getByText('Bestätigt'))
      .toBeInTheDocument()
  })

  it('rejects a request and frees the spot', async () => {
    const user = userEvent.setup()
    renderApp(`/shifts/${warehouse.id}`)

    await user.click(await screen.findByRole('button', { name: 'Lena Hofer ablehnen' }))

    expect(await screen.findByText('Die Anfrage von Lena Hofer wurde abgelehnt')).toBeInTheDocument()
    expect(await screen.findByText('1 von 5')).toBeInTheDocument()
    expect(api.count(`POST /shifts/${warehouse.id}/assignments/${api.assignments[warehouse.id]?.[0]?.id ?? ''}/reject`))
      .toBe(1)
  })

  it('tells when a colleague decided first and refreshes the list', async () => {
    const user = userEvent.setup()
    const lena = api.assignments[warehouse.id]?.[0]
    api.respondOnce(
      `POST /shifts/${warehouse.id}/assignments/${lena?.id ?? ''}/approve`,
      problem(409, 'assignment_not_pending'),
    )
    renderApp(`/shifts/${warehouse.id}`)

    await user.click(await screen.findByRole('button', { name: 'Lena Hofer bestätigen' }))

    expect(
      await screen.findByText('Über diese Anfrage wurde bereits entschieden. Die Liste wurde aktualisiert.'),
    ).toBeInTheDocument()
    expect(api.count(`GET /shifts/${warehouse.id}/assignments`)).toBe(2)
  })

  it('removes a confirmed worker only with a reason', async () => {
    const user = userEvent.setup()
    renderApp(`/shifts/${warehouse.id}`)

    await user.click(await screen.findByRole('button', { name: 'Jakob Steiner entfernen' }))
    const dialog = within(await screen.findByRole('alertdialog'))
    await user.click(dialog.getByRole('button', { name: 'Entfernen' }))

    expect(dialog.getByText('Bitte gib einen Grund an.')).toBeInTheDocument()
    expect(dialog.getByLabelText('Grund')).toHaveFocus()

    await user.type(dialog.getByLabelText('Grund'), 'Kann laut Rücksprache nicht kommen')
    await user.click(dialog.getByRole('button', { name: 'Entfernen' }))

    expect(await screen.findByText('Jakob Steiner wurde aus der Schicht entfernt')).toBeInTheDocument()
    await waitFor(() => {
      expect(screen.queryByRole('alertdialog')).not.toBeInTheDocument()
    })
    const jakob = within(section(/Eingeteilt/).getByRole('row', { name: /Jakob Steiner/ }))
    expect(await jakob.findByText('Grund: Kann laut Rücksprache nicht kommen')).toBeInTheDocument()
  })

  it('cancels the whole shift after a confirmation', async () => {
    const user = userEvent.setup()
    // Only a shift that has not ended can be called off.
    api.shifts = api.shifts.map((it) =>
      it.id === warehouse.id
        ? { ...it, startsAt: new Date(2099, 0, 5, 8, 0), endsAt: new Date(2099, 0, 5, 16, 0) }
        : it,
    )
    renderApp(`/shifts/${warehouse.id}`)

    await user.click(await screen.findByRole('button', { name: 'Schicht absagen' }))
    const dialog = within(await screen.findByRole('alertdialog'))
    expect(dialog.getByText(/Alle 2 Personen mit Platz werden mit abgesagt/)).toBeInTheDocument()
    await user.click(dialog.getByRole('button', { name: 'Absagen' }))

    expect(await screen.findByText('Lagerunterstützung wurde abgesagt')).toBeInTheDocument()
    await waitFor(() => {
      expect(screen.queryByRole('button', { name: 'Schicht absagen' })).not.toBeInTheDocument()
    })
    expect(screen.getByText('Abgesagt')).toBeInTheDocument()
    expect(api.assignments[warehouse.id]?.map((it) => it.status)).toEqual([
      AssignmentStatus.CANCELLED,
      AssignmentStatus.CANCELLED,
      AssignmentStatus.CANCELLED,
    ])
  })

  it('marks a worker of a past shift as no-show', async () => {
    const user = userEvent.setup()
    renderApp(`/shifts/${lastWeek.id}`)

    expect(await screen.findByText('Gearbeitet')).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Schicht absagen' })).not.toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Jakob Steiner als nicht erschienen markieren' }))

    expect(await screen.findByText('Jakob Steiner ist als nicht erschienen markiert')).toBeInTheDocument()
    expect(await screen.findAllByText('Nicht erschienen')).not.toHaveLength(0)
  })

  it('says when the shift does not exist', async () => {
    renderApp('/shifts/0199c3a0-0000-7000-8000-000000000999')

    expect(await screen.findByRole('heading', { name: 'Schicht nicht gefunden' })).toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Alle Schichten' })).toHaveAttribute('href', '/shifts')
  })
})
