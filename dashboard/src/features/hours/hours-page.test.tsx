import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

import { AssignmentStatus, ShiftStatus } from '@/api/generated'
import {
  assignment,
  installFakeApi,
  jakob,
  lastWeek,
  lena,
  mira,
  problem,
  shift,
  umschlaglager,
} from '@/test/fake-api'
import { renderApp } from '@/test/render'

const early = shift(10, {
  title: 'Inventur Wels',
  status: ShiftStatus.COMPLETED,
  location: umschlaglager,
  startsAt: new Date(2026, 8, 3, 7, 0),
  endsAt: new Date(2026, 8, 3, 15, 0),
})
const night = shift(11, {
  title: 'Nachtschicht Lager',
  status: ShiftStatus.COMPLETED,
  startsAt: new Date(2026, 8, 10, 22, 0),
  endsAt: new Date(2026, 8, 11, 6, 0),
  hourlyRateCents: 1800,
})

const lenaEarly = assignment(10, lena, {
  status: AssignmentStatus.COMPLETED,
  hours: {
    startedAt: new Date(2026, 8, 3, 7, 0),
    endedAt: new Date(2026, 8, 3, 15, 0),
    breakMinutes: 30,
    workedMinutes: 450,
    grossCents: 12375,
    approvedAt: new Date(2026, 8, 4, 9, 0),
  },
})
const jakobEarly = assignment(11, jakob, { status: AssignmentStatus.COMPLETED })
const miraNight = assignment(12, mira, {
  status: AssignmentStatus.COMPLETED,
  hours: {
    startedAt: new Date(2026, 8, 10, 22, 0),
    endedAt: new Date(2026, 8, 11, 6, 15),
    breakMinutes: 30,
    workedMinutes: 465,
    grossCents: 13950,
    approvedAt: new Date(2026, 8, 11, 9, 0),
  },
})

