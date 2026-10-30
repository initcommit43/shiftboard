import { screen, waitFor, within } from '@testing-library/react'
import userEvent, { type UserEvent } from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

import { StaffRequestStatus } from '@/api/generated'
import {
  clientContact,
  installFakeApi,
  nordlicht,
  openRequest,
  portalNewYear,
  problem,
  staffRequest,
  umschlaglager,
  zentrallager,
} from '@/test/fake-api'
import { renderApp } from '@/test/render'

describe('client portal: staff requests', () => {
  let api: ReturnType<typeof installFakeApi>

  beforeEach(() => {
    // Only the clock is fake, so that the fixtures' October 2026 lies ahead.
    vi.useFakeTimers({ toFake: ['Date'] })
    vi.setSystemTime(new Date(2026, 9, 14, 12, 0))
    api = installFakeApi()
    api.user = clientContact
    api.features = { contactButton: false, checkIn: false, clientPortal: true }
    api.signIn()
  })

  afterEach(() => {
    vi.useRealTimers()
  })

  const field = (label: string) => screen.findByLabelText<HTMLInputElement>(label)
  const sent = () => api.calls.find((call) => call.route === 'POST /client/staff-requests')?.body

  function row(role: string) {
    const found = screen.getByText(role).closest('tr')
    if (!found) {
      throw new Error(`No row for ${role}`)
    }
    return within(found)
  }

  describe('navigation', () => {
    it('switches between the shifts and the requests', async () => {
      const user = userEvent.setup()
      const { router } = renderApp('/portal')

      const nav = within(await screen.findByRole('navigation', { name: 'Portalnavigation' }))
      expect(nav.getByRole('link', { name: 'Schichten' })).toHaveAttribute('aria-current', 'page')
      await user.click(nav.getByRole('link', { name: 'Personalanfragen' }))

      expect(await screen.findByRole('heading', { name: 'Personalanfragen' })).toBeInTheDocument()
      expect(router.state.location.pathname).toBe('/portal/requests')
      expect(nav.getByRole('link', { name: 'Personalanfragen' })).toHaveAttribute('aria-current', 'page')
      expect(nav.getByRole('link', { name: 'Schichten' })).not.toHaveAttribute('aria-current')
    })
  })

  describe('the list', () => {
    it("shows the client's requests with their status and what became of them", async () => {
      renderApp('/portal/requests')

      expect(await screen.findByText('Lagerhelfer:innen')).toBeInTheDocument()
      expect(screen.queryByText('Servicekräfte')).not.toBeInTheDocument()

      const open = row('Lagerhelfer:innen')
      expect(open.getByText('Offen')).toBeInTheDocument()
      expect(open.getByText('Zentrallager Linz')).toBeInTheDocument()
      expect(open.getByText('Do., 22.10.2026')).toBeInTheDocument()
      expect(open.getByText('07:00 – ca. 15:00')).toBeInTheDocument()
      expect(open.getByText('3 Personen')).toBeInTheDocument()
      expect(open.getByText('Angefragt von Petra Lindner')).toBeInTheDocument()
      expect(open.getByRole('button', { name: /zurückziehen/ })).toBeInTheDocument()

      const planned = row('Inventurhilfe')
      expect(planned.getByText('Eingeplant')).toBeInTheDocument()
      expect(planned.getByRole('link', { name: 'Zur Schicht' })).toHaveAttribute(
        'href',
        `/portal/shifts/${portalNewYear.id}`,
      )

      const preparing = row('Kommissionierung')
      expect(preparing.getByText('Eingeplant')).toBeInTheDocument()
      expect(preparing.getByText('Die Agentur bereitet die Schicht vor.')).toBeInTheDocument()
      expect(preparing.queryByRole('link')).not.toBeInTheDocument()

      const declined = row('Staplerfahrer:innen')
      expect(declined.getByText('Abgelehnt')).toBeInTheDocument()
      expect(
        declined.getByText('Grund: An diesem Tag ist niemand mit Staplerschein frei.'),
      ).toBeInTheDocument()
      expect(declined.queryByRole('button')).not.toBeInTheDocument()

      const withdrawn = row('Verpackung')
      expect(withdrawn.getByText('Zurückgezogen')).toBeInTheDocument()
      expect(withdrawn.getByText('1 Person')).toBeInTheDocument()
      expect(withdrawn.queryByRole('button')).not.toBeInTheDocument()

      expect(screen.getByText('5 Anfragen')).toBeInTheDocument()
    })

    it('lists the newest request first', async () => {
      renderApp('/portal/requests')

      await screen.findByText('Lagerhelfer:innen')
      const roles = screen
        .getAllByRole('row')
        .slice(1)
        .map((it) => it.querySelector('td span')?.textContent)
      expect(roles).toEqual([
        'Verpackung',
        'Staplerfahrer:innen',
        'Kommissionierung',
        'Inventurhilfe',
        'Lagerhelfer:innen',
      ])
    })

    it('withdraws an open request after a confirmation', async () => {
      const user = userEvent.setup()
      renderApp('/portal/requests')

      await user.click(
        await screen.findByRole('button', {
          name: 'Anfrage Lagerhelfer:innen am Do., 22.10.2026 zurückziehen',
        }),
      )
      const dialog = within(await screen.findByRole('alertdialog'))
      expect(dialog.getByRole('heading', { name: 'Anfrage zurückziehen?' })).toBeInTheDocument()

      // Keeping it sends nothing.
      await user.click(dialog.getByRole('button', { name: 'Behalten' }))
      expect(api.count(`POST /client/staff-requests/${openRequest.id}/withdraw`)).toBe(0)

      await user.click(screen.getByRole('button', { name: /Lagerhelfer:innen am .* zurückziehen/ }))
      await user.click(
        within(await screen.findByRole('alertdialog')).getByRole('button', { name: 'Zurückziehen' }),
      )

      expect(await screen.findByText('Anfrage Lagerhelfer:innen zurückgezogen')).toBeInTheDocument()
      await waitFor(() => {
        expect(row('Lagerhelfer:innen').getByText('Zurückgezogen')).toBeInTheDocument()
      })
      expect(row('Lagerhelfer:innen').queryByRole('button')).not.toBeInTheDocument()
    })

    it('says so when the agency handled the request in the meantime', async () => {
      const user = userEvent.setup()
      renderApp('/portal/requests')

      await screen.findByText('Lagerhelfer:innen')
      api.staffRequests = api.staffRequests.map((it) =>
        it.id === openRequest.id ? { ...it, status: StaffRequestStatus.DECLINED, declineReason: 'Ausgebucht.' } : it,
      )
      await user.click(screen.getByRole('button', { name: /Lagerhelfer:innen am .* zurückziehen/ }))
      await user.click(
        within(await screen.findByRole('alertdialog')).getByRole('button', { name: 'Zurückziehen' }),
      )

      expect(
        await screen.findByText(
          'Diese Anfrage wurde schon bearbeitet oder zurückgezogen. Die Liste wurde aktualisiert.',
        ),
      ).toBeInTheDocument()
      expect(await screen.findByText('Grund: Ausgebucht.')).toBeInTheDocument()
    })

    it('pages through many requests', async () => {
      const user = userEvent.setup()
      api.staffRequests = Array.from({ length: 25 }, (_, index) =>
        staffRequest(index + 30, {
          role: `Anfrage ${String(index + 1)}`,
          createdAt: new Date(2026, 9, 13, 23, 59 - index),
        }),
      )
      renderApp('/portal/requests')

      expect(await screen.findByText('Anfrage 1')).toBeInTheDocument()
      await user.click(screen.getByRole('button', { name: 'Weiter' }))

      expect(await screen.findByText('Anfrage 21')).toBeInTheDocument()
      expect(screen.getByText('Seite 2 von 2')).toBeInTheDocument()
    })

    it('shows an empty state that leads to the form', async () => {
      const user = userEvent.setup()
      api.staffRequests = []
      const { router } = renderApp('/portal/requests')

      expect(await screen.findByText('Noch keine Anfragen')).toBeInTheDocument()
      // The header has the same link; the empty state's comes second.
      const [, fromEmptyState] = screen.getAllByRole('link', { name: 'Personal anfragen' })
      if (!fromEmptyState) {
        throw new Error('The empty state has no link to the form')
      }
      await user.click(fromEmptyState)

      expect(await screen.findByRole('heading', { name: 'Personal anfragen' })).toBeInTheDocument()
      expect(router.state.location.pathname).toBe('/portal/requests/new')
    })

    it('shows an error and recovers on retry', async () => {
      const user = userEvent.setup()
      api.respondOnce('GET /client/staff-requests', new Response(null, { status: 500 }))
      renderApp('/portal/requests')

      expect(await screen.findByText('Anfragen konnten nicht geladen werden')).toBeInTheDocument()
      await user.click(screen.getByRole('button', { name: 'Erneut versuchen' }))

      expect(await screen.findByText('Lagerhelfer:innen')).toBeInTheDocument()
    })
  })

  describe('the form', () => {
    /** Fills in everything a request needs, for the Umschlaglager. */
    async function fillIn(user: UserEvent) {
      await user.selectOptions(await field('Einsatzort'), 'Umschlaglager Wels')
      await user.type(await field('Tätigkeit'), 'Wareneingang')
      await user.type(await field('Datum'), '2026-10-24')
      await user.type(await field('Beginn'), '22:00')
      await user.type(await field('Ende'), '06:00')
    }

    it('sends a request, then shows it as open in the list', async () => {
      const user = userEvent.setup()
      const { router } = renderApp('/portal/requests')

      await user.click(await screen.findByRole('link', { name: 'Personal anfragen' }))
      expect(
        within(await field('Einsatzort'))
          .getAllByRole('option')
          .map((it) => it.textContent),
      ).toEqual(['Bitte wählen', 'Umschlaglager Wels', 'Zentrallager Linz'])
      await fillIn(user)
      expect(screen.getByText('Terminalstraße 12, 4600 Wels')).toBeInTheDocument()
      expect(await field('Ende')).toHaveAccessibleDescription('Endet am Folgetag, So., 25.10.2026.')
      await user.click(screen.getByRole('checkbox', { name: /ungefähr/ }))
      await user.clear(await field('Anzahl Personen'))
      await user.type(await field('Anzahl Personen'), '4')
      await user.type(await field('Hinweise'), 'Bitte am Empfang melden.')
      await user.click(screen.getByRole('button', { name: 'Anfrage senden' }))

      expect(await screen.findByText('Anfrage für Wareneingang gesendet')).toBeInTheDocument()
      expect(sent()).toEqual({
        locationId: umschlaglager.id,
        role: 'Wareneingang',
        startsAt: new Date(2026, 9, 24, 22, 0).toISOString(),
        endsAt: new Date(2026, 9, 25, 6, 0).toISOString(),
        endIsEstimate: true,
        workerCount: 4,
        notes: 'Bitte am Empfang melden.',
      })
      await waitFor(() => {
        expect(router.state.location.pathname).toBe('/portal/requests')
      })
      await screen.findByText('Wareneingang')
      const created = row('Wareneingang')
      expect(created.getByText('Offen')).toBeInTheDocument()
      expect(created.getByText('22:00 – ca. So., 06:00')).toBeInTheDocument()
      expect(created.getByText('4 Personen')).toBeInTheDocument()
    })

    it('leaves out empty notes', async () => {
      const user = userEvent.setup()
      renderApp('/portal/requests/new')

      await fillIn(user)
      await user.click(screen.getByRole('button', { name: 'Anfrage senden' }))

      await screen.findByText('Anfrage für Wareneingang gesendet')
      expect(sent()).toMatchObject({ workerCount: 1, endIsEstimate: false })
      expect(sent()).not.toHaveProperty('notes')
    })

    it('names what is missing and sends nothing', async () => {
      const user = userEvent.setup()
      renderApp('/portal/requests/new')

      await user.clear(await field('Anzahl Personen'))
      await user.click(screen.getByRole('button', { name: 'Anfrage senden' }))

      for (const label of ['Einsatzort', 'Tätigkeit', 'Datum', 'Beginn', 'Ende', 'Anzahl Personen']) {
        expect(await field(label)).toHaveAccessibleDescription('Bitte ausfüllen.')
        expect(await field(label)).toBeInvalid()
      }
      expect(await field('Einsatzort')).toHaveFocus()
      expect(sent()).toBeUndefined()

      await user.type(await field('Tätigkeit'), 'Wareneingang')
      expect(await field('Tätigkeit')).toBeValid()
    })

    it('rejects a start that has passed and a count out of range', async () => {
      const user = userEvent.setup()
      renderApp('/portal/requests/new')

      await fillIn(user)
      await user.clear(await field('Datum'))
      await user.type(await field('Datum'), '2026-10-13')
      await user.clear(await field('Anzahl Personen'))
      await user.type(await field('Anzahl Personen'), '501')
      await user.click(screen.getByRole('button', { name: 'Anfrage senden' }))

      expect(await field('Datum')).toHaveAccessibleDescription('Dieser Zeitpunkt ist schon vorbei.')
      expect(await field('Anzahl Personen')).toHaveAccessibleDescription('Zwischen 1 und 500 Personen.')
      expect(sent()).toBeUndefined()

      // Today, but earlier than now: the start is wrong, not the day.
      await user.clear(await field('Datum'))
      await user.type(await field('Datum'), '2026-10-14')
      await user.clear(await field('Beginn'))
      await user.type(await field('Beginn'), '11:00')
      await user.click(screen.getByRole('button', { name: 'Anfrage senden' }))

      expect(await field('Datum')).toBeValid()
      expect(await field('Beginn')).toHaveAccessibleDescription('Dieser Zeitpunkt ist schon vorbei.')
      expect(sent()).toBeUndefined()
    })

    it('places the field errors of the API on the fields', async () => {
      const user = userEvent.setup()
      api.respondOnce(
        'POST /client/staff-requests',
        problem(400, 'validation_failed', [
          { field: 'locationId', code: 'not_found' },
          { field: 'startsAt', code: 'in_past' },
        ]),
      )
      renderApp('/portal/requests/new')

      await fillIn(user)
      await user.click(screen.getByRole('button', { name: 'Anfrage senden' }))

      expect(await field('Einsatzort')).toHaveAccessibleDescription(
        'Diesen Einsatzort gibt es nicht mehr. Lade die Seite neu.',
      )
      expect(await field('Beginn')).toHaveAccessibleDescription('Dieser Zeitpunkt ist schon vorbei.')
      expect(screen.getByRole('alert')).toHaveTextContent('Bitte prüfe die markierten Felder.')
      expect(await field('Einsatzort')).toHaveFocus()
    })

    it('chooses a sole location', async () => {
      api.clients = api.clients.map((it) => (it.id === nordlicht.id ? { ...it, locations: [zentrallager] } : it))
      renderApp('/portal/requests/new')

      expect(await field('Einsatzort')).toHaveValue(zentrallager.id)
      expect(screen.getByText('Industriezeile 40, 4020 Linz')).toBeInTheDocument()
    })

    it('says so when the client has no location', async () => {
      api.clients = api.clients.map((it) => (it.id === nordlicht.id ? { ...it, locations: [] } : it))
      renderApp('/portal/requests/new')

      expect(await screen.findByText('Noch keine Einsatzorte')).toBeInTheDocument()
      expect(screen.queryByRole('button', { name: 'Anfrage senden' })).not.toBeInTheDocument()
    })

    it('goes back to the list', async () => {
      const user = userEvent.setup()
      const { router } = renderApp('/portal/requests/new')

      await user.click(await screen.findByRole('link', { name: 'Alle Anfragen' }))

      await waitFor(() => {
        expect(router.state.location.pathname).toBe('/portal/requests')
      })
    })
  })
})
