import { screen, waitFor, within } from '@testing-library/react'
import userEvent, { type UserEvent } from '@testing-library/user-event'
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

describe('shift templates', () => {
  let api: ReturnType<typeof installFakeApi>

  beforeEach(() => {
    api = installFakeApi()
    api.signIn()
  })

  const field = (label: string) => screen.findByLabelText<HTMLInputElement>(label)
  const sent = (route: string) => api.calls.find((call) => call.route === route)?.body

  /** Everything a template needs; no date. */
  async function fillIn(user: UserEvent, start: string, end: string) {
    await user.selectOptions(await field('Kunde'), 'Nordlicht Logistik')
    await user.selectOptions(await field('Einsatzort'), 'Zentrallager Linz')
    await user.type(await field('Titel'), 'Kommissionierung')
    await user.type(await field('Beginn'), start)
    await user.type(await field('Ende'), end)
    await user.type(await field('Stundenlohn in Euro'), '15,80')
  }

  describe('saving', () => {
    it('saves the form without a date and offers it for the next shift', async () => {
      renderApp('/shifts/new')
      const user = userEvent.setup()

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
      expect(await field('Titel')).toHaveValue('Kommissionierung')
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
      const user = userEvent.setup()

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
      const user = userEvent.setup()

      await user.click(await screen.findByRole('button', { name: 'Als Vorlage speichern' }))

      expect(screen.queryByRole('alertdialog')).not.toBeInTheDocument()
      expect(await field('Kunde')).toHaveAccessibleDescription('Bitte ausfüllen.')
      expect(await field('Beginn')).toHaveAccessibleDescription('Bitte ausfüllen.')
      expect(await field('Datum')).toBeValid()
      expect(await field('Kunde')).toHaveFocus()
      expect(sent('POST /shift-templates')).toBeUndefined()
    })

    it('asks for another name when the agency has one like it', async () => {
      renderApp('/shifts/new')
      const user = userEvent.setup()

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
      const user = userEvent.setup()

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
      const user = userEvent.setup()

      const picker = await field('Vorlage verwenden')
      await waitFor(() => {
        expect(picker).toBeEnabled()
      })
      expect(
        within(picker)
          .getAllByRole('option')
          .map((it) => it.textContent),
      ).toEqual(['Ohne Vorlage', 'Gala Nachtservice', 'Lager Frühschicht'])
      await user.selectOptions(picker, 'Lager Frühschicht')

      expect(await field('Kunde')).toHaveValue(nordlicht.id)
      expect(await field('Einsatzort')).toHaveValue(zentrallager.id)
      expect(await field('Titel')).toHaveValue('Lagerunterstützung')
      expect(await field('Beschreibung')).toHaveValue('Sicherheitsschuhe mitbringen.')
      expect(await field('Beginn')).toHaveValue('06:00')
      expect(await field('Ende')).toHaveValue('14:00')
      expect(await field('Datum')).toHaveValue('')
      expect(screen.getByRole('checkbox', { name: 'Staplerschein' })).toBeChecked()

      await user.type(await field('Datum'), '2026-10-27')
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
      const user = userEvent.setup()

      const picker = await field('Vorlage verwenden')
      await waitFor(() => {
        expect(picker).toBeEnabled()
      })
      await user.selectOptions(picker, 'Gala Nachtservice')

      expect(await field('Beginn')).toHaveValue('22:00')
      expect(await field('Ende')).toHaveValue('05:00')
      expect(screen.getByRole('checkbox', { name: /geschätzt/ })).toBeChecked()

      // In Central European time, summer time ends that night.
      await user.type(await field('Datum'), '2026-10-24')
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
      const user = userEvent.setup()

      const picker = await field('Vorlage verwenden')
      await waitFor(() => {
        expect(picker).toBeEnabled()
      })
      await user.selectOptions(picker, 'Gala Nachtservice')

      expect(await screen.findByRole('alert')).toHaveTextContent(
        'Nicht mehr vorhanden und daher leer: Erforderliche Qualifikationen.',
      )
      expect(await field('Kunde')).toHaveValue(hafenhalle.id)
      expect(screen.getByRole('checkbox', { name: 'Staplerschein' })).not.toBeChecked()
    })

    it('starts over empty when no template is chosen again', async () => {
      renderApp('/shifts/new')
      const user = userEvent.setup()

      const picker = await field('Vorlage verwenden')
      await waitFor(() => {
        expect(picker).toBeEnabled()
      })
      await user.selectOptions(picker, 'Lager Frühschicht')
      expect(await field('Titel')).toHaveValue('Lagerunterstützung')

      await user.selectOptions(picker, 'Ohne Vorlage')

      expect(await field('Titel')).toHaveValue('')
      expect(await field('Beginn')).toHaveValue('')
    })

    it('explains how to get a template when there is none', async () => {
      api.templates = []
      renderApp('/shifts/new')

      const picker = await field('Vorlage verwenden')
      expect(
        await screen.findByText(/Noch keine Vorlagen\. Speichere eine Schicht/),
      ).toBeInTheDocument()
      expect(picker).toBeDisabled()
      // The form works without one.
      expect(await field('Kunde')).toBeEnabled()
    })
  })
})