describe('hours page', () => {
  let api: ReturnType<typeof installFakeApi>

  beforeEach(() => {
    // Only the clock is fake, so that last month is September 2026.
    vi.useFakeTimers({ toFake: ['Date'] })
    vi.setSystemTime(new Date(2026, 9, 21, 12, 0))
    api = installFakeApi()
    api.signIn()
    api.pastShifts = [early, night, lastWeek]
    api.assignments[early.id] = [lenaEarly, jakobEarly]
    api.assignments[night.id] = [miraNight]
  })

  afterEach(() => {
    vi.useRealTimers()
  })

  /** jsdom has no object URLs and no downloads: collects the files and names handed out instead. */
  function captureDownloads() {
    const files: Blob[] = []
    const names: string[] = []
    Object.assign(URL, {
      createObjectURL: (blob: Blob) => {
        files.push(blob)
        return 'blob:hours'
      },
      revokeObjectURL: () => undefined,
    })
    vi.spyOn(HTMLAnchorElement.prototype, 'click').mockImplementation(function (this: HTMLAnchorElement) {
      names.push(this.download)
    })
    return { files, names }
  }

  function rows() {
    return within(screen.getByRole('table')).getAllByRole('row').slice(1)
  }

  it('opens from the navigation and shows last month, open entries first', async () => {
    const user = userEvent.setup()
    renderApp('/shifts')

    const nav = within(await screen.findByRole('navigation', { name: 'Hauptnavigation' }))
    await user.click(nav.getByRole('link', { name: 'Stunden' }))

    expect(await screen.findByRole('heading', { name: 'Stunden', level: 1 })).toBeInTheDocument()
    expect(screen.getByLabelText('Von')).toHaveValue('2026-09-01')
    expect(screen.getByLabelText('Bis')).toHaveValue('2026-09-30')
    await screen.findByRole('table')
    const [call] = api.queries('GET /hours')
    expect(call?.get('from')).toBe(new Date(2026, 8, 1).toISOString())
    expect(call?.get('to')).toBe(new Date(2026, 9, 1).toISOString())

    const [first, second, third] = rows().map((row) => within(row))
    expect(first?.getByText('Jakob Steiner')).toBeInTheDocument()
    expect(first?.getByText('Offen')).toBeInTheDocument()
    expect(first?.getByText('Geplant 07:00 – 15:00')).toBeInTheDocument()
    expect(second?.getByText('Lena Hofer')).toBeInTheDocument()
    expect(second?.getByText('Do., 03.09.2026')).toBeInTheDocument()
    expect(second?.getByText('07:00 – 15:00')).toBeInTheDocument()
    expect(second?.getByText('30 Min.')).toBeInTheDocument()
    expect(second?.getByText('7,50 Std.')).toBeInTheDocument()
    expect(second?.getByText('123,75 €')).toBeInTheDocument()
    expect(second?.getByText('Freigegeben')).toBeInTheDocument()
    expect(third?.getByText('Mira Aigner')).toBeInTheDocument()
    expect(third?.getByText('22:00 – Fr., 06:15')).toBeInTheDocument()
    expect(screen.getByText('3 Einträge, davon 2 freigegeben')).toBeInTheDocument()
  })

  it('links each open entry to its shift', async () => {
    renderApp('/hours')

    const link = await screen.findByRole('link', {
      name: 'Stunden von Jakob Steiner bei Inventur Wels erfassen',
    })
    expect(link).toHaveAttribute('href', `/shifts/${early.id}`)
    expect(screen.queryByRole('link', { name: /Stunden von Lena Hofer/ })).not.toBeInTheDocument()
  })

  it('says how many entries are still open and left out of the file', async () => {
    renderApp('/hours')

    expect(
      await screen.findByText(
        '1 Eintrag ist noch offen und nicht in der CSV-Datei. Gebt die Stunden zuerst bei der Schicht frei.',
      ),
    ).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'CSV exportieren' })).toBeEnabled()
  })

  it('loads every page of a period', async () => {
    api.assignments[early.id] = Array.from({ length: 101 }, (_, index) =>
      assignment(20 + index, lena, { status: AssignmentStatus.COMPLETED }),
    )
    renderApp('/hours')

    await screen.findByRole('table')
    expect(await screen.findByText('102 Einträge, davon 1 freigegeben')).toBeInTheDocument()
    expect(api.queries('GET /hours').map((it) => it.get('page')))
      .toEqual(['0', '1'])
  })

  it('shows another period and disables the export when nothing is approved', async () => {
    const user = userEvent.setup()
    renderApp('/hours')

    await screen.findByRole('table')
    const from = screen.getByLabelText('Von')
    const to = screen.getByLabelText('Bis')
    await user.clear(to)
    await user.type(to, '2026-10-31')
    await user.clear(from)
    await user.type(from, '2026-10-01')

    // Jakob worked on lastWeek (08.10.) and holds a spot on warehouse (15.10.), neither approved.
    expect(await screen.findByText('2 Einträge, davon 0 freigegeben')).toBeInTheDocument()
    expect(rows()[0]).toHaveTextContent('Messeaufbau')
    expect(screen.getByRole('button', { name: 'CSV exportieren' })).toBeDisabled()
    const call = api.queries('GET /hours').at(-1)
    expect(call?.get('from')).toBe(new Date(2026, 9, 1).toISOString())
    expect(call?.get('to')).toBe(new Date(2026, 10, 1).toISOString())
  })

  it('asks for a valid period when the end is before the start', async () => {
    renderApp('/hours?from=2026-09-30&to=2026-09-01')

    expect(await screen.findByRole('heading', { name: 'Kein gültiger Zeitraum' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'CSV exportieren' })).toBeDisabled()
    expect(api.count('GET /hours')).toBe(0)
  })

  it('shows an empty period', async () => {
    renderApp('/hours?from=2026-08-01&to=2026-08-31')

    expect(await screen.findByRole('heading', { name: 'Keine Stunden in diesem Zeitraum' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'CSV exportieren' })).toBeDisabled()
  })

  it('shows an error and recovers on retry', async () => {
    const user = userEvent.setup()
    api.respondOnce('GET /hours', problem(500, 'internal_error'))
    renderApp('/hours')

    expect(await screen.findByRole('heading', { name: 'Die Stunden konnten nicht geladen werden' }))
      .toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Erneut versuchen' }))

    expect(await screen.findByText('3 Einträge, davon 2 freigegeben')).toBeInTheDocument()
  })

  it('exports the approved hours as a CSV file for payroll', async () => {
    const user = userEvent.setup()
    const { files, names } = captureDownloads()
    renderApp('/hours')

    await user.click(await screen.findByRole('button', { name: 'CSV exportieren' }))

    expect(names).toEqual(['stunden-2026-09-01-bis-2026-09-30.csv'])
    const [file = new Blob()] = files
    expect(file.type).toBe('text/csv;charset=utf-8')
    const bytes = new Uint8Array(await file.arrayBuffer())
    expect([...bytes.slice(0, 3)]).toEqual([0xef, 0xbb, 0xbf])
    expect(new TextDecoder().decode(bytes).split('\r\n')).toEqual([
      'Nachname;Vorname;Datum;Kunde;Einsatzort;Schicht;Beginn;Ende;Pause (Min.);Stunden;Stundenlohn;Brutto',
      'Hofer;Lena;03.09.2026;Nordlicht Logistik;Umschlaglager Wels;Inventur Wels;07:00;15:00;30;7,50;16,50;123,75',
      'Aigner;Mira;10.09.2026;Nordlicht Logistik;Zentrallager Linz;Nachtschicht Lager;22:00;06:15;30;7,75;18,00;139,50',
      '',
    ])
  })

  it('writes the header in English when the dashboard is in English', async () => {
    const user = userEvent.setup()
    const { files } = captureDownloads()
    localStorage.setItem('shiftboard.language', 'en')
    const { default: i18n } = await import('@/i18n')
    await i18n.changeLanguage('en')
    try {
      renderApp('/hours')

      await user.click(await screen.findByRole('button', { name: 'Export CSV' }))

      await waitFor(() => {
        expect(files).toHaveLength(1)
      })
      const [file = new Blob()] = files
      const [header] = (await file.text()).split('\r\n')
      expect(header).toBe(
        'Last name;First name;Date;Client;Location;Shift;Start;End;Break (min);Hours;Hourly rate;Gross',
      )
    } finally {
      await i18n.changeLanguage('de')
    }
  })
})
