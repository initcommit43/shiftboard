import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it } from 'vitest'

import { ShiftStatus } from '@/api/generated'
import {
  forklift,
  installFakeApi,
  nordlicht,
  problem,
  shift,
  umschlaglager,
} from '@/test/fake-api'
import { renderApp } from '@/test/render'

/** A day from today at the given time, in the browser's time zone. */
function inDays(days: number, hours: number, minutes = 0) {
  const date = new Date()
  date.setDate(date.getDate() + days)
  date.setHours(hours, minutes, 0, 0)
  return date
}

function dateText(date: Date) {
  return `${String(date.getFullYear())}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
}

const upcoming = shift(20, {
  title: 'Kommissionierung',
  description: 'Treffpunkt Tor 3.',
  startsAt: inDays(3, 7),
  endsAt: inDays(3, 15),
  takenSlots: 2,
  qualifications: [forklift],
})

describe('editing a shift', () => {
  let api: ReturnType<typeof installFakeApi>

  beforeEach(() => {
    api = installFakeApi()
    api.shifts = [upcoming, ...api.shifts]
    api.signIn()
  })

  const sent = (route: string) => api.calls.find((call) => call.route === route)?.body

  it('changes every field, keeps the date and goes back to the shift', async () => {
    renderApp(`/shifts/${upcoming.id}`)
    const user = userEvent.setup()

    await user.click(await screen.findByRole('link', { name: 'Bearbeiten' }))

    expect(await screen.findByRole('heading', { name: 'Schicht bearbeiten' })).toBeInTheDocument()
    expect(
      screen.getByText(
        '2 Personen haben einen Platz. Sie bekommen beim Speichern eine Nachricht mit den Änderungen.',
      ),
    ).toBeInTheDocument()
    expect(screen.getByLabelText('Datum')).toHaveValue(dateText(upcoming.startsAt))
    expect(screen.getByLabelText('Beginn')).toHaveValue('07:00')
    expect(screen.getByLabelText('Titel')).toHaveValue('Kommissionierung')

    await user.selectOptions(screen.getByLabelText('Einsatzort'), 'Umschlaglager Wels')
    await user.clear(screen.getByLabelText('Beginn'))
    await user.type(screen.getByLabelText('Beginn'), '08:00')
    await user.clear(screen.getByLabelText('Stundenlohn in Euro'))
    await user.type(screen.getByLabelText('Stundenlohn in Euro'), '17,20')
    await user.clear(screen.getByLabelText('Beschreibung'))
    await user.click(screen.getByRole('button', { name: 'Änderungen speichern' }))

    expect(await screen.findByText('Änderungen an „Kommissionierung“ gespeichert')).toBeInTheDocument()
    expect(sent(`PUT /shifts/${upcoming.id}`)).toEqual({
      clientId: nordlicht.id,
      locationId: umschlaglager.id,
      title: 'Kommissionierung',
      startsAt: inDays(3, 8).toISOString(),
      endsAt: inDays(3, 15).toISOString(),
      endIsEstimate: false,
      hourlyRateCents: 1720,
      slots: 5,
      qualificationIds: [forklift.id],
    })
    // Back on the shift, with the new values.
    expect(await screen.findByRole('heading', { name: 'Kommissionierung' })).toBeInTheDocument()
    expect(await screen.findByText(/Umschlaglager Wels/)).toBeInTheDocument()
    expect(screen.queryByText('Treffpunkt Tor 3.')).not.toBeInTheDocument()
  })

  it('keeps the spots at or above the ones taken', async () => {
    renderApp(`/shifts/${upcoming.id}/edit`)
    const user = userEvent.setup()

    const slots = await screen.findByLabelText('Plätze')
    await user.clear(slots)
    await user.type(slots, '1')
    await user.click(screen.getByRole('button', { name: 'Änderungen speichern' }))

    expect(
      await screen.findByText(
        'Weniger Plätze als vergeben. Lehne zuerst jemanden ab oder nimm jemanden heraus.',
      ),
    ).toBeInTheDocument()
    expect(slots).toHaveFocus()
  })

  it('explains a new time that would double-book someone', async () => {
    api.respondOnce(`PUT /shifts/${upcoming.id}`, problem(409, 'shift_overlap'))
    renderApp(`/shifts/${upcoming.id}/edit`)
    const user = userEvent.setup()

    await user.clear(await screen.findByLabelText('Beginn'))
    await user.type(screen.getByLabelText('Beginn'), '05:00')
    await user.click(screen.getByRole('button', { name: 'Änderungen speichern' }))

    expect(
      await screen.findByText(/hätte jemand mit Platz schon eine andere Schicht/),
    ).toBeInTheDocument()
    expect(screen.getByRole('heading', { name: 'Schicht bearbeiten' })).toBeInTheDocument()
  })

  it('is not offered once the shift has started', async () => {
    const running = shift(21, {
      title: 'Nachtinventur',
      startsAt: inDays(0, 0),
      endsAt: inDays(1, 23),
    })
    api.shifts = [running, ...api.shifts]
    renderApp(`/shifts/${running.id}`)

    expect(await screen.findByRole('heading', { name: 'Nachtinventur' })).toBeInTheDocument()
    expect(screen.queryByRole('link', { name: 'Bearbeiten' })).not.toBeInTheDocument()
  })

  it('says so when the shift can no longer be edited', async () => {
    const cancelled = shift(22, {
      title: 'Abgesagt',
      status: ShiftStatus.CANCELLED,
      startsAt: inDays(4, 7),
      endsAt: inDays(4, 15),
    })
    api.shifts = [cancelled, ...api.shifts]
    renderApp(`/shifts/${cancelled.id}/edit`)

    expect(
      await screen.findByText('Diese Schicht lässt sich nicht mehr bearbeiten'),
    ).toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Zur Schicht' })).toHaveAttribute(
      'href',
      `/shifts/${cancelled.id}`,
    )
  })

  it('lets a draft be changed without a notice to anyone', async () => {
    const draft = shift(23, {
      title: 'Entwurf',
      status: ShiftStatus.DRAFT,
      startsAt: inDays(5, 7),
      endsAt: inDays(5, 15),
    })
    api.shifts = [draft, ...api.shifts]
    renderApp(`/shifts/${draft.id}/edit`)

    expect(await screen.findByLabelText('Titel')).toHaveValue('Entwurf')
    expect(screen.queryByText(/haben einen Platz/)).not.toBeInTheDocument()
  })
})
