import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it } from 'vitest'

import { AssignmentStatus, CancelledBy } from '@/api/generated'
import {
  assignment,
  gala,
  installFakeApi,
  inventory,
  jakob,
  lastWeek,
  lena,
  mira,
  problem,
} from '@/test/fake-api'
import { renderApp } from '@/test/render'

describe('hours on the shift detail page', () => {
  let api: ReturnType<typeof installFakeApi>

  // lastWeek: 08.10.2026, 07:00 – 15:00, 16,50 € per hour.
  const jakobWorked = assignment(4, jakob, {
    status: AssignmentStatus.COMPLETED,
    decidedAt: new Date(2026, 9, 8, 15, 1),
    checkedInAt: new Date(2026, 9, 8, 6, 55),
    checkedOutAt: new Date(2026, 9, 8, 15, 10),
  })
  const lenaWorked = assignment(5, lena, {
    status: AssignmentStatus.COMPLETED,
    decidedAt: new Date(2026, 9, 8, 15, 1),
  })

  beforeEach(() => {
    api = installFakeApi()
    api.signIn()
    api.assignments[lastWeek.id] = [
      jakobWorked,
      lenaWorked,
      assignment(6, mira, { status: AssignmentStatus.NO_SHOW, decidedAt: new Date(2026, 9, 8, 16, 0) }),
    ]
  })

  function hours() {
    return within(screen.getByRole('region', { name: 'Stunden' }))
  }

  async function openDialog(name: RegExp) {
    const user = userEvent.setup()
    await user.click(await screen.findByRole('button', { name }))
    return { user, dialog: within(await screen.findByRole('alertdialog')) }
  }

  it('lists everyone who held a confirmed spot with planned times, check-in, check-out and status', async () => {
    renderApp(`/shifts/${lastWeek.id}`)

    await screen.findByRole('region', { name: 'Stunden' })
    const jakobRow = within(hours().getByRole('row', { name: /Jakob Steiner/ }))
    expect(jakobRow.getByText('07:00 – 15:00')).toBeInTheDocument()
    expect(jakobRow.getByText('06:55')).toBeInTheDocument()
    expect(jakobRow.getByText('15:10')).toBeInTheDocument()
    expect(jakobRow.getByText('Offen')).toBeInTheDocument()
    const lenaRow = within(hours().getByRole('row', { name: /Lena Hofer/ }))
    expect(lenaRow.getByText('Nicht eingecheckt')).toBeInTheDocument()
    expect(lenaRow.getByText('Nicht ausgecheckt')).toBeInTheDocument()
    expect(lenaRow.getByRole('button', { name: 'Stunden von Lena Hofer erfassen' })).toBeInTheDocument()
    // No-shows get no hours.
    expect(hours().queryByText('Mira Aigner')).not.toBeInTheDocument()
  })

  it('has no hours section before the shift starts', async () => {
    renderApp(`/shifts/${gala.id}`)

    expect(await screen.findByText('Noch niemand eingeteilt.')).toBeInTheDocument()
    expect(screen.queryByRole('region', { name: 'Stunden' })).not.toBeInTheDocument()
  })

  it('prefills check-in and check-out with a 30 minute break for more than six hours', async () => {
    renderApp(`/shifts/${lastWeek.id}`)

    const { dialog } = await openDialog(/Stunden von Jakob Steiner erfassen/)

    expect(dialog.getByRole('heading', { name: 'Stunden von Jakob Steiner' })).toBeInTheDocument()
    expect(dialog.getByLabelText('Datum')).toHaveValue('2026-10-08')
    expect(dialog.getByLabelText('Beginn')).toHaveValue('06:55')
    expect(dialog.getByLabelText('Ende')).toHaveValue('15:10')
    expect(dialog.getByLabelText('Pause in Minuten')).toHaveValue(30)
    expect(dialog.getByLabelText('Beginn')).toHaveAccessibleDescription('Geplant 07:00 · Eingecheckt 06:55')
    // 8:15 minus 30 minutes, at 16,50 € per hour.
    expect(dialog.getByText('7,75 Std.')).toBeInTheDocument()
    expect(dialog.getByText('127,88 €')).toBeInTheDocument()
  })

  it('prefills the planned times where check-in or check-out is missing', async () => {
    api.assignments[lastWeek.id] = [
      { ...lenaWorked, checkedInAt: new Date(2026, 9, 8, 7, 5) },
    ]
    renderApp(`/shifts/${lastWeek.id}`)

    const { dialog } = await openDialog(/Stunden von Lena Hofer erfassen/)

    expect(dialog.getByLabelText('Beginn')).toHaveValue('07:05')
    expect(dialog.getByLabelText('Ende')).toHaveValue('15:00')
    expect(dialog.getByLabelText('Pause in Minuten')).toHaveValue(30)
  })

  it('suggests no break for six hours or less', async () => {
    // inventory: 19.10.2026, 06:00 – 12:00.
    api.assignments[inventory.id] = [
      assignment(7, lena, { status: AssignmentStatus.CONFIRMED, decidedAt: new Date(2026, 9, 18, 9, 0) }),
    ]
    renderApp(`/shifts/${inventory.id}`)

    const { dialog } = await openDialog(/Stunden von Lena Hofer erfassen/)

    expect(dialog.getByLabelText('Beginn')).toHaveValue('06:00')
    expect(dialog.getByLabelText('Ende')).toHaveValue('12:00')
    expect(dialog.getByLabelText('Pause in Minuten')).toHaveValue(0)
    expect(dialog.getByText('6,00 Std.')).toBeInTheDocument()
  })

  it('saves the hours and shows them as approved with hours and gross', async () => {
    renderApp(`/shifts/${lastWeek.id}`)

    const { user, dialog } = await openDialog(/Stunden von Lena Hofer erfassen/)
    const pause = dialog.getByLabelText('Pause in Minuten')
    await user.clear(pause)
    await user.type(pause, '45')
    await user.click(dialog.getByRole('button', { name: 'Stunden freigeben' }))

    await waitFor(() => {
      expect(screen.queryByRole('alertdialog')).not.toBeInTheDocument()
    })
    const row = within(hours().getByRole('row', { name: /Lena Hofer/ }))
    expect(await row.findByText('Freigegeben')).toBeInTheDocument()
    expect(row.getByText('7,25 Std. · 119,63 € (07:00 – 15:00, 45 Min. Pause)')).toBeInTheDocument()
    expect(row.getByRole('button', { name: 'Stunden von Lena Hofer ändern' })).toBeInTheDocument()
    const route = `PUT /shifts/${lastWeek.id}/assignments/${lenaWorked.id}/hours`
    expect(api.calls.find((it) => it.route === route)?.body).toEqual({
      startedAt: new Date(2026, 9, 8, 7, 0).toISOString(),
      endedAt: new Date(2026, 9, 8, 15, 0).toISOString(),
      breakMinutes: 45,
    })
  })

  it('takes an end before the start as the next day', async () => {
    renderApp(`/shifts/${lastWeek.id}`)

    const { user, dialog } = await openDialog(/Stunden von Lena Hofer erfassen/)
    const end = dialog.getByLabelText('Ende')
    await user.clear(end)
    await user.type(end, '01:00')

    expect(end).toHaveAccessibleDescription(/^Endet am Folgetag/)
    await user.click(dialog.getByRole('button', { name: 'Stunden freigeben' }))

    const route = `PUT /shifts/${lastWeek.id}/assignments/${lenaWorked.id}/hours`
    await waitFor(() => {
      expect(api.calls.find((it) => it.route === route)?.body).toMatchObject({
        endedAt: new Date(2026, 9, 9, 1, 0).toISOString(),
      })
    })
  })

  it('checks the fields before saving', async () => {
    renderApp(`/shifts/${lastWeek.id}`)

    const { user, dialog } = await openDialog(/Stunden von Lena Hofer erfassen/)
    const end = dialog.getByLabelText('Ende')
    await user.clear(end)
    await user.type(end, '07:00')
    await user.click(dialog.getByRole('button', { name: 'Stunden freigeben' }))

    expect(dialog.getByText('Das Ende muss nach dem Beginn liegen.')).toBeInTheDocument()
    expect(end).toHaveFocus()

    await user.clear(end)
    await user.type(end, '07:20')
    await user.click(dialog.getByRole('button', { name: 'Stunden freigeben' }))

    expect(dialog.getByText('Die Pause muss kürzer sein als die Arbeitszeit.')).toBeInTheDocument()
    expect(dialog.getByLabelText('Pause in Minuten')).toHaveFocus()
    expect(api.count(`PUT /shifts/${lastWeek.id}/assignments/${lenaWorked.id}/hours`)).toBe(0)
  })

  it('shows the field errors of the backend on their fields', async () => {
    const route = `PUT /shifts/${lastWeek.id}/assignments/${lenaWorked.id}/hours`
    api.respondOnce(
      route,
      problem(400, 'validation_failed', [
        { field: 'endedAt', code: 'too_long' },
        { field: 'breakMinutes', code: 'out_of_range' },
      ]),
    )
    renderApp(`/shifts/${lastWeek.id}`)

    const { user, dialog } = await openDialog(/Stunden von Lena Hofer erfassen/)
    await user.click(dialog.getByRole('button', { name: 'Stunden freigeben' }))

    expect(await dialog.findByText('Höchstens 24 Stunden.')).toBeInTheDocument()
    expect(dialog.getByText('Zwischen 0 und 1440 Minuten.')).toBeInTheDocument()
    expect(dialog.getByLabelText('Ende')).toHaveFocus()
    expect(dialog.queryByText('Bitte prüfe die markierten Felder.')).not.toBeInTheDocument()
  })

  it('explains a shift that has not started or a worker who lost the spot', async () => {
    const route = `PUT /shifts/${lastWeek.id}/assignments/${lenaWorked.id}/hours`
    api.respondOnce(route, problem(409, 'assignment_not_worked'))
    renderApp(`/shifts/${lastWeek.id}`)

    const { user, dialog } = await openDialog(/Stunden von Lena Hofer erfassen/)
    await user.click(dialog.getByRole('button', { name: 'Stunden freigeben' }))

    expect(
      await dialog.findByText('Diese Person hat keinen bestätigten Platz mehr. Die Liste wurde aktualisiert.'),
    ).toBeInTheDocument()

    api.respondOnce(route, problem(409, 'shift_not_started'))
    await user.click(dialog.getByRole('button', { name: 'Stunden freigeben' }))

    expect(
      await dialog.findByText('Die Schicht hat noch nicht begonnen. Stunden lassen sich erst danach erfassen.'),
    ).toBeInTheDocument()
  })

  it('changes approved hours, starting from the approved values', async () => {
    api.assignments[lastWeek.id] = [
      {
        ...jakobWorked,
        hours: {
          startedAt: new Date(2026, 9, 8, 7, 0),
          endedAt: new Date(2026, 9, 8, 15, 0),
          breakMinutes: 30,
          workedMinutes: 450,
          grossCents: 12375,
          approvedAt: new Date(2026, 9, 9, 9, 0),
        },
      },
    ]
    renderApp(`/shifts/${lastWeek.id}`)

    await screen.findByRole('region', { name: 'Stunden' })
    const row = within(hours().getByRole('row', { name: /Jakob Steiner/ }))
    expect(row.getByText('7,50 Std. · 123,75 € (07:00 – 15:00, 30 Min. Pause)')).toBeInTheDocument()

    const { user, dialog } = await openDialog(/Stunden von Jakob Steiner ändern/)
    expect(dialog.getByLabelText('Beginn')).toHaveValue('07:00')
    expect(dialog.getByLabelText('Ende')).toHaveValue('15:00')
    const end = dialog.getByLabelText('Ende')
    await user.clear(end)
    await user.type(end, '16:00')
    await user.click(dialog.getByRole('button', { name: 'Stunden freigeben' }))

    expect(await row.findByText('8,50 Std. · 140,25 € (07:00 – 16:00, 30 Min. Pause)')).toBeInTheDocument()
  })

  it('offers no no-show for a worker who checked in', async () => {
    renderApp(`/shifts/${lastWeek.id}`)

    expect(
      await screen.findByRole('button', { name: 'Lena Hofer als nicht erschienen markieren' }),
    ).toBeInTheDocument()
    expect(
      screen.queryByRole('button', { name: 'Jakob Steiner als nicht erschienen markieren' }),
    ).not.toBeInTheDocument()
  })

  it('tells when a worker cannot be a no-show because they were there', async () => {
    const user = userEvent.setup()
    api.respondOnce(
      `POST /shifts/${lastWeek.id}/assignments/${lenaWorked.id}/no-show`,
      problem(409, 'worker_attended'),
    )
    api.assignments[lastWeek.id] = [
      lenaWorked,
      assignment(8, jakob, {
        status: AssignmentStatus.CANCELLED,
        cancelledBy: CancelledBy.WORKER,
        decidedAt: new Date(2026, 9, 7, 9, 0),
      }),
    ]
    renderApp(`/shifts/${lastWeek.id}`)

    await user.click(await screen.findByRole('button', { name: 'Lena Hofer als nicht erschienen markieren' }))

    expect(
      await screen.findByText(
        'Diese Person war da: Sie hat eingecheckt oder hat freigegebene Stunden. Sie kann nicht als nicht erschienen markiert werden.',
      ),
    ).toBeInTheDocument()
    // Cancelled claims get no hours either.
    expect(hours().queryByText('Jakob Steiner')).not.toBeInTheDocument()
  })
})
