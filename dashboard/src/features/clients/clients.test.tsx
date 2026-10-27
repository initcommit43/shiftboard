import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it } from 'vitest'

import { ClientUserStatus } from '@/api/generated'
import { dispatcher, hafenhalle, installFakeApi, nordlicht, petra, problem, tobias } from '@/test/fake-api'
import { renderApp } from '@/test/render'

describe('client users', () => {
  let api: ReturnType<typeof installFakeApi>

  beforeEach(() => {
    api = installFakeApi()
    api.features = { contactButton: false, checkIn: false, clientPortal: true }
    api.signIn()
  })

  function row(name: string) {
    const cell = screen.getByRole('cell', { name })
    const found = cell.closest('tr')
    if (!found) {
      throw new Error(`No row for ${name}`)
    }
    return within(found)
  }

  describe('navigation', () => {
    it('offers the clients while the client portal is on', async () => {
      const user = userEvent.setup()
      const { router } = renderApp('/signups')

      const navigation = await screen.findByRole('navigation', { name: 'Hauptnavigation' })
      await user.click(await within(navigation).findByRole('link', { name: 'Kunden' }))

      expect(await screen.findByRole('heading', { name: 'Kunden' })).toBeInTheDocument()
      expect(router.state.location.pathname).toBe('/clients')
      expect(await screen.findByRole('link', { name: 'Nordlicht Logistik' })).toBeInTheDocument()
      expect(screen.getByRole('cell', { name: 'Umschlaglager Wels, Zentrallager Linz' })).toBeInTheDocument()
      expect(screen.getByText('2 Kunden')).toBeInTheDocument()
    })

    it('hides the clients while the client portal is off', async () => {
      api.features = { contactButton: false, checkIn: false, clientPortal: false }
      renderApp('/signups')

      const navigation = await screen.findByRole('navigation', { name: 'Hauptnavigation' })
      expect(await within(navigation).findByRole('link', { name: 'Einstellungen' })).toBeInTheDocument()
      await waitFor(() => {
        expect(api.count('GET /agency/features')).toBe(1)
      })
      expect(within(navigation).queryByRole('link', { name: 'Kunden' })).not.toBeInTheDocument()
    })

    it('explains a deep link while the client portal is off and loads no client users', async () => {
      api.features = { contactButton: false, checkIn: false, clientPortal: false }
      renderApp(`/clients/${nordlicht.id}`)

      expect(await screen.findByText('Das Kundenportal ist ausgeschaltet')).toBeInTheDocument()
      expect(screen.getByText(/Ein Admin kann es in den Einstellungen/)).toBeInTheDocument()
      expect(api.count(`GET /clients/${nordlicht.id}/users`)).toBe(0)
    })

    it('points admins to the settings while the client portal is off', async () => {
      api.user = { ...dispatcher, role: 'ADMIN' }
      api.features = { contactButton: false, checkIn: false, clientPortal: false }
      renderApp('/clients')

      expect(await screen.findByRole('link', { name: 'Zu den Einstellungen' })).toHaveAttribute('href', '/settings')
    })
  })

  describe('a client', () => {
    it("lists the client's users with their status", async () => {
      renderApp(`/clients/${nordlicht.id}`)

      expect(await screen.findByRole('heading', { name: 'Nordlicht Logistik' })).toBeInTheDocument()
      expect(await screen.findByRole('cell', { name: 'Petra Lindner' })).toBeInTheDocument()
      expect(row('Petra Lindner').getByText('petra.lindner@nordlicht.example')).toBeInTheDocument()
      expect(row('Petra Lindner').getByText('Aktiv')).toBeInTheDocument()
      expect(row('Tobias Wallner').getByText('Eingeladen')).toBeInTheDocument()
      // A new link only for someone who hasn't set a password yet.
      expect(row('Petra Lindner').queryByRole('button', { name: /Neuen Link/ })).not.toBeInTheDocument()
      expect(row('Tobias Wallner').getByRole('button', { name: 'Neuen Link für Tobias Wallner erstellen' })).toBeInTheDocument()
    })

    it('shows deactivated users without actions', async () => {
      api.clientUsers[nordlicht.id] = [{ ...petra, status: ClientUserStatus.DEACTIVATED }]
      renderApp(`/clients/${nordlicht.id}`)

      expect(await screen.findByText('Deaktiviert')).toBeInTheDocument()
      expect(row('Petra Lindner').queryByRole('button')).not.toBeInTheDocument()
    })

    it('shows an empty state for a client without users', async () => {
      renderApp(`/clients/${hafenhalle.id}`)

      expect(await screen.findByText('Noch keine Zugänge')).toBeInTheDocument()
      expect(screen.getByRole('button', { name: 'Zugang anlegen' })).toBeInTheDocument()
    })

    it('says so when the client does not exist', async () => {
      renderApp('/clients/0199c3a0-0000-7000-8000-000000000399')

      expect(await screen.findByText('Kunde nicht gefunden')).toBeInTheDocument()
    })

    it('shows an error and recovers on retry', async () => {
      const user = userEvent.setup()
      api.respondOnce(`GET /clients/${nordlicht.id}/users`, problem(500, 'internal_error'))
      renderApp(`/clients/${nordlicht.id}`)

      expect(await screen.findByText('Die Zugänge konnten nicht geladen werden')).toBeInTheDocument()
      await user.click(screen.getByRole('button', { name: 'Erneut versuchen' }))

      expect(await screen.findByRole('cell', { name: 'Petra Lindner' })).toBeInTheDocument()
    })
  })

  describe('giving access', () => {
    async function openInvite() {
      const user = userEvent.setup()
      renderApp(`/clients/${nordlicht.id}`)
      await screen.findByRole('cell', { name: 'Petra Lindner' })
      await user.click(screen.getByRole('button', { name: 'Zugang anlegen' }))
      return { user, dialog: within(await screen.findByRole('alertdialog')) }
    }

    it('invites a user and shows the setup link to copy', async () => {
      const { user, dialog } = await openInvite()

      await user.type(dialog.getByLabelText('Vorname'), 'Sabine')
      await user.type(dialog.getByLabelText('Nachname'), 'Auer')
      await user.type(dialog.getByLabelText('E-Mail'), 'sabine.auer@nordlicht.example')
      await user.click(dialog.getByRole('button', { name: 'Zugang anlegen' }))

      const link = `${window.location.origin}/client-setup/setup-code-1`
      expect(await dialog.findByRole('heading', { name: 'Link für Sabine Auer' })).toBeInTheDocument()
      expect(dialog.getByLabelText('Link zum Passwort setzen')).toHaveValue(link)
      expect(dialog.getByText(/funktioniert einmal und gilt bis 22\.10\.2026, 14:30/)).toBeInTheDocument()
      expect(api.calls.find((it) => it.route === `POST /clients/${nordlicht.id}/users`)?.body).toEqual({
        firstName: 'Sabine',
        lastName: 'Auer',
        email: 'sabine.auer@nordlicht.example',
      })

      await user.click(dialog.getByRole('button', { name: 'Kopieren' }))
      expect(await screen.findByText('Link kopiert')).toBeInTheDocument()
      expect(await navigator.clipboard.readText()).toBe(link)

      await user.click(dialog.getByRole('button', { name: 'Fertig' }))
      expect(screen.queryByRole('alertdialog')).not.toBeInTheDocument()
      expect(await screen.findByRole('cell', { name: 'Sabine Auer' })).toBeInTheDocument()
      expect(row('Sabine Auer').getByText('Eingeladen')).toBeInTheDocument()
    })

    it('checks the required fields before sending', async () => {
      const { user, dialog } = await openInvite()

      await user.type(dialog.getByLabelText('Vorname'), 'Sabine')
      await user.click(dialog.getByRole('button', { name: 'Zugang anlegen' }))

      expect(dialog.getByLabelText('Nachname')).toHaveAccessibleDescription('Bitte ausfüllen.')
      expect(dialog.getByLabelText('Nachname')).toHaveFocus()
      expect(dialog.getByLabelText('E-Mail')).toHaveAttribute('aria-invalid', 'true')
      expect(dialog.getByLabelText('Vorname')).not.toHaveAttribute('aria-invalid', 'true')
      expect(api.count(`POST /clients/${nordlicht.id}/users`)).toBe(0)
    })

    it('shows the field errors of the problem details', async () => {
      const { user, dialog } = await openInvite()

      await user.type(dialog.getByLabelText('Vorname'), 'Sabine')
      await user.type(dialog.getByLabelText('Nachname'), 'Auer')
      await user.type(dialog.getByLabelText('E-Mail'), 'sabine.auer')
      await user.click(dialog.getByRole('button', { name: 'Zugang anlegen' }))

      const email = dialog.getByLabelText('E-Mail')
      await waitFor(() => {
        expect(email).toHaveAccessibleDescription('Bitte gib eine gültige E-Mail-Adresse ein.')
      })
      expect(email).toHaveFocus()

      await user.type(email, '@nordlicht.example')
      expect(email).not.toHaveAttribute('aria-invalid', 'true')
    })

    it('says when the email address already has an account', async () => {
      const { user, dialog } = await openInvite()

      await user.type(dialog.getByLabelText('Vorname'), 'Petra')
      await user.type(dialog.getByLabelText('Nachname'), 'Lindner')
      await user.type(dialog.getByLabelText('E-Mail'), petra.email)
      await user.click(dialog.getByRole('button', { name: 'Zugang anlegen' }))

      await waitFor(() => {
        expect(dialog.getByLabelText('E-Mail')).toHaveAccessibleDescription(
          'Mit dieser E-Mail-Adresse gibt es schon ein Konto.',
        )
      })
    })

    it('says when the client portal was switched off in the meantime', async () => {
      const { user, dialog } = await openInvite()
      api.features = { ...api.features, clientPortal: false }

      await user.type(dialog.getByLabelText('Vorname'), 'Sabine')
      await user.type(dialog.getByLabelText('Nachname'), 'Auer')
      await user.type(dialog.getByLabelText('E-Mail'), 'sabine.auer@nordlicht.example')
      await user.click(dialog.getByRole('button', { name: 'Zugang anlegen' }))

      expect(await dialog.findByRole('alert')).toHaveTextContent('Das Kundenportal ist ausgeschaltet.')
    })
  })

  describe('managing access', () => {
    it('creates a new link for an invited user', async () => {
      const user = userEvent.setup()
      renderApp(`/clients/${nordlicht.id}`)

      await user.click(await screen.findByRole('button', { name: 'Neuen Link für Tobias Wallner erstellen' }))

      const dialog = within(await screen.findByRole('alertdialog'))
      expect(dialog.getByRole('heading', { name: 'Link für Tobias Wallner' })).toBeInTheDocument()
      expect(dialog.getByText(/Der bisherige Link funktioniert nicht mehr/)).toBeInTheDocument()
      expect(dialog.getByLabelText('Link zum Passwort setzen')).toHaveValue(
        `${window.location.origin}/client-setup/setup-code-1`,
      )
      expect(api.setupCodes).toEqual({ 'setup-code-1': { clientId: nordlicht.id, userId: tobias.id } })
    })

    it('explains when a user set their password before the new link was made', async () => {
      const user = userEvent.setup()
      renderApp(`/clients/${nordlicht.id}`)
      const renew = await screen.findByRole('button', { name: 'Neuen Link für Tobias Wallner erstellen' })
      api.clientUsers[nordlicht.id] = [petra, { ...tobias, status: ClientUserStatus.ACTIVE }]

      await user.click(renew)

      expect(await screen.findByText(/hat schon ein Passwort gesetzt/)).toBeInTheDocument()
      expect(screen.queryByRole('alertdialog')).not.toBeInTheDocument()
      await waitFor(() => {
        expect(row('Tobias Wallner').getByText('Aktiv')).toBeInTheDocument()
      })
    })

    it('ends access after a confirmation', async () => {
      const user = userEvent.setup()
      renderApp(`/clients/${nordlicht.id}`)

      await user.click(await screen.findByRole('button', { name: 'Zugang von Petra Lindner beenden' }))
      const dialog = within(await screen.findByRole('alertdialog'))
      expect(dialog.getByText(/wird auf allen Geräten abgemeldet/)).toBeInTheDocument()
      await user.click(dialog.getByRole('button', { name: 'Zugang beenden' }))

      expect(await screen.findByText('Zugang von Petra Lindner beendet')).toBeInTheDocument()
      await waitFor(() => {
        expect(row('Petra Lindner').getByText('Deaktiviert')).toBeInTheDocument()
      })
      expect(api.count(`POST /clients/${nordlicht.id}/users/${petra.id}/deactivate`)).toBe(1)
    })

    it('keeps access when the confirmation is cancelled', async () => {
      const user = userEvent.setup()
      renderApp(`/clients/${nordlicht.id}`)

      await user.click(await screen.findByRole('button', { name: 'Zugang von Tobias Wallner beenden' }))
      await user.click(within(await screen.findByRole('alertdialog')).getByRole('button', { name: 'Abbrechen' }))

      expect(screen.queryByRole('alertdialog')).not.toBeInTheDocument()
      expect(api.count(`POST /clients/${nordlicht.id}/users/${tobias.id}/deactivate`)).toBe(0)
      expect(row('Tobias Wallner').getByText('Eingeladen')).toBeInTheDocument()
    })
  })
})
