import { CalendarRange, Clock, Download, Info, TriangleAlert } from 'lucide-react'
import type { ReactNode } from 'react'
import { useTranslation } from 'react-i18next'
import { Link, useSearchParams } from 'react-router'

import { type HoursEntry, HoursStatus } from '@/api/generated'
import { PageHeader } from '@/components/page-header'
import { StateCard } from '@/components/state-card'
import { Alert, AlertTitle } from '@/components/ui/alert'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Skeleton } from '@/components/ui/skeleton'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import { formatShiftDate, formatShiftTime } from '@/features/shifts/format'
import { downloadFile } from '@/lib/download'

import { hoursCsv } from './csv'
import { formatHours, formatMoney, hoursStatusBadge } from './format'
import { lastMonth, periodRange } from './period'
import { useHoursOfPeriod } from './queries'

/** Open entries first, each group by shift start as the API sends them. */
function openFirst(entries: HoursEntry[]) {
  return [
    ...entries.filter((it) => it.status === HoursStatus.OPEN),
    ...entries.filter((it) => it.status !== HoursStatus.OPEN),
  ]
}

/** The period is in the address, `?from=2026-09-01&to=2026-09-30`; last month by default. */
function usePeriod() {
  const [params, setParams] = useSearchParams()
  const fallback = lastMonth(new Date())
  const from = params.get('from') ?? fallback.from
  const to = params.get('to') ?? fallback.to

  return {
    from,
    to,
    change: (changes: { from?: string; to?: string }) => {
      setParams({ from, to, ...changes }, { replace: true })
    },
  }
}

export function HoursPage() {
  const { t } = useTranslation()
  const period = usePeriod()
  const range = periodRange(period.from, period.to)
  const entries = useHoursOfPeriod(range)
  const approved = entries.data?.filter((it) => it.status === HoursStatus.APPROVED) ?? []

  return (
    <div className="space-y-8">
      <PageHeader
        title={t('hours.page.title')}
        description={t('hours.page.description')}
        action={
          <Button
            disabled={approved.length === 0}
            onClick={() => {
              downloadFile(
                t('hours.export.fileName', { from: period.from, to: period.to }),
                hoursCsv(approved, (column) => t(`hours.export.columns.${column}`)),
                'text/csv;charset=utf-8',
              )
            }}
          >
            <Download aria-hidden />
            {t('hours.export.action')}
          </Button>
        }
      />

      <div className="flex flex-wrap items-start gap-4">
        <DateField
          id="hours-from"
          label={t('hours.page.from')}
          value={period.from}
          onChange={(from) => {
            period.change({ from })
          }}
        />
        <DateField
          id="hours-to"
          label={t('hours.page.to')}
          value={period.to}
          onChange={(to) => {
            period.change({ to })
          }}
        />
      </div>

      {range === null ? (
        <StateCard
          icon={<CalendarRange />}
          title={t('hours.page.invalidPeriod.title')}
          description={t('hours.page.invalidPeriod.description')}
        />
      ) : entries.isPending ? (
        <HoursTableSkeleton />
      ) : entries.isError ? (
        <StateCard
          icon={<TriangleAlert className="text-danger-text" />}
          title={t('hours.page.error.title')}
          description={t('hours.page.error.description')}
          action={
            <Button
              variant="outline"
              disabled={entries.isFetching}
              onClick={() => {
                void entries.refetch()
              }}
            >
              {t('shifts.error.retry')}
            </Button>
          }
        />
      ) : entries.data.length === 0 ? (
        <StateCard
          icon={<Clock />}
          title={t('hours.page.empty.title')}
          description={t('hours.page.empty.description')}
        />
      ) : (
        <HoursList entries={entries.data} approved={approved.length} />
      )}
    </div>
  )
}

function DateField({
  id,
  label,
  value,
  onChange,
}: {
  id: string
  label: string
  value: string
  onChange: (value: string) => void
}) {
  return (
    <div className="flex w-full flex-col gap-2 sm:w-56">
      <Label htmlFor={id}>{label}</Label>
      <Input
        id={id}
        type="date"
        value={value}
        onChange={(event) => {
          onChange(event.target.value)
        }}
      />
    </div>
  )
}

