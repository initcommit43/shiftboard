import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it } from 'vitest'

import { gala, installFakeApi, problem, shift } from '@/test/fake-api'
import { renderApp } from '@/test/render'

describe('upcoming shifts', () => {
  let api: ReturnType<typeof installFakeApi>

  beforeEach(() => {
    api = installFakeApi()
    api.signIn()
  })

  function row(title: string) {
    return within(screen.getByRole('row', { name: new RegExp(title) }))
  }

  it('shows a loading state while the list is fetched', async () => {
    api.respondOnce('GET /shifts', new Promise<Response>(() => undefined))
    renderApp('/shifts')

    expect(
      await screen.findByRole('status', { name: 'Schichten werden geladen …' }),
    ).toBeInTheDocument()
  })

  it('lists the shifts with client, location, time, status and taken spots', async () => {
    renderApp('/shifts')

    const warehouse = within(await screen.findByRole('row', { name: /Lagerunterstützung/ }))
    expect(warehouse.getByText('Nordlicht Logistik')).toBeInTheDocument()
    expect(warehouse.getByText('Zentrallager Linz')).toBeInTheDocument()
    expect(warehouse.getByText('Do., 15.10.2026')).toBeInTheDocument()
    expect(warehouse.getByText('08:00 – ca. 16:00')).toBeInTheDocument()
    expect(warehouse.getByText('Veröffentlicht')).toBeInTheDocument()
    expect(warehouse.getByText('2 von 5')).toBeInTheDocument()
    expect(warehouse.queryByText('Voll')).not.toBeInTheDocument()
    expect(warehouse.queryByRole('button')).not.toBeInTheDocument()

    // A draft is told apart by its status and can be published; an end on the next day names its weekday.
    expect(row('Servicekraft Gala').getByText('Entwurf')).toBeInTheDocument()
    expect(row('Servicekraft Gala').getByText('18:00 – Sa., 01:00')).toBeInTheDocument()
    expect(row('Servicekraft Gala').getByText('0 von 4')).toBeInTheDocument()
    expect(row('Servicekraft Gala').getByRole('button', { name: /veröffentlichen/ })).toBeEnabled()

    expect(row('Nachtinventur').getByText('2 von 2')).toBeInTheDocument()
    expect(row('Nachtinventur').getByText('Voll')).toBeInTheDocument()

    // The API sorts by start time; the list keeps that order.
    expect(
      screen
        .getAllByRole('row')
        .slice(1)
        .map((it) => within(it).getAllByRole('cell')[0]?.textContent),
    ).toEqual(['Lagerunterstützung', 'Servicekraft Gala', 'Nachtinventur'])
    expect(screen.getByText('3 anstehende Schichten')).toBeInTheDocument()
    expect(screen.queryByRole('navigation', { name: 'Seiten' })).not.toBeInTheDocument()
  })

  it('shows an empty state when nothing is coming up', async () => {
    api.shifts = []
    renderApp('/shifts')

    expect(
      await screen.findByRole('heading', { name: 'Keine anstehenden Schichten' }),
    ).toBeInTheDocument()
    expect(screen.queryByRole('table')).not.toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Neue Schicht' })).toHaveAttribute(
      'href',
      '/shifts/new',
    )
  })

  it('shows an error and recovers on retry', async () => {
    api.respondOnce('GET /shifts', problem(500, 'internal_error'))
    renderApp('/shifts')

    expect(
      await screen.findByRole('heading', { name: 'Schichten konnten nicht geladen werden' }),
    ).toBeInTheDocument()

    await userEvent.click(screen.getByRole('button', { name: 'Erneut versuchen' }))

    expect(await screen.findByRole('row', { name: /Lagerunterstützung/ })).toBeInTheDocument()
  })

  it('publishes a draft from the list', async () => {
    renderApp('/shifts')

    await userEvent.click(
      await screen.findByRole('button', { name: 'Servicekraft Gala veröffentlichen' }),
    )

    expect(await screen.findByText('Servicekraft Gala wurde veröffentlicht')).toBeInTheDocument()
    await waitFor(() => {
      expect(row('Servicekraft Gala').getByText('Veröffentlicht')).toBeInTheDocument()
    })
    expect(row('Servicekraft Gala').queryByRole('button')).not.toBeInTheDocument()
    expect(api.count(`POST /shifts/${gala.id}/publish`)).toBe(1)
  })

  it('refreshes the list when someone else has already published the draft', async () => {
    renderApp('/shifts')
    const publish = await screen.findByRole('button', {
      name: 'Servicekraft Gala veröffentlichen',
    })
    api.shifts = api.shifts.map((it) => (it === gala ? { ...gala, status: 'PUBLISHED' } : it))

    await userEvent.click(publish)

    expect(
      await screen.findByText('Diese Schicht ist kein Entwurf mehr. Die Liste wurde aktualisiert.'),
    ).toBeInTheDocument()
    await waitFor(() => {
      expect(row('Servicekraft Gala').getByText('Veröffentlicht')).toBeInTheDocument()
    })
  })

  it('pages through more shifts than fit on one page', async () => {
    api.shifts = Array.from({ length: 21 }, (_, index) =>
      shift(index + 1, { title: `Schicht ${String(index + 1)}` }),
    )
    renderApp('/shifts')

    const pages = within(await screen.findByRole('navigation', { name: 'Seiten' }))
    expect(pages.getByText('Seite 1 von 2')).toBeInTheDocument()

    await userEvent.click(pages.getByRole('button', { name: 'Weiter' }))

    expect(await screen.findByRole('row', { name: /Schicht 21/ })).toBeInTheDocument()
    expect(screen.getAllByRole('row')).toHaveLength(2)
  })
})
