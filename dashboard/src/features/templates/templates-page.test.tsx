import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it } from 'vitest'

import {
  forklift,
  installFakeApi,
  morningTemplate,
  nightTemplate,
  nordlicht,
  problem,
  zentrallager,
} from '@/test/fake-api'
import { renderApp } from '@/test/render'
import { enter, typingUser } from '@/test/user'

describe('templates page', () => {
  let api: ReturnType<typeof installFakeApi>

  beforeEach(() => {
    api = installFakeApi()
    api.signIn()
  })

  /** The rows of the loaded table, without its header. */
  const rows = async () => {
    await waitFor(() => {
      expect(screen.queryByRole('status')).not.toBeInTheDocument()
    })
    const table = await screen.findByRole('table')
    return within(table).getAllByRole('row').slice(1)
  }
  const sent = (route: string) => api.calls.find((call) => call.route === route)?.body

  describe('the list', () => {
    it('shows every template sorted by name, with its times, rate and spots', async () => {
      renderApp('/templates')

      expect(await screen.findByRole('heading', { name: 'Vorlagen' })).toBeInTheDocument()
      const [gala, lager] = await rows()
      expect(gala).toHaveTextContent('Gala Nachtservice')
      expect(gala).toHaveTextContent('Servicekraft Gala')
      expect(gala).toHaveTextContent('Hafenhalle Events')
      // Seven hours from 22:00 end the next morning; the end is an estimate.
      expect(gala).toHaveTextContent('22:00 – ca. 05:00 (Folgetag)')
      expect(gala).toHaveTextContent('18,50 €')
      expect(lager).toHaveTextContent('Lager Frühschicht')
      expect(lager).toHaveTextContent('Zentrallager Linz')
      expect(lager).toHaveTextContent('06:00 – 14:00')
      expect(lager).toHaveTextContent('16,50 €')
      expect(lager?.querySelectorAll('td')[5]).toHaveTextContent('3')
      expect(screen.getByText('2 Vorlagen')).toBeInTheDocument()
    })

    it('is reachable from the navigation', async () => {
      renderApp('/shifts')
      const user = userEvent.setup()

      await user.click(await screen.findByRole('link', { name: 'Vorlagen' }))

      expect(await screen.findByRole('heading', { name: 'Vorlagen' })).toBeInTheDocument()
    })

    it('says when a client or location no longer exists', async () => {
      api.templates = [{ ...morningTemplate, clientId: '0199c3a0-0000-7000-8000-000000000399' }]
      renderApp('/templates')

      const [row] = await rows()
      expect(row?.textContent.match(/Nicht mehr vorhanden/g)).toHaveLength(2)
    })

    it('explains how to create the first template', async () => {
      api.templates = []
      renderApp('/templates')

      expect(await screen.findByText('Noch keine Vorlagen')).toBeInTheDocument()
      expect(screen.getByRole('link', { name: 'Neue Schicht' })).toHaveAttribute('href', '/shifts/new')
    })

    it('offers to try again when loading fails', async () => {
      api.respondOnce('GET /shift-templates', problem(500, 'internal'))
      renderApp('/templates')
      const user = userEvent.setup()

      await user.click(await screen.findByRole('button', { name: 'Erneut versuchen' }))

      expect(await rows()).toHaveLength(2)
    })
  })

  describe('editing', () => {
    it('changes every field, the name included, and goes back to the list', async () => {
      renderApp('/templates')
      const user = typingUser()

      await user.click(
        await screen.findByRole('link', { name: 'Vorlage „Lager Frühschicht“ bearbeiten' }),
      )

      const name = await screen.findByLabelText('Name der Vorlage')
      expect(name).toHaveValue('Lager Frühschicht')
      // A template has no date.
      expect(screen.queryByLabelText('Datum')).not.toBeInTheDocument()
      expect(screen.getByLabelText('Beginn')).toHaveValue('06:00')
      expect(screen.getByLabelText('Ende')).toHaveValue('14:00')

      await user.clear(name)
      await enter(user, name, 'Lager Spätschicht')
      await user.clear(screen.getByLabelText('Beginn'))
      await enter(user, screen.getByLabelText('Beginn'), '22:00')
      await user.clear(screen.getByLabelText('Ende'))
      await enter(user, screen.getByLabelText('Ende'), '06:00')
      expect(screen.getByText('Endet am Folgetag.')).toBeInTheDocument()
      await user.clear(screen.getByLabelText('Plätze'))
      await user.type(screen.getByLabelText('Plätze'), '4')
      await user.click(screen.getByRole('button', { name: 'Vorlage speichern' }))

      expect(await screen.findByText('Vorlage „Lager Spätschicht“ gespeichert')).toBeInTheDocument()
      expect(sent(`PUT /shift-templates/${morningTemplate.id}`)).toEqual({
        name: 'Lager Spätschicht',
        clientId: nordlicht.id,
        locationId: zentrallager.id,
        title: 'Lagerunterstützung',
        description: 'Sicherheitsschuhe mitbringen.',
        startTime: '22:00',
        durationMinutes: 480,
        endIsEstimate: false,
        hourlyRateCents: 1650,
        slots: 4,
        qualificationIds: [forklift.id],
      })
      expect(await screen.findByRole('heading', { name: 'Vorlagen' })).toBeInTheDocument()
      const [, lager] = await rows()
      expect(lager).toHaveTextContent('Lager Spätschicht')
      expect(lager).toHaveTextContent('22:00 – 06:00 (Folgetag)')
    })

    it('keeps the name unique', async () => {
      renderApp(`/templates/${morningTemplate.id}`)
      const user = userEvent.setup()

      const name = await screen.findByLabelText('Name der Vorlage')
      await user.clear(name)
      await user.type(name, nightTemplate.name.toUpperCase())
      await user.click(screen.getByRole('button', { name: 'Vorlage speichern' }))

      expect(await screen.findByText('Eine Vorlage mit diesem Namen gibt es schon.')).toBeInTheDocument()
      expect(name).toHaveFocus()
      expect(name).toHaveAttribute('aria-invalid', 'true')
    })

    it('needs a name and the fields a shift needs', async () => {
      renderApp(`/templates/${morningTemplate.id}`)
      const user = userEvent.setup()

      await user.clear(await screen.findByLabelText('Name der Vorlage'))
      await user.clear(screen.getByLabelText('Titel'))
      await user.click(screen.getByRole('button', { name: 'Vorlage speichern' }))

      expect(await screen.findByText('Bitte gib einen Namen ein.')).toBeInTheDocument()
      expect(screen.getByLabelText('Titel')).toHaveAttribute('aria-invalid', 'true')
      expect(api.count(`PUT /shift-templates/${morningTemplate.id}`)).toBe(0)
    })

    it('says so when the template is gone', async () => {
      renderApp('/templates/0199c3a0-0000-7000-8000-000000000799')

      expect(await screen.findByText('Diese Vorlage gibt es nicht mehr')).toBeInTheDocument()
      expect(screen.getByRole('link', { name: 'Zu den Vorlagen' })).toHaveAttribute('href', '/templates')
    })
  })

  describe('deleting', () => {
    it('asks first and leaves the template when kept', async () => {
      renderApp('/templates')
      const user = userEvent.setup()

      await user.click(
        await screen.findByRole('button', { name: 'Vorlage „Lager Frühschicht“ löschen' }),
      )
      const dialog = within(await screen.findByRole('alertdialog'))
      expect(dialog.getByText(/bleiben, wie sie sind/)).toBeInTheDocument()
      await user.click(dialog.getByRole('button', { name: 'Behalten' }))

      expect(api.count(`DELETE /shift-templates/${morningTemplate.id}`)).toBe(0)
      expect(await rows()).toHaveLength(2)
    })

    it('removes the template from the list', async () => {
      renderApp('/templates')
      const user = userEvent.setup()

      await user.click(
        await screen.findByRole('button', { name: 'Vorlage „Lager Frühschicht“ löschen' }),
      )
      await user.click(
        within(await screen.findByRole('alertdialog')).getByRole('button', {
          name: 'Vorlage löschen',
        }),
      )

      expect(await screen.findByText('Vorlage „Lager Frühschicht“ gelöscht')).toBeInTheDocument()
      await waitFor(async () => {
        expect(await rows()).toHaveLength(1)
      })
      expect(screen.queryByText('Lager Frühschicht')).not.toBeInTheDocument()
    })

    it('says so when a colleague deleted it already', async () => {
      renderApp('/templates')
      const user = userEvent.setup()

      await user.click(
        await screen.findByRole('button', { name: 'Vorlage „Lager Frühschicht“ löschen' }),
      )
      api.templates = [nightTemplate]
      await user.click(
        within(await screen.findByRole('alertdialog')).getByRole('button', {
          name: 'Vorlage löschen',
        }),
      )

      expect(
        await screen.findByText('Diese Vorlage gibt es nicht mehr. Die Liste wurde aktualisiert.'),
      ).toBeInTheDocument()
      await waitFor(async () => {
        expect(await rows()).toHaveLength(1)
      })
    })
  })
})
