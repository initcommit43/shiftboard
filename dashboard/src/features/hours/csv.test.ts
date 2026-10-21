import { describe, expect, it } from 'vitest'

import { type HoursEntry, HoursStatus } from '@/api/generated'
import { jakob, lena, nordlicht, zentrallager } from '@/test/fake-api'

import { csvCell, hoursCsv, hoursDecimal } from './csv'

const shift: HoursEntry['shift'] = {
  id: '0199c3a0-0000-7000-8000-000000000401',
  title: 'Lagerunterstützung',
  startsAt: new Date(2026, 8, 3, 7, 0),
  endsAt: new Date(2026, 8, 3, 15, 0),
  hourlyRateCents: 1650,
  client: { id: nordlicht.id, name: nordlicht.name },
  location: zentrallager,
}

function entry(number: number, person: typeof lena, values: Partial<HoursEntry> = {}): HoursEntry {
  return {
    assignmentId: `0199c3a0-0000-7000-8000-0000000005${String(number).padStart(2, '0')}`,
    status: HoursStatus.OPEN,
    shift,
    worker: { id: person.id, firstName: person.firstName, lastName: person.lastName, phone: person.phone },
    ...values,
  }
}

const hours: NonNullable<HoursEntry['hours']> = {
  startedAt: new Date(2026, 8, 3, 7, 0),
  endedAt: new Date(2026, 8, 3, 15, 0),
  breakMinutes: 30,
  workedMinutes: 450,
  grossCents: 12375,
  approvedAt: new Date(2026, 8, 4, 9, 0),
}

const approved = entry(1, lena, { status: HoursStatus.APPROVED, hours })

const label = (column: string) => column

describe('payroll csv', () => {
  it('writes a header and one row per approved entry, leaving open ones out', () => {
    const csv = hoursCsv([approved, entry(2, jakob)], label)

    expect(csv).toBe(
      String.fromCharCode(0xfeff) +
        'lastName;firstName;date;client;location;shift;start;end;break;hours;hourlyRate;gross\r\n' +
        'Hofer;Lena;03.09.2026;Nordlicht Logistik;Zentrallager Linz;Lagerunterstützung;07:00;15:00;30;7,50;16,50;123,75\r\n',
    )
  })

  it('starts with a byte order mark and ends lines with CRLF', () => {
    const csv = hoursCsv([approved], label)

    expect(csv.charCodeAt(0)).toBe(0xfeff)
    expect(csv.split('\r\n')).toHaveLength(3)
    expect(csv.replaceAll('\r\n', '')).not.toContain('\n')
  })

  it('writes hours, rate and gross with a decimal comma and no thousands separator', () => {
    expect(hoursDecimal(450)).toBe('7,50')
    expect(hoursDecimal(485)).toBe('8,08')
    expect(hoursDecimal(1)).toBe('0,02')
    expect(hoursDecimal(1440)).toBe('24,00')

    const big = { ...approved, shift: { ...shift, hourlyRateCents: 123456 } }
    const [, row] = hoursCsv([{ ...big, hours: { ...hours, grossCents: 925920 } }], label).split('\r\n')
    expect(row).toMatch(/;1234,56;9259,20$/)
  })

  it('writes local dates and times of the approved hours, also over midnight', () => {
    const night = {
      ...approved,
      hours: {
        ...hours,
        startedAt: new Date(2026, 8, 30, 22, 5),
        endedAt: new Date(2026, 9, 1, 6, 0),
      },
    }

    const [, row] = hoursCsv([night], label).split('\r\n')

    expect(row).toContain(';30.09.2026;')
    expect(row).toContain(';22:05;06:00;')
  })

  it('quotes cells with separators, quotes or line breaks', () => {
    expect(csvCell('Lager; Halle 2')).toBe('"Lager; Halle 2"')
    expect(csvCell('Halle "Nord"')).toBe('"Halle ""Nord"""')
    expect(csvCell('Zeile 1\nZeile 2')).toBe('"Zeile 1\nZeile 2"')
    expect(csvCell('Nordlicht Logistik')).toBe('Nordlicht Logistik')
  })

  it('escapes cells that a spreadsheet would read as a formula', () => {
    expect(csvCell('=SUMME(A1:A9)')).toBe("'=SUMME(A1:A9)")
    expect(csvCell('+43 660')).toBe("'+43 660")
    expect(csvCell('-5')).toBe("'-5")
    expect(csvCell('@home')).toBe("'@home")
    expect(csvCell('\tTab')).toBe("'\tTab")
    expect(csvCell('=A1;B1')).toBe('"\'=A1;B1"')

    const evil = { ...approved, shift: { ...shift, title: '=HYPERLINK("x")' } }
    const [, row] = hoursCsv([evil], label).split('\r\n')
    expect(row).toContain(';"\'=HYPERLINK(""x"")";')
  })
})
