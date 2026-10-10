import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it } from 'vitest'

import { dispatcher, installFakeApi, PASSWORD, problem } from '@/test/fake-api'
import { renderApp } from '@/test/render'

describe('authentication', () => {
  let api: ReturnType<typeof installFakeApi>

  beforeEach(() => {
    api = installFakeApi()
  })

  async function submitLogin(password = PASSWORD) {
    const user = userEvent.setup()
    await user.type(await screen.findByLabelText('E-Mail'), dispatcher.email)
    await user.type(screen.getByLabelText('Passwort'), password)
    await user.click(screen.getByRole('button', { name: 'Anmelden' }))
  }

  describe('login', () => {
    it('logs in and lands on the signups', async () => {
      const { router } = renderApp('/')

      await submitLogin()

      expect(await screen.findByRole('heading', { name: 'Anmeldungen' })).toBeInTheDocument()
      expect(router.state.location.pathname).toBe('/signups')
      expect(api.calls[0]).toEqual({
        route: 'POST /auth/login',
        body: { email: dispatcher.email, password: PASSWORD, client: 'DASHBOARD' },
      })
    })

    it('offers password managers the right fields and points workers to the app', async () => {
      renderApp('/login')

      expect(await screen.findByLabelText('E-Mail')).toHaveAttribute('autocomplete', 'username')
      expect(screen.getByLabelText('Passwort')).toHaveAttribute('autocomplete', 'current-password')
      expect(screen.getByLabelText('Passwort')).toHaveAttribute('type', 'password')
      expect(
        screen.getByText('Du bist Mitarbeiter:in? Deine Schichten findest du in der shiftboard App.'),
      ).toBeInTheDocument()
    })

    it('shows one generic error for wrong credentials and keeps the input', async () => {
      renderApp('/login')

      await submitLogin('wrong-password')

      expect(await screen.findByRole('alert')).toHaveTextContent('E-Mail oder Passwort ist falsch.')
      expect(screen.getByLabelText('E-Mail')).toHaveValue(dispatcher.email)
      expect(screen.getByLabelText('E-Mail')).not.toHaveAttribute('aria-invalid')
    })

    it('shows the same error to an account that belongs to the worker app', async () => {
      api.respondOnce('POST /auth/login', problem(403, 'wrong_client'))
      renderApp('/login')

      await submitLogin()

      expect(await screen.findByRole('alert')).toHaveTextContent('E-Mail oder Passwort ist falsch.')
      expect(screen.getByRole('heading', { name: 'Anmelden' })).toBeInTheDocument()
    })

    it('explains the rate limit', async () => {
      api.respondOnce('POST /auth/login', problem(429, 'too_many_attempts'))
      renderApp('/login')

      await submitLogin()

      expect(await screen.findByRole('alert')).toHaveTextContent('Zu viele Anmeldeversuche.')
    })

    it('explains a failed connection', async () => {
      api.respondOnce('POST /auth/login', new TypeError('Failed to fetch'))
      renderApp('/login')

      await submitLogin()

      expect(await screen.findByRole('alert')).toHaveTextContent('Der Server ist nicht erreichbar.')
    })

    it('falls back to a generic message for unknown errors', async () => {
      api.respondOnce('POST /auth/login', problem(500, 'something_new'))
      renderApp('/login')

      await submitLogin()

      expect(await screen.findByRole('alert')).toHaveTextContent('Etwas ist schiefgelaufen.')
    })

    it('disables the button while the login is running', async () => {
      let answer: (response: Response) => void = () => undefined
      api.respondOnce(
        'POST /auth/login',
        new Promise<Response>((resolve) => {
          answer = resolve
        }),
      )
      renderApp('/login')

      await submitLogin()

      expect(screen.getByRole('button', { name: 'Anmelden' })).toBeDisabled()

      answer(problem(401, 'invalid_credentials'))

      await waitFor(() => {
        expect(screen.getByRole('button', { name: 'Anmelden' })).toBeEnabled()
      })
    })
  })

  describe('route guard', () => {
    it('sends a visitor to the login and back to the requested page', async () => {
      const { router } = renderApp('/settings')

      expect(await screen.findByRole('heading', { name: 'Anmelden' })).toBeInTheDocument()
      expect(router.state.location.pathname).toBe('/login')

      await submitLogin()

      expect(await screen.findByRole('heading', { name: 'Einstellungen' })).toBeInTheDocument()
      expect(router.state.location.pathname).toBe('/settings')
    })

    it('ignores a return address outside the app', async () => {
      const { router } = renderApp('/login?redirectTo=//example.com')

      await submitLogin()

      expect(await screen.findByRole('heading', { name: 'Anmeldungen' })).toBeInTheDocument()
      expect(router.state.location.pathname).toBe('/signups')
    })

    it('takes a signed-in user from the login into the app', async () => {
      api.signIn()
      const { router } = renderApp('/login')

      expect(await screen.findByRole('heading', { name: 'Anmeldungen' })).toBeInTheDocument()
      expect(router.state.location.pathname).toBe('/signups')
    })
  })

  describe('session', () => {
    it('restores the session after a page load before rendering the page', async () => {
      api.signIn()
      renderApp('/signups')

      expect(screen.getByRole('status', { name: 'Sitzung wird geladen …' })).toBeInTheDocument()

      expect(await screen.findByRole('heading', { name: 'Anmeldungen' })).toBeInTheDocument()
      const header = within(screen.getByRole('banner'))
      expect(header.getByText('Donau Personal')).toBeInTheDocument()
      expect(header.getByText(dispatcher.email)).toBeInTheDocument()
      expect(header.getByText('Disponent:in')).toBeInTheDocument()
      expect(api.count('POST /auth/refresh')).toBe(1)
    })

    it('asks for a login when the stored session is no longer valid', async () => {
      api.signIn()
      api.revokeSession()
      renderApp('/signups')

      expect(await screen.findByRole('heading', { name: 'Anmelden' })).toBeInTheDocument()
      expect(localStorage.getItem('shiftboard.refreshToken')).toBeNull()
    })

    it('returns to the login when the session ends while working', async () => {
      api.signIn()
      const { router } = renderApp('/signups')
      const approve = await screen.findByRole('button', { name: 'Lena Hofer freigeben' })

      api.revokeSession()
      await userEvent.click(approve)

      expect(await screen.findByRole('heading', { name: 'Anmelden' })).toBeInTheDocument()
      expect(router.state.location.search).toBe('?redirectTo=%2Fsignups')
      expect(
        screen.getByText('Deine Sitzung ist abgelaufen. Bitte melde dich erneut an.'),
      ).toBeInTheDocument()
    })

    it('logs out: ends the session on the server and on this device', async () => {
      api.signIn()
      const { router } = renderApp('/signups')
      const user = userEvent.setup()

      await user.click(await screen.findByRole('button', { name: 'Benutzermenü' }))
      await user.click(await screen.findByRole('menuitem', { name: 'Abmelden' }))

      expect(await screen.findByRole('heading', { name: 'Anmelden' })).toBeInTheDocument()
      expect(router.state.location.pathname).toBe('/login')
      expect(localStorage.getItem('shiftboard.refreshToken')).toBeNull()
      expect(api.calls.at(-1)).toEqual({
        route: 'POST /auth/logout',
        body: { refreshToken: 'refresh-2' },
      })
    })
  })
})
