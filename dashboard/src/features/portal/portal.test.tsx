import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it } from 'vitest'

import { ClientUserStatus } from '@/api/generated'
import {
  clientContact,
  clientShift,
  dispatcher,
  installFakeApi,
  nordlicht,
  PASSWORD,
  petra,
  portalFair,
  portalInventory,
  portalNewYear,
  portalUnloading,
  portalWarehouse,
} from '@/test/fake-api'
import { renderApp } from '@/test/render'

describe('client portal', () => {
  let api: ReturnType<typeof installFakeApi>

  beforeEach(() => {
    api = installFakeApi()
    api.user = clientContact
    api.features = { contactButton: false, checkIn: false, clientPortal: true }
  })

  async function submitLogin(email = clientContact.email) {
    const user = userEvent.setup()
    await user.type(await screen.findByLabelText('E-Mail'), email)
    await user.type(screen.getByLabelText('Passwort'), PASSWORD)
    await user.click(screen.getByRole('button', { name: 'Anmelden' }))
  }

  function row(title: string) {
    const found = screen.getByRole('link', { name: title }).closest('tr')
    if (!found) {
      throw new Error(`No row for ${title}`)
    }
    return within(found)
  }

  /** Requests the agency's side of the dashboard would make. */
  function staffCalls() {
    return api.calls.filter(
      (it) =>
        !it.route.startsWith('GET /client/') &&
        !['POST /auth/login', 'POST /auth/refresh', 'POST /auth/logout', 'GET /me'].includes(it.route),
    )
  }

  describe('login', () => {
    it('takes a client user from the login to their portal, without the agency navigation', async () => {
      const { router } = renderApp('/')

      await submitLogin()

      expect(await screen.findByRole('heading', { name: 'Eure Schichten' })).toBeInTheDocument()
      expect(router.state.location.pathname).toBe('/portal')
      const header = within(screen.getByRole('banner'))
      expect(header.getByText('Nordlicht Logistik')).toBeInTheDocument()
      expect(header.getByText('Kundenportal von Donau Personal')).toBeInTheDocument()
      expect(header.getByText('Kundenzugang')).toBeInTheDocument()
      expect(screen.queryByRole('navigation', { name: 'Hauptnavigation' })).not.toBeInTheDocument()
      // No staff queries: no signups, unread counts or features.
      expect(staffCalls()).toEqual([])
    })

    it('explains that the client portal is switched off', async () => {
      api.features = { contactButton: false, checkIn: false, clientPortal: false }
      renderApp('/login')

      await submitLogin()

      expect(await screen.findByRole('alert')).toHaveTextContent(
        'Das Kundenportal ist derzeit ausgeschaltet. Bitte wende dich an die Agentur.',
      )
      expect(screen.getByRole('heading', { name: 'Anmelden' })).toBeInTheDocument()
    })

    it('explains that the access has been ended', async () => {
      api.clientUsers[nordlicht.id] = [{ ...petra, status: ClientUserStatus.DEACTIVATED }]
      renderApp('/login')

      await submitLogin()

      expect(await screen.findByRole('alert')).toHaveTextContent(
        'Dein Zugang wurde beendet. Wenn du wieder Zugang brauchst, wende dich an die Agentur.',
      )
    })

    it('logs out from the portal', async () => {
      api.signIn()
      const user = userEvent.setup()
      const { router } = renderApp('/portal')

      await user.click(await screen.findByRole('button', { name: 'Benutzermenü' }))
      await user.click(await screen.findByRole('menuitem', { name: 'Abmelden' }))

      expect(await screen.findByRole('heading', { name: 'Anmelden' })).toBeInTheDocument()
      expect(router.state.location.pathname).toBe('/login')
      expect(localStorage.getItem('shiftboard.refreshToken')).toBeNull()
    })
  })

  describe('route guards', () => {
    it.each(['/settings', '/signups', `/shifts/${portalWarehouse.id}`, `/clients/${nordlicht.id}`])(
      'sends a client user from %s to the portal',
      async (path) => {
        api.signIn()
        const { router } = renderApp(path)

        expect(await screen.findByRole('heading', { name: 'Eure Schichten' })).toBeInTheDocument()
        expect(router.state.location.pathname).toBe('/portal')
        expect(staffCalls()).toEqual([])
      },
    )

    it('brings a client user back to a portal deep link after the login', async () => {
      const { router } = renderApp(`/portal/shifts/${portalWarehouse.id}`)

      await submitLogin()

      expect(await screen.findByRole('heading', { name: 'Lagerunterstützung' })).toBeInTheDocument()
      expect(router.state.location.pathname).toBe(`/portal/shifts/${portalWarehouse.id}`)
    })

    it('sends the agency from the portal to the dashboard', async () => {
      api.user = dispatcher
      api.signIn()
      const { router } = renderApp(`/portal/shifts/${portalWarehouse.id}`)

      expect(await screen.findByRole('heading', { name: 'Anmeldungen' })).toBeInTheDocument()
      expect(router.state.location.pathname).toBe('/signups')
      expect(api.count('GET /client/shifts')).toBe(0)
    })

    it('ends the session when the client portal is switched off', async () => {
      api.signIn()
      api.features = { contactButton: false, checkIn: false, clientPortal: false }
      const { router } = renderApp('/portal')

      expect(await screen.findByRole('heading', { name: 'Anmelden' })).toBeInTheDocument()
      expect(router.state.location.pathname).toBe('/login')
    })
  })

  describe('shifts', () => {
    beforeEach(() => {
      api.signIn()
    })

    it('lists the upcoming shifts with times, location, status and fill status', async () => {
      renderApp('/portal')

      expect(await screen.findByRole('link', { name: 'Lagerunterstützung' })).toBeInTheDocument()
      expect(api.queries('GET /client/shifts')[0]?.get('period')).toBe('UPCOMING')

      const warehouse = row('Lagerunterstützung')
      expect(warehouse.getByText('Zentrallager Linz')).toBeInTheDocument()
      expect(warehouse.getByText('Do., 15.10.2026')).toBeInTheDocument()
      expect(warehouse.getByText('08:00 – ca. 16:00')).toBeInTheDocument()
      expect(warehouse.getByText('Geplant')).toBeInTheDocument()
      expect(warehouse.getByText('4 von 5')).toBeInTheDocument()

      const inventory = row('Nachtinventur')
      expect(inventory.getByText('Voll')).toBeInTheDocument()
      expect(inventory.getByText('22:00 – Di., 06:00')).toBeInTheDocument()

      const unloading = row('Wareneingang')
      expect(unloading.getByText('Abgesagt')).toBeInTheDocument()
      expect(unloading.queryByText('0 von 3')).not.toBeInTheDocument()

      expect(row('Inventur Jahresende').getByText('0 von 3')).toBeInTheDocument()
      expect(screen.getByText('4 anstehende Schichten')).toBeInTheDocument()
    })

    it('never shows an hourly rate', async () => {
      renderApp('/portal')

      await screen.findByRole('link', { name: 'Lagerunterstützung' })
      expect(screen.queryByText(/€/)).not.toBeInTheDocument()
      expect(screen.queryByText('Stundenlohn')).not.toBeInTheDocument()
    })

    it('switches to the past shifts', async () => {
      const user = userEvent.setup()
      const { router } = renderApp('/portal')

      const tabs = within(await screen.findByRole('navigation', { name: 'Zeitraum' }))
      expect(tabs.getByRole('link', { name: 'Anstehend' })).toHaveAttribute('aria-current', 'page')
      await user.click(tabs.getByRole('link', { name: 'Vergangen' }))

      expect(await screen.findByRole('link', { name: 'Messeaufbau' })).toBeInTheDocument()
      expect(router.state.location.search).toBe('?period=past')
      expect(api.queries('GET /client/shifts').at(-1)?.get('period')).toBe('PAST')
      expect(row('Messeaufbau').getByText('Vorbei')).toBeInTheDocument()
      expect(row('Messeaufbau').getByText('Voll')).toBeInTheDocument()
      expect(screen.getByText('1 vergangene Schicht')).toBeInTheDocument()
      expect(screen.queryByRole('link', { name: 'Lagerunterstützung' })).not.toBeInTheDocument()
    })

    it('pages through many shifts', async () => {
      const user = userEvent.setup()
      api.clientShifts = Array.from({ length: 25 }, (_, index) =>
        clientShift(index + 20, { title: `Schicht ${String(index + 1)}` }),
      )
      renderApp('/portal')

      expect(await screen.findByRole('link', { name: 'Schicht 1' })).toBeInTheDocument()
      await user.click(screen.getByRole('button', { name: 'Weiter' }))

      expect(await screen.findByRole('link', { name: 'Schicht 21' })).toBeInTheDocument()
      expect(screen.getByText('Seite 2 von 2')).toBeInTheDocument()
    })

    it('shows empty states for both periods', async () => {
      const user = userEvent.setup()
      api.clientShifts = []
      api.pastClientShifts = []
      renderApp('/portal')

      expect(await screen.findByText('Keine anstehenden Schichten')).toBeInTheDocument()
      await user.click(screen.getByRole('link', { name: 'Vergangen' }))
      expect(await screen.findByText('Noch keine vergangenen Schichten')).toBeInTheDocument()
    })

    it('shows an error and recovers on retry', async () => {
      const user = userEvent.setup()
      api.respondOnce('GET /client/shifts', new Response(null, { status: 500 }))
      renderApp('/portal')

      await user.click(await screen.findByRole('button', { name: 'Erneut versuchen' }))

      expect(await screen.findByRole('link', { name: 'Lagerunterstützung' })).toBeInTheDocument()
    })
  })

  describe('a shift', () => {
    beforeEach(() => {
      api.signIn()
    })

    it('shows the details and the names of the confirmed workers', async () => {
      const user = userEvent.setup()
      const { router } = renderApp('/portal')

      await user.click(await screen.findByRole('link', { name: 'Lagerunterstützung' }))

      expect(await screen.findByRole('heading', { name: 'Lagerunterstützung' })).toBeInTheDocument()
      expect(router.state.location.pathname).toBe(`/portal/shifts/${portalWarehouse.id}`)
      expect(screen.getByText('Zentrallager Linz, Industriezeile 40, 4020 Linz')).toBeInTheDocument()
      expect(screen.getByText('Sicherheitsschuhe mitbringen. Treffpunkt ist Tor 3.')).toBeInTheDocument()
      expect(screen.getByText('4 von 5')).toBeInTheDocument()
      const team = within(screen.getByRole('list', { name: 'Wer kommt' }))
      expect(team.getAllByRole('listitem').map((it) => it.textContent)).toEqual([
        'MAMira Aigner',
        'LHLena Hofer',
        'SHSophie Huber',
        'JSJakob Steiner',
      ])
    })

    it('says when nobody is confirmed yet', async () => {
      renderApp(`/portal/shifts/${portalNewYear.id}`)

      expect(await screen.findByRole('heading', { name: 'Inventur Jahresende' })).toBeInTheDocument()
      expect(screen.getByText('Noch niemand bestätigt')).toBeInTheDocument()
      expect(screen.queryByRole('list', { name: 'Wer kommt' })).not.toBeInTheDocument()
    })

    it('shows a full shift as full', async () => {
      renderApp(`/portal/shifts/${portalInventory.id}`)

      expect(await screen.findByText('Voll')).toBeInTheDocument()
      expect(screen.getAllByRole('listitem')).toHaveLength(2)
    })

    it('shows a cancelled shift as cancelled', async () => {
      renderApp(`/portal/shifts/${portalUnloading.id}`)

      expect(await screen.findByRole('alert')).toHaveTextContent('Diese Schicht wurde abgesagt.')
      expect(screen.getByText('Abgesagt')).toBeInTheDocument()
      expect(screen.queryByRole('heading', { name: 'Wer kommt' })).not.toBeInTheDocument()
    })

    it('goes back to the list', async () => {
      const user = userEvent.setup()
      const { router } = renderApp(`/portal/shifts/${portalFair.id}`)

      await user.click(await screen.findByRole('link', { name: 'Alle Schichten' }))

      await waitFor(() => {
        expect(router.state.location.pathname).toBe('/portal')
      })
    })

    it("says so for a shift the client can't see", async () => {
      renderApp('/portal/shifts/0199c3a0-0000-7000-8000-000000001099')

      expect(await screen.findByText('Schicht nicht gefunden')).toBeInTheDocument()
    })
  })
})
