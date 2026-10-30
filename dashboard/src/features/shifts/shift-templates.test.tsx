import { screen, waitFor, within } from '@testing-library/react'
import type { UserEvent } from '@testing-library/user-event'
import { beforeEach, describe, expect, it } from 'vitest'

import {
  forklift,
  gala,
  hafenhalle,
  hafenhalleLinz,
  installFakeApi,
  nordlicht,
  service,
  zentrallager,
} from '@/test/fake-api'
import { renderApp } from '@/test/render'
import { enter, typingUser } from '@/test/user'

describe('shift templates', () => {
  let api: ReturnType<typeof installFakeApi>

  beforeEach(() => {
    api = installFakeApi()
    api.signIn()
  })

  // Looked up once the form is shown: waiting for each field again costs a turn of the event
  // loop every time, and on a busy machine those turns add up past the test timeout.
  const field = (label: string) => screen.getByLabelText<HTMLInputElement>(label)
  const formShown = () => screen.findByLabelText('Kunde')
  /** The template picker, once the templates have loaded. */
  async function picker() {
    const select = await screen.findByLabelText<HTMLSelectElement>('Vorlage verwenden')
    await waitFor(() => {
      expect(select).toBeEnabled()
    })
    return select
  }
  const sent = (route: string) => api.calls.find((call) => call.route === route)?.body

  /** Everything a template needs; no date. */
  async function fillIn(user: UserEvent, start: string, end: string) {
    await formShown()
    await user.selectOptions(field('Kunde'), 'Nordlicht Logistik')
    await user.selectOptions(field('Einsatzort'), 'Zentrallager Linz')
    await enter(user, field('Titel'), 'Kommissionierung')
    await enter(user, field('Beginn'), start)
    await enter(user, field('Ende'), end)
    await enter(user, field('Stundenlohn in Euro'), '15,80')
  }

  describe('saving', () => {
    it('saves the form without a date and offers it for the next shift', async () => {
      renderApp('/shifts/new')
      const user = typingUser()

      await fillIn(user, '14:00', '22:30')
      await user.click(screen.getByRole('checkbox', { name: 'Staplerschein' }))
      await user.click(screen.getByRole('button', { name: 'Als Vorlage speichern' }))

      const dialog = within(await screen.findByRole('alertdialog'))
      const name = dialog.getByLabelText('Name der Vorlage')
      expect(name).toHaveValue('Kommissionierung')
      await user.clear(name)
      await user.type(name, 'Lager Spätschicht')
      await user.click(dialog.getByRole('button', { name: 'Vorlage speichern' }))

      expect(await screen.findByText('Vorlage „Lager Spätschicht“ gespeichert')).toBeInTheDocument()
      expect(screen.queryByRole('alertdialog')).not.toBeInTheDocument()
      expect(sent('POST /shift-templates')).toEqual({
        name: 'Lager Spätschicht',
        clientId: nordlicht.id,
        locationId: zentrallager.id,
        title: 'Kommissionierung',
        startTime: '14:00',
        durationMinutes: 510,
        endIsEstimate: false,
        hourlyRateCents: 1580,
        slots: 1,
        qualificationIds: [forklift.id],
      })
      // The form stays as it was, ready to be published too.
      expect(field('Titel')).toHaveValue('Kommissionierung')
      await waitFor(() => {
        expect(
          within(screen.getByLabelText('Vorlage verwenden')).getByRole('option', {
            name: 'Lager Spätschicht',
          }),
        ).toBeInTheDocument()
      })
    })

    it('keeps the next day of an overnight shift as its length', async () => {
      renderApp('/shifts/new')
      const user = typingUser()

      await fillIn(user, '22:00', '06:00')
      await user.click(screen.getByRole('button', { name: 'Als Vorlage speichern' }))
      await user.click(
        within(await screen.findByRole('alertdialog')).getByRole('button', {
          name: 'Vorlage speichern',
        }),
      )

      await waitFor(() => {
        expect(sent('POST /shift-templates')).toMatchObject({
          startTime: '22:00',
          durationMinutes: 480,
        })
      })
    })

    it('names what is missing first, but not the date', async () => {
      renderApp('/shifts/new')
      const user = typingUser()

      await formShown()
      await user.click(screen.getByRole('button', { name: 'Als Vorlage speichern' }))

      expect(screen.queryByRole('alertdialog')).not.toBeInTheDocument()
      expect(field('Kunde')).toHaveAccessibleDescription('Bitte ausfüllen.')
      expect(field('Beginn')).toHaveAccessibleDescription('Bitte ausfüllen.')
      expect(field('Datum')).toBeValid()
      expect(field('Kunde')).toHaveFocus()
      expect(sent('POST /shift-templates')).toBeUndefined()
    })

    it('asks for another name when the agency has one like it', async () => {
      renderApp('/shifts/new')
      const user = typingUser()

      await fillIn(user, '06:00', '14:00')
      await user.click(screen.getByRole('button', { name: 'Als Vorlage speichern' }))
      const dialog = within(await screen.findByRole('alertdialog'))
      const name = dialog.getByLabelText('Name der Vorlage')

      await user.clear(name)
      await user.click(dialog.getByRole('button', { name: 'Vorlage speichern' }))
      expect(name).toHaveAccessibleDescription('Bitte gib einen Namen ein.')

      await user.type(name, 'lager frühschicht')
      await user.click(dialog.getByRole('button', { name: 'Vorlage speichern' }))

      await waitFor(() => {
        expect(name).toHaveAccessibleDescription('Eine Vorlage mit diesem Namen gibt es schon.')
      })
      expect(name).toHaveFocus()
      expect(screen.getByRole('alertdialog')).toBeInTheDocument()
    })

    it('saves an existing shift from its detail page', async () => {
      renderApp(`/shifts/${gala.id}`)
      const user = typingUser()

      await user.click(await screen.findByRole('button', { name: 'Als Vorlage speichern' }))
      const dialog = within(await screen.findByRole('alertdialog'))
      expect(dialog.getByLabelText('Name der Vorlage')).toHaveValue('Servicekraft Gala')
      await user.click(dialog.getByRole('button', { name: 'Vorlage speichern' }))

      expect(await screen.findByText('Vorlage „Servicekraft Gala“ gespeichert')).toBeInTheDocument()
      expect(sent('POST /shift-templates')).toEqual({
        name: 'Servicekraft Gala',
        clientId: hafenhalle.id,
        locationId: hafenhalleLinz.id,
        title: 'Servicekraft Gala',
        startTime: '18:00',
        durationMinutes: 420,
        endIsEstimate: false,
        hourlyRateCents: 1800,
        slots: 4,
        qualificationIds: [service.id],
      })
    })
  })

  describe('using', () => {
    it('fills in the form from a template so only the date is left', async () => {
      const { router } = renderApp('/shifts/new')
      const user = typingUser()

      const select = await picker()
      expect(
        within(select)
          .getAllByRole('option')
          .map((it) => it.textContent),
      ).toEqual(['Ohne Vorlage', 'Gala Nachtservice', 'Lager Frühschicht'])
      await user.selectOptions(select, 'Lager Frühschicht')

      expect(field('Kunde')).toHaveValue(nordlicht.id)
      expect(field('Einsatzort')).toHaveValue(zentrallager.id)
      expect(field('Titel')).toHaveValue('Lagerunterstützung')
      expect(field('Beschreibung')).toHaveValue('Sicherheitsschuhe mitbringen.')
      expect(field('Beginn')).toHaveValue('06:00')
      expect(field('Ende')).toHaveValue('14:00')
      expect(field('Datum')).toHaveValue('')
      expect(screen.getByRole('checkbox', { name: 'Staplerschein' })).toBeChecked()

      await user.type(field('Datum'), '2026-10-27')
      await user.click(screen.getByRole('button', { name: 'Veröffentlichen' }))

      await waitFor(() => {
        expect(router.state.location.pathname).toBe('/shifts')
      })
      expect(sent('POST /shifts')).toEqual({
        clientId: nordlicht.id,
        locationId: zentrallager.id,
        title: 'Lagerunterstützung',
        description: 'Sicherheitsschuhe mitbringen.',
        startsAt: new Date(2026, 9, 27, 6, 0).toISOString(),
        endsAt: new Date(2026, 9, 27, 14, 0).toISOString(),
        endIsEstimate: false,
        hourlyRateCents: 1650,
        slots: 3,
        qualificationIds: [forklift.id],
        publish: true,
      })
    })

    it('places an overnight template across midnight', async () => {
      const { router } = renderApp('/shifts/new')
      const user = typingUser()

      const select = await picker()
      await user.selectOptions(select, 'Gala Nachtservice')

      expect(field('Beginn')).toHaveValue('22:00')
      expect(field('Ende')).toHaveValue('05:00')
      expect(screen.getByRole('checkbox', { name: /geschätzt/ })).toBeChecked()

      // In Central European time, summer time ends that night.
      await user.type(field('Datum'), '2026-10-24')
      await user.click(screen.getByRole('button', { name: 'Als Entwurf speichern' }))

      await waitFor(() => {
        expect(router.state.location.pathname).toBe('/shifts')
      })
      expect(sent('POST /shifts')).toMatchObject({
        startsAt: new Date(2026, 9, 24, 22, 0).toISOString(),
        endsAt: new Date(2026, 9, 25, 5, 0).toISOString(),
        endIsEstimate: true,
      })
    })

    it('leaves out a qualification that no longer exists and says so', async () => {
      api.qualifications = [forklift]
      renderApp('/shifts/new')
      const user = typingUser()

      const select = await picker()
      await user.selectOptions(select, 'Gala Nachtservice')

      expect(await screen.findByRole('alert')).toHaveTextContent(
        'Nicht mehr vorhanden und daher leer: Erforderliche Qualifikationen.',
      )
      expect(field('Kunde')).toHaveValue(hafenhalle.id)
      expect(screen.getByRole('checkbox', { name: 'Staplerschein' })).not.toBeChecked()
    })

    it('starts over empty when no template is chosen again', async () => {
      renderApp('/shifts/new')
      const user = typingUser()

      const select = await picker()
      await user.selectOptions(select, 'Lager Frühschicht')
      expect(field('Titel')).toHaveValue('Lagerunterstützung')

      await user.selectOptions(select, 'Ohne Vorlage')

      expect(field('Titel')).toHaveValue('')
      expect(field('Beginn')).toHaveValue('')
    })

    it('explains how to get a template when there is none', async () => {
      api.templates = []
      renderApp('/shifts/new')

      const select = await screen.findByLabelText('Vorlage verwenden')
      expect(
        await screen.findByText(/Noch keine Vorlagen\. Speichere eine Schicht/),
      ).toBeInTheDocument()
      expect(select).toBeDisabled()
      // The form works without one.
      expect(field('Kunde')).toBeEnabled()
    })
  })
})
