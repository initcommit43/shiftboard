import { screen, waitFor, within } from '@testing-library/react'
import userEvent, { type UserEvent } from '@testing-library/user-event'
import { beforeEach, describe, expect, it } from 'vitest'

import {
  forklift,
  hafenhalle,
  installFakeApi,
  nordlicht,
  problem,
  zentrallager,
} from '@/test/fake-api'
import { renderApp } from '@/test/render'

describe('new shift', () => {
  let api: ReturnType<typeof installFakeApi>

  beforeEach(() => {
    api = installFakeApi()
    api.signIn()
  })

  const field = (label: string) => screen.findByLabelText<HTMLInputElement>(label)

  /** Fills in everything a shift needs, for Nordlicht Logistik at the Zentrallager. */
  async function fillIn(user: UserEvent) {
    await user.selectOptions(await field('Kunde'), 'Nordlicht Logistik')
    await user.selectOptions(await field('Einsatzort'), 'Zentrallager Linz')
    await user.type(await field('Titel'), 'Lagerunterstützung')
    await user.type(await field('Datum'), '2026-10-20')
    await user.type(await field('Beginn'), '08:00')
    await user.type(await field('Ende'), '16:30')
    await user.type(await field('Stundenlohn in Euro'), '16,50')
  }

  const created = () => api.calls.find((call) => call.route === 'POST /shifts')?.body

  it('creates and publishes a shift, then shows it in the list', async () => {
    const { router } = renderApp('/shifts')
    const user = userEvent.setup()

    await user.click(await screen.findByRole('link', { name: 'Neue Schicht' }))
    await fillIn(user)
    await user.type(await field('Beschreibung'), 'Sicherheitsschuhe mitbringen.')
    await user.click(screen.getByRole('checkbox', { name: /geschätzt/ }))
    await user.clear(await field('Plätze'))
    await user.type(await field('Plätze'), '3')
    await user.click(screen.getByRole('checkbox', { name: 'Staplerschein' }))
    await user.click(screen.getByRole('button', { name: 'Veröffentlichen' }))

    expect(await screen.findByText('Lagerunterstützung wurde veröffentlicht')).toBeInTheDocument()
    expect(created()).toEqual({
      clientId: nordlicht.id,
      locationId: zentrallager.id,
      title: 'Lagerunterstützung',
      description: 'Sicherheitsschuhe mitbringen.',
      startsAt: new Date(2026, 9, 20, 8, 0).toISOString(),
      endsAt: new Date(2026, 9, 20, 16, 30).toISOString(),
      endIsEstimate: true,
      hourlyRateCents: 1650,
      slots: 3,
      qualificationIds: [forklift.id],
      publish: true,
    })

    await waitFor(() => {
      expect(router.state.location.pathname).toBe('/shifts')
    })
    const row = within(await screen.findByRole('row', { name: /Di\., 20\.10\.2026/ }))
    expect(row.getByText('08:00 – ca. 16:30')).toBeInTheDocument()
    expect(row.getByText('Veröffentlicht')).toBeInTheDocument()
    expect(row.getByText('0 von 3')).toBeInTheDocument()
  })

  it('saves a shift as a draft without publishing it', async () => {
    const { router } = renderApp('/shifts/new')
    const user = userEvent.setup()

    await fillIn(user)
    await user.click(screen.getByRole('button', { name: 'Als Entwurf speichern' }))

    expect(
      await screen.findByText('Lagerunterstützung wurde als Entwurf gespeichert'),
    ).toBeInTheDocument()
    expect(created()).toMatchObject({ publish: false, slots: 1, qualificationIds: [] })
    expect(created()).not.toHaveProperty('description')
    await waitFor(() => {
      expect(router.state.location.pathname).toBe('/shifts')
    })
    expect(
      within(await screen.findByRole('row', { name: /Di\., 20\.10\.2026/ })).getByText('Entwurf'),
    ).toBeInTheDocument()
  })

  it('offers the locations of the chosen client and picks a sole one', async () => {
    renderApp('/shifts/new')
    const user = userEvent.setup()

    const location = await field('Einsatzort')
    expect(location).toBeDisabled()

    await user.selectOptions(await field('Kunde'), 'Nordlicht Logistik')
    expect(within(location).getAllByRole('option').map((it) => it.textContent)).toEqual([
      'Bitte wählen',
      'Umschlaglager Wels',
      'Zentrallager Linz',
    ])
    await user.selectOptions(location, 'Zentrallager Linz')
    expect(screen.getByText('Industriezeile 40, 4020 Linz')).toBeInTheDocument()

    await user.selectOptions(await field('Kunde'), 'Hafenhalle Events')
    expect(location).toHaveValue(hafenhalle.locations[0]?.id)
    expect(screen.getByText('Hafenstraße 9, 4020 Linz')).toBeInTheDocument()
  })

  it('names what is missing and sends nothing', async () => {
    renderApp('/shifts/new')
    const user = userEvent.setup()

    await user.clear(await field('Plätze'))
    await user.click(screen.getByRole('button', { name: 'Veröffentlichen' }))

    for (const label of [
      'Kunde',
      'Einsatzort',
      'Titel',
      'Datum',
      'Beginn',
      'Ende',
      'Stundenlohn in Euro',
      'Plätze',
    ]) {
      expect(await field(label)).toHaveAccessibleDescription('Bitte ausfüllen.')
      expect(await field(label)).toBeInvalid()
    }
    expect(await field('Kunde')).toHaveFocus()
    expect(created()).toBeUndefined()

    // Correcting a field clears its message.
    await user.type(await field('Titel'), 'Lagerunterstützung')
    expect(await field('Titel')).toBeValid()
  })

  it('rejects a rate of zero, no spots and an end at the start', async () => {
    renderApp('/shifts/new')
    const user = userEvent.setup()

    await fillIn(user)
    await user.clear(await field('Stundenlohn in Euro'))
    await user.type(await field('Stundenlohn in Euro'), '0')
    await user.clear(await field('Plätze'))
    await user.type(await field('Plätze'), '0')
    await user.clear(await field('Ende'))
    await user.type(await field('Ende'), '08:00')
    await user.click(screen.getByRole('button', { name: 'Als Entwurf speichern' }))

    expect(await field('Ende')).toHaveAccessibleDescription('Das Ende muss nach dem Beginn liegen.')
    expect(await field('Stundenlohn in Euro')).toHaveAccessibleDescription(
      'Der Stundenlohn muss über 0 € liegen.',
    )
    expect(await field('Plätze')).toHaveAccessibleDescription('Zwischen 1 und 500 Plätze.')
    expect(await field('Ende')).toHaveFocus()

    await user.clear(await field('Stundenlohn in Euro'))
    await user.type(await field('Stundenlohn in Euro'), 'viel')
    await user.click(screen.getByRole('button', { name: 'Als Entwurf speichern' }))

    expect(await field('Stundenlohn in Euro')).toHaveAccessibleDescription(
      'Das Format stimmt nicht.',
    )
    expect(created()).toBeUndefined()
  })

  it('treats an end before the start as the next day', async () => {
    renderApp('/shifts/new')
    const user = userEvent.setup()

    await fillIn(user)
    await user.clear(await field('Beginn'))
    await user.type(await field('Beginn'), '22:00')
    await user.clear(await field('Ende'))
    await user.type(await field('Ende'), '06:00')

    expect(await field('Ende')).toHaveAccessibleDescription(
      'Endet am Folgetag, Mi., 21.10.2026.',
    )

    await user.click(screen.getByRole('button', { name: 'Veröffentlichen' }))

    await waitFor(() => {
      expect(created()).toMatchObject({
        startsAt: new Date(2026, 9, 20, 22, 0).toISOString(),
        endsAt: new Date(2026, 9, 21, 6, 0).toISOString(),
      })
    })
  })

  it('shows what the server rejects on the field', async () => {
    api.respondOnce(
      'POST /shifts',
      problem(400, 'validation_failed', [
        { field: 'locationId', code: 'not_found' },
        { field: 'endsAt', code: 'before_start' },
        { field: 'hourlyRateCents', code: 'out_of_range' },
      ]),
    )
    const { router } = renderApp('/shifts/new')
    const user = userEvent.setup()

    await fillIn(user)
    await user.click(screen.getByRole('button', { name: 'Veröffentlichen' }))

    expect(await screen.findByRole('alert')).toHaveTextContent(
      'Bitte prüfe die markierten Felder.',
    )
    expect(await field('Einsatzort')).toHaveAccessibleDescription(
      'Diese Auswahl gibt es nicht mehr. Lade die Seite neu.',
    )
    expect(await field('Ende')).toHaveAccessibleDescription('Das Ende muss nach dem Beginn liegen.')
    expect(await field('Stundenlohn in Euro')).toHaveAccessibleDescription(
      'Der Stundenlohn muss über 0 € liegen.',
    )
    expect(await field('Einsatzort')).toHaveFocus()
    expect(await field('Titel')).toHaveValue('Lagerunterstützung')
    expect(router.state.location.pathname).toBe('/shifts/new')
  })

  it('keeps the entries when the server cannot be reached', async () => {
    api.respondOnce('POST /shifts', new TypeError('Failed to fetch'))
    renderApp('/shifts/new')
    const user = userEvent.setup()

    await fillIn(user)
    await user.click(screen.getByRole('button', { name: 'Veröffentlichen' }))

    expect(await screen.findByRole('alert')).toHaveTextContent('Der Server ist nicht erreichbar.')
    expect(await field('Titel')).toHaveValue('Lagerunterstützung')
    expect(screen.getByRole('button', { name: 'Veröffentlichen' })).toBeEnabled()
  })

  it('goes back to the list on cancel', async () => {
    const { router } = renderApp('/shifts/new')

    await userEvent.click(await screen.findByRole('link', { name: 'Abbrechen' }))

    expect(router.state.location.pathname).toBe('/shifts')
    expect(created()).toBeUndefined()
  })

  it('shows an error when clients and qualifications cannot be loaded, and recovers', async () => {
    api.respondOnce('GET /qualifications', problem(500, 'internal_error'))
    renderApp('/shifts/new')

    expect(
      await screen.findByRole('heading', { name: 'Das Formular konnte nicht geladen werden' }),
    ).toBeInTheDocument()

    await userEvent.click(screen.getByRole('button', { name: 'Erneut versuchen' }))

    expect(await field('Kunde')).toBeInTheDocument()
  })

  it('explains that a shift needs a client when the agency has none', async () => {
    api.clients = []
    renderApp('/shifts/new')

    expect(await screen.findByRole('heading', { name: 'Noch keine Kunden' })).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Veröffentlichen' })).not.toBeInTheDocument()
  })
})
