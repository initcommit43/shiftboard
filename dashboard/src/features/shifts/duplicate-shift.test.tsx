import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it } from 'vitest'

import {
  gala,
  hafenhalle,
  hafenhalleLinz,
  installFakeApi,
  lastWeek,
  nordlicht,
  service,
  umschlaglager,
  warehouse,
} from '@/test/fake-api'
import { renderApp } from '@/test/render'

describe('duplicate a shift', () => {
  let api: ReturnType<typeof installFakeApi>

  beforeEach(() => {
    api = installFakeApi()
    api.signIn()
  })

  const field = (label: string) => screen.findByLabelText<HTMLInputElement>(label)
  const created = () => api.calls.find((call) => call.route === 'POST /shifts')?.body

  it('copies everything but the date and publishes the copy on the chosen day', async () => {
    const { router } = renderApp(`/shifts/${gala.id}`)
    const user = userEvent.setup()

    await user.click(await screen.findByRole('link', { name: 'Duplizieren' }))

    expect(await screen.findByRole('heading', { name: 'Schicht duplizieren' })).toBeInTheDocument()
    expect(await field('Kunde')).toHaveValue(hafenhalle.id)
    expect(await field('Einsatzort')).toHaveValue(hafenhalleLinz.id)
    expect(await field('Titel')).toHaveValue('Servicekraft Gala')
    expect(await field('Datum')).toHaveValue('')
    expect(await field('Beginn')).toHaveValue('18:00')
    expect(await field('Ende')).toHaveValue('01:00')
    expect(await field('Stundenlohn in Euro')).toHaveValue('18,00')
    expect(await field('Plätze')).toHaveValue(4)
    expect(screen.getByRole('checkbox', { name: 'Service' })).toBeChecked()
    expect(screen.queryByRole('alert')).not.toBeInTheDocument()

    await user.click(screen.getByRole('button', { name: 'Veröffentlichen' }))
    expect(await field('Datum')).toHaveAccessibleDescription('Bitte ausfüllen.')
    expect(created()).toBeUndefined()

    await user.type(await field('Datum'), '2026-10-23')
    await user.click(screen.getByRole('button', { name: 'Veröffentlichen' }))

    await waitFor(() => {
      expect(router.state.location.pathname).toBe('/shifts')
    })
    expect(created()).toEqual({
      clientId: hafenhalle.id,
      locationId: hafenhalleLinz.id,
      title: 'Servicekraft Gala',
      startsAt: new Date(2026, 9, 23, 18, 0).toISOString(),
      endsAt: new Date(2026, 9, 24, 1, 0).toISOString(),
      endIsEstimate: false,
      hourlyRateCents: 1800,
      slots: 4,
      qualificationIds: [service.id],
      publish: true,
    })
  })

  it('copies a shift that has already taken place, without its claims', async () => {
    renderApp(`/shifts/new?from=${lastWeek.id}`)

    expect(await field('Titel')).toHaveValue('Messeaufbau')
    expect(await field('Beginn')).toHaveValue('07:00')
    expect(await field('Ende')).toHaveValue('15:00')
    expect(await field('Datum')).toHaveValue('')
  })

  it('leaves out what no longer exists and says so', async () => {
    api.clients = [hafenhalle, { ...nordlicht, locations: [umschlaglager] }]
    api.qualifications = [service]
    renderApp(`/shifts/new?from=${warehouse.id}`)

    expect(await screen.findByRole('alert')).toHaveTextContent(
      'Nicht mehr vorhanden und daher leer: Einsatzort und Erforderliche Qualifikationen. Bitte neu auswählen.',
    )
    expect(await field('Kunde')).toHaveValue(nordlicht.id)
    expect(await field('Einsatzort')).toHaveValue('')
    expect(screen.getByRole('checkbox', { name: 'Service' })).not.toBeChecked()
    expect(await field('Titel')).toHaveValue('Lagerunterstützung')
  })

  it('explains when the shift to copy does not exist', async () => {
    renderApp('/shifts/new?from=0199c3a0-0000-7000-8000-000000000499')

    expect(await screen.findByRole('heading', { name: 'Schicht nicht gefunden' })).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Veröffentlichen' })).not.toBeInTheDocument()
  })

  it('offers duplicating on the detail page of a shift', async () => {
    renderApp('/shifts')
    const user = userEvent.setup()

    await user.click(
      within(await screen.findByRole('row', { name: /Nachtinventur/ })).getByRole('link', {
        name: /Nachtinventur/,
      }),
    )

    expect(await screen.findByRole('link', { name: 'Duplizieren' })).toHaveAttribute(
      'href',
      expect.stringContaining('/shifts/new?from='),
    )
  })
})
