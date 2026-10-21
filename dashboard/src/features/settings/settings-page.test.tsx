import { screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it } from 'vitest'

import { dispatcher, installFakeApi, problem } from '@/test/fake-api'
import { renderApp } from '@/test/render'

describe('agency settings', () => {
  let api: ReturnType<typeof installFakeApi>

  beforeEach(() => {
    api = installFakeApi()
  })

  function signInAs(role: 'ADMIN' | 'DISPATCHER') {
    api.user = { ...dispatcher, role }
    api.signIn()
  }

  it('shows the defaults: approval required and 24 hours', async () => {
    signInAs('ADMIN')
    renderApp('/settings')

    expect(await screen.findByLabelText('Anfragen automatisch bestätigen')).not.toBeChecked()
    expect(screen.getByLabelText('Absagefrist in Stunden')).toHaveValue(24)
  })

  it('lets an admin switch on auto-confirm and change the deadline', async () => {
    const user = userEvent.setup()
    signInAs('ADMIN')
    renderApp('/settings')

    await user.click(await screen.findByLabelText('Anfragen automatisch bestätigen'))
    const deadline = screen.getByLabelText('Absagefrist in Stunden')
    await user.clear(deadline)
    await user.type(deadline, '48')
    await user.click(screen.getByRole('button', { name: 'Speichern' }))

    expect(await screen.findByText('Die Einstellungen sind gespeichert')).toBeInTheDocument()
    expect(api.settings).toEqual({ autoConfirm: true, cancellationDeadlineHours: 48 })
  })

  it('checks the deadline before saving', async () => {
    const user = userEvent.setup()
    signInAs('ADMIN')
    renderApp('/settings')

    const deadline = await screen.findByLabelText('Absagefrist in Stunden')
    await user.clear(deadline)
    await user.type(deadline, '400')
    await user.click(screen.getByRole('button', { name: 'Speichern' }))

    expect(screen.getByText('Eine ganze Zahl zwischen 0 und 336.')).toBeInTheDocument()
    expect(deadline).toHaveFocus()
    expect(api.count('PUT /agency/settings')).toBe(0)
  })

  it('shows dispatchers the settings without letting them change them', async () => {
    signInAs('DISPATCHER')
    renderApp('/settings')

    expect(await screen.findByText('Nur Admins können die Einstellungen ändern.')).toBeInTheDocument()
    expect(screen.getByLabelText('Anfragen automatisch bestätigen')).toBeDisabled()
    expect(screen.getByLabelText('Absagefrist in Stunden')).toBeDisabled()
    expect(screen.queryByRole('button', { name: 'Speichern' })).not.toBeInTheDocument()
  })

  it('lets an admin switch on the WhatsApp contact', async () => {
    const user = userEvent.setup()
    signInAs('ADMIN')
    renderApp('/settings')

    const toggle = await screen.findByLabelText('WhatsApp-Kontakt anzeigen')
    expect(toggle).not.toBeChecked()
    await user.click(toggle)
    await user.click(screen.getByRole('button', { name: 'Zusatzfunktionen speichern' }))

    expect(await screen.findByText('Die Zusatzfunktionen sind gespeichert')).toBeInTheDocument()
    expect(api.features).toEqual({ contactButton: true, checkIn: false })
    expect(api.count('PUT /agency/features')).toBe(1)
    expect(api.count('PUT /agency/settings')).toBe(0)
  })

  it('lets an admin switch on check-in in the app and sends both features', async () => {
    const user = userEvent.setup()
    signInAs('ADMIN')
    api.features = { contactButton: true, checkIn: false }
    renderApp('/settings')

    const toggle = await screen.findByLabelText('Einchecken in der App')
    expect(toggle).not.toBeChecked()
    expect(toggle).toHaveAccessibleDescription(/Ohne diese Funktion werden die Stunden nach den geplanten Zeiten freigegeben/)
    await user.click(toggle)
    await user.click(screen.getByRole('button', { name: 'Zusatzfunktionen speichern' }))

    await waitFor(() => {
      expect(api.features).toEqual({ contactButton: true, checkIn: true })
    })
  })

  it('shows dispatchers the check-in switch without letting them change it', async () => {
    signInAs('DISPATCHER')
    api.features = { contactButton: false, checkIn: true }
    renderApp('/settings')

    const toggle = await screen.findByLabelText('Einchecken in der App')
    expect(toggle).toBeChecked()
    expect(toggle).toBeDisabled()
    expect(screen.queryByRole('button', { name: 'Zusatzfunktionen speichern' })).not.toBeInTheDocument()
  })

  it('shows an error and recovers on retry', async () => {
    const user = userEvent.setup()
    signInAs('ADMIN')
    api.respondOnce('GET /agency/settings', problem(500, 'internal_error'))
    renderApp('/settings')

    await user.click(await screen.findByRole('button', { name: 'Erneut versuchen' }))

    expect(await screen.findByLabelText('Absagefrist in Stunden')).toHaveValue(24)
  })
})
