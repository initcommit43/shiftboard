import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it } from 'vitest'

import { ClientUserStatus } from '@/api/generated'
import { dispatcher, installFakeApi, nordlicht, problem, tobias } from '@/test/fake-api'
import { renderApp } from '@/test/render'

const SETUP_PATH = '/client-setup/tobias-first-code'

describe('client setup', () => {
  let api: ReturnType<typeof installFakeApi>

  beforeEach(() => {
    api = installFakeApi()
    api.features = { contactButton: false, checkIn: false, clientPortal: true }
  })

  async function choosePassword(password: string, confirmation = password) {
    const user = userEvent.setup()
    await user.type(await screen.findByLabelText('Passwort'), password)
    await user.type(screen.getByLabelText('Passwort wiederholen'), confirmation)
    await user.click(screen.getByRole('button', { name: 'Passwort festlegen und anmelden' }))
  }

  it('greets the invited user, sets the password and lands logged in on the portal', async () => {
    const { router } = renderApp(SETUP_PATH)

    expect(await screen.findByRole('heading', { name: 'Passwort festlegen' })).toBeInTheDocument()
    expect(
      screen.getByText(
        /Hallo Tobias, hier richtest du deinen Zugang zum Kundenportal von Donau Personal für Nordlicht Logistik ein/,
      ),
    ).toBeInTheDocument()
    expect(screen.getByLabelText('E-Mail')).toHaveValue(tobias.email)
    expect(screen.getByLabelText('E-Mail')).toHaveAttribute('autocomplete', 'username')
    expect(screen.getByLabelText('Passwort')).toHaveAttribute('autocomplete', 'new-password')

    await choosePassword('sicheres-passwort')

    expect(await screen.findByRole('heading', { name: 'Eure Schichten' })).toBeInTheDocument()
    expect(router.state.location.pathname).toBe('/portal')
    expect(api.calls.find((it) => it.route === 'POST /client-setup/tobias-first-code')?.body).toEqual({
      password: 'sicheres-passwort',
    })
    expect(within(screen.getByRole('banner')).getByText('Nordlicht Logistik')).toBeInTheDocument()
    // Logged in like after a login: the refresh token is kept for the next page load.
    expect(localStorage.getItem('shiftboard.refreshToken')).toBe('refresh-1')
    expect(api.clientUsers[nordlicht.id]?.find((it) => it.id === tobias.id)?.status).toBe(
      ClientUserStatus.ACTIVE,
    )
  })

  it('checks the length and the repetition before sending', async () => {
    renderApp(SETUP_PATH)

    await choosePassword('kurz')
    const password = screen.getByLabelText('Passwort')
    expect(password).toHaveAccessibleDescription('Das Passwort braucht mindestens 8 Zeichen.')
    expect(password).toHaveFocus()

    await userEvent.type(password, '-und-lang')
    expect(password).toHaveAccessibleDescription('Mindestens 8 Zeichen.')
    await userEvent.click(screen.getByRole('button', { name: 'Passwort festlegen und anmelden' }))
    expect(screen.getByLabelText('Passwort wiederholen')).toHaveAccessibleDescription(
      'Die Passwörter stimmen nicht überein.',
    )
    expect(api.count('POST /client-setup/tobias-first-code')).toBe(0)
  })

  it('shows a password the API rejects on the field', async () => {
    api.respondOnce(
      'POST /client-setup/tobias-first-code',
      problem(400, 'validation_failed', [{ field: 'password', code: 'invalid_length' }]),
    )
    renderApp(SETUP_PATH)

    await choosePassword('sicheres-passwort')

    await waitFor(() => {
      expect(screen.getByLabelText('Passwort')).toHaveAccessibleDescription(
        'Das Passwort braucht mindestens 8 Zeichen.',
      )
    })
  })

  it('explains an unknown, expired or used link', async () => {
    renderApp('/client-setup/used-up-code')

    expect(await screen.findByRole('heading', { name: 'Dieser Link funktioniert nicht' })).toBeInTheDocument()
    expect(screen.getByText(/Bitte deine Ansprechperson bei der Agentur um einen neuen Link/)).toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Zur Anmeldung' })).toHaveAttribute('href', '/login')
    expect(screen.queryByLabelText('Passwort')).not.toBeInTheDocument()
  })

  it('explains a link that ran out while the form was open', async () => {
    renderApp(SETUP_PATH)
    await screen.findByLabelText('Passwort')
    api.setupCodes = {}

    await choosePassword('sicheres-passwort')

    expect(await screen.findByRole('alert')).toHaveTextContent(
      'Dieser Link ist ungültig, abgelaufen oder wurde schon verwendet.',
    )
  })

  it('explains that the client portal is switched off', async () => {
    api.features = { contactButton: false, checkIn: false, clientPortal: false }
    renderApp(SETUP_PATH)

    expect(await screen.findByRole('heading', { name: 'Das Kundenportal ist nicht verfügbar' })).toBeInTheDocument()
    expect(screen.queryByLabelText('Passwort')).not.toBeInTheDocument()
  })

  it('takes over from a session of someone else in this browser', async () => {
    api.signIn()
    const { router } = renderApp(SETUP_PATH)

    await choosePassword('sicheres-passwort')

    expect(await screen.findByRole('heading', { name: 'Eure Schichten' })).toBeInTheDocument()
    expect(router.state.location.pathname).toBe('/portal')
    expect(api.user.email).not.toBe(dispatcher.email)
  })
})
