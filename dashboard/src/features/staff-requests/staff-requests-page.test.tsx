import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it } from 'vitest'

import { StaffRequestStatus } from '@/api/generated'
import {
  declinedRequest,
  galaRequest,
  hafenhalle,
  hafenhalleLinz,
  installFakeApi,
  nordlicht,
  openRequest,
  problem,
  zentrallager,
} from '@/test/fake-api'
import { renderApp } from '@/test/render'

describe('staff requests', () => {
  let api: ReturnType<typeof installFakeApi>

  beforeEach(() => {
    api = installFakeApi()
    api.features = { contactButton: false, checkIn: false, clientPortal: true }
    api.signIn()
  })

  const field = (label: string) => screen.findByLabelText<HTMLInputElement>(label)
  const nav = () => within(screen.getByRole('navigation', { name: 'Hauptnavigation' }))
  const main = () => within(screen.getByRole('main'))

  function row(client: string) {
    const found = screen.getByText(client, { selector: 'td' }).closest('tr')
    if (!found) {
      throw new Error(`No row for ${client}`)
    }
    return within(found)
  }

  describe('navigation', () => {
    it('shows the number of open requests while the client portal is on', async () => {
      renderApp('/signups')

      expect(await screen.findByText('2 offene Anfragen')).toBeInTheDocument()
      expect(nav().getByRole('link', { name: /Anfragen/ })).toHaveAttribute('href', '/staff-requests')
      expect(api.queries('GET /staff-requests')[0]?.get('status')).toBe('OPEN')
    })

    it('leaves the item out while the client portal is off', async () => {
      api.features = { contactButton: false, checkIn: false, clientPortal: false }
      renderApp('/signups')

      expect(await screen.findByRole('heading', { name: 'Anmeldungen' })).toBeInTheDocument()
      await waitFor(() => {
        expect(api.count('GET /agency/features')).toBe(1)
      })
      expect(nav().queryByRole('link', { name: /Anfragen/ })).not.toBeInTheDocument()
      expect(api.count('GET /staff-requests')).toBe(0)
    })
  })

  describe('the list', () => {
    it('lists the open requests, earliest start first', async () => {
      renderApp('/staff-requests')

      expect(await screen.findByRole('heading', { name: 'Anfragen' })).toBeInTheDocument()
      await screen.findByText('Nordlicht Logistik', { selector: 'td' })
      const clients = screen
        .getAllByRole('row')
        .slice(1)
        .map((it) => it.querySelector('td')?.textContent)
      expect(clients).toEqual(['Hafenhalle Events', 'Nordlicht Logistik'])

      const nordlichtRow = row('Nordlicht Logistik')
      expect(nordlichtRow.getByText('Do., 22.10.2026')).toBeInTheDocument()
      expect(nordlichtRow.getByText('07:00 – ca. 15:00')).toBeInTheDocument()
      expect(nordlichtRow.getByText('Zentrallager Linz')).toBeInTheDocument()
      expect(nordlichtRow.getByText('Lagerhelfer:innen')).toBeInTheDocument()
      expect(nordlichtRow.getByText('Treffpunkt Tor 3, Sicherheitsschuhe mitbringen.')).toBeInTheDocument()
      expect(nordlichtRow.getByText('3')).toBeInTheDocument()
      expect(nordlichtRow.getByText('Petra Lindner')).toBeInTheDocument()

      const gala = row('Hafenhalle Events')
      expect(gala.getByText('18:00 – Mi., 01:00')).toBeInTheDocument()
      expect(gala.getByText('Paul Gruber')).toBeInTheDocument()
      expect(gala.getByRole('link', { name: /als Schicht anlegen/ })).toHaveAttribute(
        'href',
        `/shifts/new?request=${galaRequest.id}`,
      )
      expect(main().getByText('2 offene Anfragen')).toBeInTheDocument()
    })

    it('leaves out a request the client has withdrawn', async () => {
      api.staffRequests = api.staffRequests.map((it) =>
        it.id === galaRequest.id ? { ...it, status: StaffRequestStatus.WITHDRAWN } : it,
      )
      renderApp('/staff-requests')

      expect(await screen.findByText('Nordlicht Logistik', { selector: 'td' })).toBeInTheDocument()
      expect(screen.queryByText('Hafenhalle Events', { selector: 'td' })).not.toBeInTheDocument()
      expect(main().getByText('1 offene Anfrage')).toBeInTheDocument()
    })

    it('shows the handled requests in their own tabs', async () => {
      const user = userEvent.setup()
      const { router } = renderApp('/staff-requests')

      const tabs = within(await screen.findByRole('navigation', { name: 'Status' }))
      await user.click(tabs.getByRole('link', { name: 'Abgelehnt' }))

      expect(await screen.findByText(`Grund: ${declinedRequest.declineReason ?? ''}`)).toBeInTheDocument()
      expect(router.state.location.search).toBe('?status=declined')
      expect(api.queries('GET /staff-requests').at(-1)?.get('status')).toBe('DECLINED')
      expect(tabs.getByRole('link', { name: 'Abgelehnt' })).toHaveAttribute('aria-current', 'page')

      await user.click(tabs.getByRole('link', { name: 'Angenommen' }))
      expect(await screen.findByText('Kommissionierung')).toBeInTheDocument()
      expect(screen.getAllByRole('link', { name: 'Zur Schicht' })).toHaveLength(1)
      expect(screen.getByText('2 angenommene Anfragen')).toBeInTheDocument()
    })

    it('shows an empty state', async () => {
      api.staffRequests = []
      renderApp('/staff-requests')

      expect(await screen.findByText('Keine offenen Anfragen')).toBeInTheDocument()
    })

    it('shows an error and recovers on retry', async () => {
      const user = userEvent.setup()
      api.respondOnce('GET /staff-requests', new Response(null, { status: 500 }))
      api.respondOnce('GET /staff-requests', new Response(null, { status: 500 }))
      renderApp('/staff-requests')

      expect(await screen.findByText('Anfragen konnten nicht geladen werden')).toBeInTheDocument()
      await user.click(screen.getByRole('button', { name: 'Erneut versuchen' }))

      expect(await screen.findByText('Nordlicht Logistik', { selector: 'td' })).toBeInTheDocument()
    })
  })

  describe('declining', () => {
    it('asks for a reason, then declines and drops the request from the list and the count', async () => {
      const user = userEvent.setup()
      renderApp('/staff-requests')

      await user.click(
        await screen.findByRole('button', {
          name: 'Anfrage von Nordlicht Logistik für Do., 22.10.2026 ablehnen',
        }),
      )
      const dialog = within(await screen.findByRole('alertdialog'))
      await user.click(dialog.getByRole('button', { name: 'Ablehnen' }))

      const reason = dialog.getByLabelText('Grund')
      expect(reason).toHaveAccessibleDescription('Bitte gib einen Grund an.')
      expect(reason).toHaveFocus()
      expect(api.count(`POST /staff-requests/${openRequest.id}/decline`)).toBe(0)

      await user.type(reason, 'An diesem Tag sind alle schon eingeplant.')
      await user.click(dialog.getByRole('button', { name: 'Ablehnen' }))

      expect(await screen.findByText('Anfrage von Nordlicht Logistik abgelehnt')).toBeInTheDocument()
      expect(api.calls.find((it) => it.route === `POST /staff-requests/${openRequest.id}/decline`)?.body).toEqual({
        reason: 'An diesem Tag sind alle schon eingeplant.',
      })
      await waitFor(() => {
        expect(screen.queryByText('Nordlicht Logistik', { selector: 'td' })).not.toBeInTheDocument()
      })
      expect(main().getByText('1 offene Anfrage')).toBeInTheDocument()
      expect(nav().getByText('1 offene Anfrage')).toBeInTheDocument()
    })

    it('says so when the client withdrew the request in the meantime', async () => {
      const user = userEvent.setup()
      renderApp('/staff-requests')

      await screen.findByText('Nordlicht Logistik', { selector: 'td' })
      api.staffRequests = api.staffRequests.map((it) =>
        it.id === openRequest.id ? { ...it, status: StaffRequestStatus.WITHDRAWN } : it,
      )
      await user.click(screen.getByRole('button', { name: /Nordlicht Logistik .* ablehnen/ }))
      const dialog = within(await screen.findByRole('alertdialog'))
      await user.type(dialog.getByLabelText('Grund'), 'Ausgebucht.')
      await user.click(dialog.getByRole('button', { name: 'Ablehnen' }))

      expect(
        await screen.findByText(
          'Diese Anfrage wurde schon bearbeitet oder zurückgezogen. Die Liste wurde aktualisiert.',
        ),
      ).toBeInTheDocument()
      await waitFor(() => {
        expect(screen.queryByRole('alertdialog')).not.toBeInTheDocument()
      })
      await waitFor(() => {
        expect(screen.queryByText('Nordlicht Logistik', { selector: 'td' })).not.toBeInTheDocument()
      })
    })
  })

  describe('turning a request into a shift', () => {
    const created = () =>
      api.calls.find((call) => call.route === `POST /staff-requests/${galaRequest.id}/shift`)?.body

    it('opens the form filled in from the request and saves the shift to the request', async () => {
      const user = userEvent.setup()
      const { router } = renderApp('/staff-requests')

      await user.click(await screen.findByRole('link', { name: /Hafenhalle Events .* als Schicht anlegen/ }))

      expect(await screen.findByRole('heading', { name: 'Schicht aus Anfrage anlegen' })).toBeInTheDocument()
      expect(router.state.location.search).toBe(`?request=${galaRequest.id}`)
      expect(await screen.findByRole('alert')).toHaveTextContent(
        'Anfrage von Hafenhalle Events, gesendet von Paul Gruber am Di., 13.10.2026',
      )
      expect(await field('Kunde')).toHaveValue(hafenhalle.id)
      expect(await field('Einsatzort')).toHaveValue(hafenhalleLinz.id)
      expect(await field('Titel')).toHaveValue('Servicekräfte')
      expect(await field('Beschreibung')).toHaveValue('')
      expect(await field('Datum')).toHaveValue('2026-10-20')
      expect(await field('Beginn')).toHaveValue('18:00')
      expect(await field('Ende')).toHaveValue('01:00')
      expect(await field('Stundenlohn in Euro')).toHaveValue('')
      expect(await field('Plätze')).toHaveValue(6)

      await user.click(screen.getByRole('button', { name: 'Veröffentlichen' }))
      expect(await field('Stundenlohn in Euro')).toHaveAccessibleDescription('Bitte ausfüllen.')
      expect(created()).toBeUndefined()

      await user.type(await field('Stundenlohn in Euro'), '18,50')
      await user.click(screen.getByRole('button', { name: 'Veröffentlichen' }))

      expect(await screen.findByText('Servicekräfte wurde veröffentlicht')).toBeInTheDocument()
      expect(created()).toEqual({
        clientId: hafenhalle.id,
        locationId: hafenhalleLinz.id,
        title: 'Servicekräfte',
        startsAt: new Date(2026, 9, 20, 18, 0).toISOString(),
        endsAt: new Date(2026, 9, 21, 1, 0).toISOString(),
        endIsEstimate: false,
        hourlyRateCents: 1850,
        slots: 6,
        qualificationIds: [],
        publish: true,
      })
      expect(api.count('POST /shifts')).toBe(0)
      await waitFor(() => {
        expect(router.state.location.pathname).toBe('/shifts')
      })
      await waitFor(() => {
        expect(nav().getByText('1 offene Anfrage')).toBeInTheDocument()
      })
    })

    it('takes the notes as the description and the estimated end', async () => {
      renderApp(`/shifts/new?request=${openRequest.id}`)

      expect(await field('Beschreibung')).toHaveValue('Treffpunkt Tor 3, Sicherheitsschuhe mitbringen.')
      expect(await field('Kunde')).toHaveValue(nordlicht.id)
      expect(await field('Einsatzort')).toHaveValue(zentrallager.id)
      expect(screen.getByRole('checkbox', { name: /geschätzt/ })).toBeChecked()
      expect(await field('Plätze')).toHaveValue(3)
    })

    it('keeps the client of the request', async () => {
      const user = userEvent.setup()
      api.respondOnce(
        `POST /staff-requests/${galaRequest.id}/shift`,
        problem(400, 'validation_failed', [{ field: 'clientId', code: 'not_request_client' }]),
      )
      renderApp(`/shifts/new?request=${galaRequest.id}`)

      await user.type(await field('Stundenlohn in Euro'), '18,50')
      await user.click(screen.getByRole('button', { name: 'Veröffentlichen' }))

      expect(await field('Kunde')).toHaveAccessibleDescription(
        'Die Schicht muss für den Kunden der Anfrage sein.',
      )
      expect(await field('Kunde')).toHaveFocus()
    })

    it('goes back to the requests when the request is no longer open', async () => {
      const user = userEvent.setup()
      const { router } = renderApp(`/shifts/new?request=${galaRequest.id}`)

      await user.type(await field('Stundenlohn in Euro'), '18,50')
      api.staffRequests = api.staffRequests.map((it) =>
        it.id === galaRequest.id ? { ...it, status: StaffRequestStatus.WITHDRAWN } : it,
      )
      await user.click(screen.getByRole('button', { name: 'Veröffentlichen' }))

      expect(
        await screen.findByText(
          'Diese Anfrage ist nicht mehr offen: Der Kunde hat sie zurückgezogen oder sie wurde schon bearbeitet.',
        ),
      ).toBeInTheDocument()
      await waitFor(() => {
        expect(router.state.location.pathname).toBe('/staff-requests')
      })
      expect(api.shifts.some((it) => it.title === 'Servicekräfte')).toBe(false)
    })

    it('says so when the request was handled before the form opened', async () => {
      renderApp(`/shifts/new?request=${declinedRequest.id}`)

      expect(await screen.findByText('Anfrage schon bearbeitet')).toBeInTheDocument()
      expect(screen.queryByRole('button', { name: 'Veröffentlichen' })).not.toBeInTheDocument()
      expect(screen.getByRole('link', { name: 'Zu den Anfragen' })).toHaveAttribute('href', '/staff-requests')
    })

    it("says so for a request that doesn't exist", async () => {
      renderApp('/shifts/new?request=0199c3a0-0000-7000-8000-000000001199')

      expect(await screen.findByText('Anfrage nicht gefunden')).toBeInTheDocument()
    })
  })
})
