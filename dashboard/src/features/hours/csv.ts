import type { HoursEntry } from '@/api/generated'
import { timeOfDay } from '@/features/shifts/shift-draft'

/** The columns of the payroll file, in order (ADR 0028). */
export const CSV_COLUMNS = [
  'lastName',
  'firstName',
  'date',
  'client',
  'location',
  'shift',
  'start',
  'end',
  'break',
  'hours',
  'hourlyRate',
  'gross',
] as const

export type CsvColumn = (typeof CSV_COLUMNS)[number]

const BOM = String.fromCharCode(0xfeff)
const SEPARATOR = ';'
const LINE_END = '\r\n'

/** Hundredths as a plain number with a decimal comma: 1650 → "16,50". */
function decimal(hundredths: number) {
  return `${String(Math.floor(hundredths / 100))},${String(hundredths % 100).padStart(2, '0')}`
}

/** Minutes as hours with two decimals, rounded half up: 450 → "7,50". */
export function hoursDecimal(minutes: number) {
  return decimal(Math.round((minutes * 100) / 60))
}

/** `dd.MM.yyyy` in the time zone of the browser. */
function dateText(date: Date) {
  return `${String(date.getDate()).padStart(2, '0')}.${String(date.getMonth() + 1).padStart(2, '0')}.${String(date.getFullYear())}`
}

/**
 * One cell: a value that a spreadsheet would read as a formula gets a leading quote, and a
 * value with a separator, quote or line break is quoted with its quotes doubled.
 */
export function csvCell(value: string) {
  const safe = /^[=+\-@\t\r]/.test(value) ? `'${value}` : value
  return /[;"\r\n]/.test(safe) ? `"${safe.replaceAll('"', '""')}"` : safe
}

/**
 * The payroll file: one row per worker and shift with approved hours, open entries left out.
 * Semicolons, decimal comma, local dates and times, UTF-8 with BOM and CRLF, so that Excel
 * opens it correctly for German and Austrian users.
 */
export function hoursCsv(entries: HoursEntry[], label: (column: CsvColumn) => string) {
  const rows = entries.flatMap(({ hours, shift, worker }) =>
    hours
      ? [
          [
            worker.lastName,
            worker.firstName,
            dateText(hours.startedAt),
            shift.client.name,
            shift.location.name,
            shift.title,
            timeOfDay(hours.startedAt),
            timeOfDay(hours.endedAt),
            String(hours.breakMinutes),
            hoursDecimal(hours.workedMinutes),
            decimal(shift.hourlyRateCents),
            decimal(hours.grossCents),
          ],
        ]
      : [],
  )
  const lines = [CSV_COLUMNS.map(label), ...rows].map((row) => row.map(csvCell).join(SEPARATOR))
  return BOM + lines.map((line) => line + LINE_END).join('')
}
