import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it } from 'vitest'

import { installFakeApi, jakob, lena, problem, worker } from '@/test/fake-api'
import { renderApp } from '@/test/render'

describe('pending signups', () => {
  let api: ReturnType<typeof installFakeApi>

  beforeEach(() => {
    api = installFakeApi()
    api.signIn()
  })

  function deferred() {
    let resolve: (response: Response) => void = () => undefined
    const promise = new Promise<Response>((done) => {
      resolve = done
    })
    return { promise, resolve }
  }

  function row(name: string) {
    return within(screen.getByRole('row', { name: new RegExp(name) }))
  }

  const navigation = () => within(screen.getByRole('navigation', { name: 'Hauptnavigation' }))

  it('shows a loading state while the list is fetched', async () => {
    api.respondOnce('GET /workers', deferred().promise)
    renderApp('/signups')

    expect(
      await screen.findByRole('status', { name: 'Anmeldungen werden geladen …' }),
    ).toBeInTheDocument()
  })

  it('lists the pending signups with their details', async () => {
    renderApp('/signups')

    const lenaRow = within(await screen.findByRole('row', { name: /Lena Hofer/ }))
    expect(lenaRow.getByText('lena.hofer@example.com')).toBeInTheDocument()
    expect(lenaRow.getByText('+43 660 5550101')).toBeInTheDocument()
    expect(lenaRow.getByText('Service')).toBeInTheDocument()
    expect(lenaRow.getByText('Bar')).toBeInTheDocument()
    expect(lenaRow.getByText('09.10.2026, 18:42')).toBeInTheDocument()

    expect(screen.getAllByRole('row')).toHaveLength(4)
    expect(screen.getByText('3 Anmeldungen warten auf Freigabe')).toBeInTheDocument()
    expect(navigation().getByText('3 offene Anmeldungen')).toBeInTheDocument()
    expect(screen.queryByRole('navigation', { name: 'Seiten' })).not.toBeInTheDocument()
    expect(api.count('GET /workers')).toBe(1)
  })

  it('uses the singular for a single signup', async () => {
    api.pending = [lena]
    renderApp('/signups')

    expect(await screen.findByText('1 Anmeldung wartet auf Freigabe')).toBeInTheDocument()
    expect(navigation().getByText('1 offene Anmeldung')).toBeInTheDocument()
  })

  it('shows an empty state without a count when nothing is pending', async () => {
    api.pending = []
    renderApp('/signups')

    expect(
      await screen.findByRole('heading', { name: 'Keine offenen Anmeldungen' }),
    ).toBeInTheDocument()
    expect(screen.queryByRole('table')).not.toBeInTheDocument()
    expect(navigation().queryByText(/offene Anmeldung/)).not.toBeInTheDocument()
  })

  it('shows an error and recovers on retry', async () => {
    api.respondOnce('GET /workers', problem(500, 'internal_error'))
    renderApp('/signups')

    expect(
      await screen.findByRole('heading', { name: 'Anmeldungen konnten nicht geladen werden' }),
    ).toBeInTheDocument()

    await userEvent.click(screen.getByRole('button', { name: 'Erneut versuchen' }))

    expect(await screen.findByRole('row', { name: /Lena Hofer/ })).toBeInTheDocument()
  })

  it('approves a signup: the row disappears, a toast confirms and the count drops', async () => {
    const approval = deferred()
    renderApp('/signups')
    const user = userEvent.setup()

    await user.click(await screen.findByRole('button', { name: 'Lena Hofer freigeben' }))

    expect(api.count(`POST /workers/${lena.id}/approve`)).toBe(1)
    expect(screen.queryByRole('alertdialog')).not.toBeInTheDocument()
    expect(await screen.findByText('Lena Hofer wurde freigegeben')).toBeInTheDocument()
    expect(screen.getByText('Der Zugang gilt ab dem nächsten App-Start.')).toBeInTheDocument()
    await waitFor(() => {
      expect(screen.queryByRole('row', { name: /Lena Hofer/ })).not.toBeInTheDocument()
    })
    expect(screen.getByText('2 Anmeldungen warten auf Freigabe')).toBeInTheDocument()
    expect(navigation().getByText('2 offene Anmeldungen')).toBeInTheDocument()

    // While a decision is running, both actions of that row are blocked.
    api.respondOnce(`POST /workers/${jakob.id}/approve`, approval.promise)
    await user.click(screen.getByRole('button', { name: 'Jakob Steiner freigeben' }))

    expect(row('Jakob Steiner').getByRole('button', { name: /freigeben/ })).toBeDisabled()
    expect(row('Jakob Steiner').getByRole('button', { name: /ablehnen/ })).toBeDisabled()
    expect(row('Mira Aigner').getByRole('button', { name: /freigeben/ })).toBeEnabled()
    approval.resolve(problem(500, 'internal_error'))
    await waitFor(() => {
      expect(row('Jakob Steiner').getByRole('button', { name: /freigeben/ })).toBeEnabled()
    })
  })

  it('asks for confirmation before rejecting and does nothing on cancel', async () => {
    renderApp('/signups')
    const user = userEvent.setup()

    await user.click(await screen.findByRole('button', { name: 'Mira Aigner ablehnen' }))

    const dialog = within(screen.getByRole('alertdialog', { name: 'Anmeldung ablehnen?' }))
    expect(
      dialog.getByText(
        'Mira Aigner erhält keinen Zugang zu den Schichten von Donau Personal. Das Konto wird als inaktiv markiert.',
      ),
    ).toBeInTheDocument()
    expect(dialog.getByRole('button', { name: 'Abbrechen' })).toHaveFocus()

    await user.click(dialog.getByRole('button', { name: 'Abbrechen' }))

    expect(screen.queryByRole('alertdialog')).not.toBeInTheDocument()
    expect(screen.getByRole('row', { name: /Mira Aigner/ })).toBeInTheDocument()
    expect(api.calls.some((call) => call.route.endsWith('/reject'))).toBe(false)
    expect(screen.getByRole('button', { name: 'Mira Aigner ablehnen' })).toHaveFocus()
  })

  it('rejects a signup after confirmation', async () => {
    renderApp('/signups')
    const user = userEvent.setup()

    await user.click(await screen.findByRole('button', { name: 'Lena Hofer ablehnen' }))
    await user.click(
      within(screen.getByRole('alertdialog')).getByRole('button', { name: 'Ablehnen' }),
    )

    expect(await screen.findByText('Lena Hofer wurde abgelehnt')).toBeInTheDocument()
    await waitFor(() => {
      expect(screen.queryByRole('alertdialog')).not.toBeInTheDocument()
    })
    expect(screen.queryByRole('row', { name: /Lena Hofer/ })).not.toBeInTheDocument()
    expect(screen.getByText('2 Anmeldungen warten auf Freigabe')).toBeInTheDocument()
    expect(api.count(`POST /workers/${lena.id}/reject`)).toBe(1)
  })

  it('refreshes the list when someone else has already decided', async () => {
    renderApp('/signups')
    const approve = await screen.findByRole('button', { name: 'Lena Hofer freigeben' })
    api.pending = api.pending.filter((it) => it !== lena)

    await userEvent.click(approve)

    expect(
      await screen.findByText(
        'Diese Anmeldung wurde bereits bearbeitet. Die Liste wurde aktualisiert.',
      ),
    ).toBeInTheDocument()
    await waitFor(() => {
      expect(screen.queryByRole('row', { name: /Lena Hofer/ })).not.toBeInTheDocument()
    })
    expect(navigation().getByText('2 offene Anmeldungen')).toBeInTheDocument()
  })

  it('tells the user when the signup no longer exists', async () => {
    api.respondOnce(`POST /workers/${lena.id}/reject`, problem(404, 'worker_not_found'))
    renderApp('/signups')
    const user = userEvent.setup()

    await user.click(await screen.findByRole('button', { name: 'Lena Hofer ablehnen' }))
    await user.click(
      within(screen.getByRole('alertdialog')).getByRole('button', { name: 'Ablehnen' }),
    )

    expect(
      await screen.findByText('Diese Anmeldung gibt es nicht mehr. Die Liste wurde aktualisiert.'),
    ).toBeInTheDocument()
    await waitFor(() => {
      expect(screen.queryByRole('alertdialog')).not.toBeInTheDocument()
    })
  })

  it('pages through more signups than fit on one page', async () => {
    api.pending = Array.from({ length: 21 }, (_, index) =>
      worker(index + 1, 'Lena', `Hofer${String(index + 1)}`, [], new Date(2026, 9, 9, 8, index)),
    )
    renderApp('/signups')
    const user = userEvent.setup()

    const pages = within(await screen.findByRole('navigation', { name: 'Seiten' }))
    expect(pages.getByText('Seite 1 von 2')).toBeInTheDocument()
    expect(pages.getByRole('button', { name: 'Zurück' })).toBeDisabled()
    expect(screen.getByText('21 Anmeldungen warten auf Freigabe')).toBeInTheDocument()

    await user.click(pages.getByRole('button', { name: 'Weiter' }))

    expect(await screen.findByRole('row', { name: /Lena Hofer21/ })).toBeInTheDocument()
    expect(screen.getAllByRole('row')).toHaveLength(2)

    // Deciding the only signup of the last page steps back to the page before.
    await user.click(screen.getByRole('button', { name: 'Lena Hofer21 freigeben' }))

    expect(await screen.findByRole('row', { name: /Lena Hofer20/ })).toBeInTheDocument()
    expect(screen.queryByRole('navigation', { name: 'Seiten' })).not.toBeInTheDocument()
  })
})