function HoursList({ entries, approved }: { entries: HoursEntry[]; approved: number }) {
  const { t } = useTranslation()
  const open = entries.length - approved

  return (
    <>
      {open > 0 && (
        <Alert>
          <Info aria-hidden />
          <AlertTitle>{t('hours.page.open', { count: open })}</AlertTitle>
        </Alert>
      )}
      <HoursTableFrame>
        {openFirst(entries).map((entry) => (
          <HoursRow key={entry.assignmentId} entry={entry} />
        ))}
      </HoursTableFrame>
      <p className="type-body-sm text-ink-secondary">
        {t('hours.page.count', { count: entries.length, approved })}
      </p>
    </>
  )
}

function HoursTableFrame({ children }: { children: ReactNode }) {
  const { t } = useTranslation()

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>{t('hours.page.columns.worker')}</TableHead>
          <TableHead>{t('hours.page.columns.shift')}</TableHead>
          <TableHead>{t('hours.page.columns.date')}</TableHead>
          <TableHead>{t('hours.page.columns.break')}</TableHead>
          <TableHead>{t('hours.page.columns.hours')}</TableHead>
          <TableHead>{t('hours.page.columns.gross')}</TableHead>
          <TableHead>{t('hours.page.columns.status')}</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>{children}</TableBody>
    </Table>
  )
}

function HoursRow({ entry }: { entry: HoursEntry }) {
  const { t, i18n } = useTranslation()
  const { hours, shift, worker } = entry
  const name = `${worker.firstName} ${worker.lastName}`
  const none = <span className="text-ink-tertiary">–</span>
  const status = hoursStatusBadge(t, entry.status)

  return (
    <TableRow>
      <TableCell className="font-semibold">{name}</TableCell>
      <TableCell>
        <Link to={`/shifts/${shift.id}`} className="font-semibold hover:underline">
          {shift.title}
        </Link>
        <span className="type-body-sm block text-ink-secondary">
          {shift.client.name} · {shift.location.name}
        </span>
      </TableCell>
      <TableCell className="tabular-nums">
        {formatShiftDate(hours?.startedAt ?? shift.startsAt, i18n.language)}
        <span className="type-body-sm block text-ink-secondary">
          {hours
            ? formatShiftTime(t, i18n.language, {
                startsAt: hours.startedAt,
                endsAt: hours.endedAt,
                endIsEstimate: false,
              })
            : t('hours.page.planned', {
                time: formatShiftTime(t, i18n.language, { ...shift, endIsEstimate: false }),
              })}
        </span>
      </TableCell>
      <TableCell className="tabular-nums">
        {hours ? t('hours.page.breakMinutes', { minutes: hours.breakMinutes }) : none}
      </TableCell>
      <TableCell className="tabular-nums">
        {hours ? formatHours(t, i18n.language, hours.workedMinutes) : none}
      </TableCell>
      <TableCell className="tabular-nums">
        {hours ? formatMoney(i18n.language, hours.grossCents) : none}
      </TableCell>
      <TableCell>
        <div className="flex flex-col items-start gap-1">
          <Badge variant={status.variant}>{status.label}</Badge>
          {!hours && (
            <Link
              to={`/shifts/${shift.id}`}
              className="type-body-sm text-link hover:underline"
              aria-label={t('hours.page.recordNamed', { name, title: shift.title })}
            >
              {t('hours.approve.action')}
            </Link>
          )}
        </div>
      </TableCell>
    </TableRow>
  )
}

const SKELETON_ROWS = 4

function HoursTableSkeleton() {
  const { t } = useTranslation()

  return (
    <div role="status" aria-label={t('hours.page.loading')}>
      <HoursTableFrame>
        {Array.from({ length: SKELETON_ROWS }, (_, row) => (
          <TableRow key={row}>
            {['w-28', 'w-36', 'w-28', 'w-14', 'w-16', 'w-16', 'w-20'].map((width, cell) => (
              <TableCell key={cell}>
                <Skeleton className={`h-3.5 ${width}`} />
              </TableCell>
            ))}
          </TableRow>
        ))}
      </HoursTableFrame>
    </div>
  )
}
