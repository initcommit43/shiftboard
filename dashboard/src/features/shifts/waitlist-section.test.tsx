import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it } from 'vitest'

import { AssignmentStatus, ShiftStatus } from '@/api/generated'
import {
  assignment,
  gala,
  installFakeApi,
  inventory,
  jakob,
  problem,
  warehouse,
  worker,
} from '@/test/fake-api'
import { renderApp } from '@/test/render'

const paul = worker(4, 'Paul', 'Gruber', [], new Date(2026, 9, 7, 9, 0))

describe('shift waitlist', () => {
  let api: ReturnType<typeof installFakeApi>

  beforeEach(() => {
    api = installFakeApi()
    api.signIn()
  })

  function waitlist() {
    return within(screen.getByRole('region', { name: 'Warteliste' }))
  }

  function firstInLine() {
    const [first] = waitlist().getAllByRole('row').slice(1)
    if (!first) {
      throw new Error('Nobody is in line')
    }
    return within(first)
  }

  /** The claims load with the shift; once they show, the page has decided on its sections. */
  async function shiftShown() {
    await screen.findByRole('region', { name: /Eingeteilt und Verlauf/ })
  }

  it('shows the line in order with place, name, phone and when they joined', async () => {
    renderApp(`/shifts/${inventory.id}`)

    const line = within(await screen.findByRole('region', { name: 'Warteliste' }))
    const [first, second] = (await line.findAllByRole('row')).slice(1).map((row) => within(row))
    expect(first?.getByText('1.')).toBeInTheDocument()
    expect(first?.getByText('Lena Hofer')).toBeInTheDocument()
    expect(first?.getByText('+43 660 5550101')).toBeInTheDocument()
    expect(first?.getByText('13.10.2026, 08:01')).toBeInTheDocument()
    expect(second?.getByText('2.')).toBeInTheDocument()
    expect(second?.getByText('Mira Aigner')).toBeInTheDocument()

    // First come, first served: taking someone off is the only thing the agency can do.
    expect(line.getAllByRole('button').map((it) => it.getAttribute('aria-label'))).toEqual([
      'Lena Hofer von der Warteliste entfernen',
      'Mira Aigner von der Warteliste entfernen',
    ])
  })

  it('keeps showing who still waits after the agency switched the waitlist off', async () => {
    api.settings = { ...api.settings, waitlist: false }
    renderApp(`/shifts/${inventory.id}`)

    expect(await screen.findByRole('region', { name: 'Warteliste' })).toBeInTheDocument()
    expect(await waitlist().findByText('Lena Hofer')).toBeInTheDocument()
  })

  it('is hidden when the agency has the waitlist off and nobody waits', async () => {
    renderApp(`/shifts/${warehouse.id}`)

    await shiftShown()
    expect(screen.queryByRole('region', { name: 'Warteliste' })).not.toBeInTheDocument()
    expect(api.count(`GET /shifts/${warehouse.id}/waitlist`)).toBe(0)
  })

  it('shows an empty line when the agency uses the waitlist and nobody waits', async () => {
    api.settings = { ...api.settings, waitlist: true }
    renderApp(`/shifts/${warehouse.id}`)

    expect(await screen.findByText(/Niemand wartet/)).toBeInTheDocument()
    expect(waitlist().queryByRole('table')).not.toBeInTheDocument()
  })

  it('has no line for a draft, even with the waitlist on', async () => {
    api.settings = { ...api.settings, waitlist: true }
    renderApp(`/shifts/${gala.id}`)

    await shiftShown()
    expect(gala.status).toBe(ShiftStatus.DRAFT)
    expect(screen.queryByRole('region', { name: 'Warteliste' })).not.toBeInTheDocument()
  })

  it('shows the line loading', async () => {
    api.respondOnce(`GET /shifts/${inventory.id}/waitlist`, new Promise<Response>(() => undefined))
    renderApp(`/shifts/${inventory.id}`)

    expect(await screen.findByRole('status', { name: 'Warteliste wird geladen …' })).toBeInTheDocument()
  })

  it('shows an error and recovers on retry', async () => {
    const user = userEvent.setup()
    api.respondOnce(`GET /shifts/${inventory.id}/waitlist`, problem(500, 'internal_error'))
    renderApp(`/shifts/${inventory.id}`)

    expect(await screen.findByText('Die Warteliste konnte nicht geladen werden.')).toBeInTheDocument()
    await user.click(waitlist().getByRole('button', { name: 'Erneut versuchen' }))

    expect(await waitlist().findByText('Lena Hofer')).toBeInTheDocument()
  })

  it('takes someone off after a confirmation and keeps the order of the others', async () => {
    const user = userEvent.setup()
    const lena = api.waitlists[inventory.id]?.[0]
    renderApp(`/shifts/${inventory.id}`)

    await user.click(
      await screen.findByRole('button', { name: 'Lena Hofer von der Warteliste entfernen' }),
    )
    const dialog = within(await screen.findByRole('alertdialog'))
    expect(dialog.getByText('Lena Hofer von der Warteliste entfernen?')).toBeInTheDocument()
    expect(dialog.getByText(/Lena Hofer bekommt eine Nachricht/)).toBeInTheDocument()
    await user.click(dialog.getByRole('button', { name: 'Entfernen' }))

    expect(await screen.findByText('Lena Hofer ist nicht mehr auf der Warteliste')).toBeInTheDocument()
    await waitFor(() => {
      expect(screen.queryByRole('alertdialog')).not.toBeInTheDocument()
    })
    await waitFor(() => {
      expect(waitlist().queryByText('Lena Hofer')).not.toBeInTheDocument()
    })
    expect(firstInLine().getByText('1.')).toBeInTheDocument()
    expect(firstInLine().getByText('Mira Aigner')).toBeInTheDocument()
    expect(api.count(`DELETE /shifts/${inventory.id}/waitlist/${lena?.id ?? ''}`)).toBe(1)
    // The shift is fetched again, so its counts are fresh.
    expect(api.count(`GET /shifts/${inventory.id}`)).toBe(2)
  })

  it('keeps the worker in line when the removal is cancelled', async () => {
    const user = userEvent.setup()
    renderApp(`/shifts/${inventory.id}`)

    await user.click(
      await screen.findByRole('button', { name: 'Mira Aigner von der Warteliste entfernen' }),
    )
    const dialog = within(await screen.findByRole('alertdialog'))
    await user.click(dialog.getByRole('button', { name: 'Abbrechen' }))

    await waitFor(() => {
      expect(screen.queryByRole('alertdialog')).not.toBeInTheDocument()
    })
    expect(waitlist().getByText('Mira Aigner')).toBeInTheDocument()
    expect(api.calls.some((call) => call.route.startsWith('DELETE'))).toBe(false)
  })

  it('tells when the worker has left the line already and refreshes it', async () => {
    const user = userEvent.setup()
    const lena = api.waitlists[inventory.id]?.[0]
    api.respondOnce(
      `DELETE /shifts/${inventory.id}/waitlist/${lena?.id ?? ''}`,
      problem(404, 'waitlist_entry_not_found'),
    )
    renderApp(`/shifts/${inventory.id}`)

    await user.click(
      await screen.findByRole('button', { name: 'Lena Hofer von der Warteliste entfernen' }),
    )
    await user.click(within(await screen.findByRole('alertdialog')).getByRole('button', { name: 'Entfernen' }))

    expect(
      await screen.findByText(
        'Diese Person ist nicht mehr auf der Warteliste: Sie hat sich ausgetragen oder ist nachgerückt. Die Liste wurde aktualisiert.',
      ),
    ).toBeInTheDocument()
    await waitFor(() => {
      expect(api.count(`GET /shifts/${inventory.id}/waitlist`)).toBe(2)
    })
  })

  it('shows who moved up among the requests when a spot frees up', async () => {
    const user = userEvent.setup()
    api.assignments[inventory.id] = [
      assignment(5, jakob),
      assignment(6, paul, { status: AssignmentStatus.CONFIRMED, decidedAt: new Date(2026, 9, 12, 12, 0) }),
    ]
    renderApp(`/shifts/${inventory.id}`)

    await user.click(await screen.findByRole('button', { name: 'Jakob Steiner ablehnen' }))

    const pending = within(await screen.findByRole('region', { name: /1 offene Anfrage/ }))
    expect(await pending.findByText('Lena Hofer')).toBeInTheDocument()
    await waitFor(() => {
      expect(waitlist().queryByText('Lena Hofer')).not.toBeInTheDocument()
    })
    expect(firstInLine().getByText('1.')).toBeInTheDocument()
    expect(firstInLine().getByText('Mira Aigner')).toBeInTheDocument()
  })
})
