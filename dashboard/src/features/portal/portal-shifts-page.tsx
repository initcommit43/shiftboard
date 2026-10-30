import { CalendarClock, History, TriangleAlert } from 'lucide-react'
import { type ReactNode, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Link, useSearchParams } from 'react-router'

import { type ClientShift, ClientShiftPeriod } from '@/api/generated'
import { PageHeader } from '@/components/page-header'
import { Pagination } from '@/components/pagination'
import { PeriodTabs } from '@/components/period-tabs'
import { StateCard } from '@/components/state-card'
import { Button } from '@/components/ui/button'
import { Skeleton } from '@/components/ui/skeleton'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import { useCurrentUser } from '@/features/auth/use-session'
import { formatShiftDate, formatShiftTime } from '@/features/shifts/format'

import { useClientShifts } from './queries'
import { FillStatus, PortalStatusBadge } from './shift-status'

/** Upcoming by default; `?period=past` shows the shifts that have ended. */
function usePeriod(): ClientShiftPeriod {
  const [params] = useSearchParams()
  return params.get('period') === 'past' ? ClientShiftPeriod.PAST : ClientShiftPeriod.UPCOMING
}

/** The client's shifts, upcoming and past. */
export function PortalShiftsPage() {
  const { t } = useTranslation()
  const { agency } = useCurrentUser()
  const period = usePeriod()

  return (
    <div className="space-y-8">
      <PageHeader
        title={t('portal.shifts.title')}
        description={t(
          period === ClientShiftPeriod.PAST ? 'portal.shifts.descriptionPast' : 'portal.shifts.description',
          { agency: agency.name },
        )}
      />
      <PeriodTabs
        label={t('shifts.periods.label')}
        current={period}
        tabs={[
          { period: ClientShiftPeriod.UPCOMING, to: '/portal', label: t('shifts.periods.upcoming') },
          { period: ClientShiftPeriod.PAST, to: '/portal?period=past', label: t('shifts.periods.past') },
        ]}
      />
      {/* A new period starts on its first page. */}
      <ShiftList key={period} period={period} />
    </div>
  )
}

function ShiftList({ period }: { period: ClientShiftPeriod }) {
  const { t } = useTranslation()
  const [page, setPage] = useState(0)
  const shifts = useClientShifts(period, page)
  const past = period === ClientShiftPeriod.PAST

  if (shifts.isPending) {
    return <PortalTableSkeleton />
  }

  if (shifts.isError) {
    return (
      <StateCard
        icon={<TriangleAlert className="text-danger-text" />}
        title={t('portal.shifts.error.title')}
        description={t('portal.shifts.error.description')}
        action={
          <Button
            variant="outline"
            disabled={shifts.isFetching}
            onClick={() => {
              void shifts.refetch()
            }}
          >
            {t('portal.shifts.error.retry')}
          </Button>
        }
      />
    )
  }

  const { content, totalElements, totalPages } = shifts.data

  // The last shift of the last page has ended in the meantime: step back to a page that still has rows.
  if (page > 0 && page >= totalPages) {
    setPage(Math.max(0, totalPages - 1))
  }

  if (totalElements === 0) {
    return past ? (
      <StateCard
        icon={<History />}
        title={t('portal.shifts.emptyPast.title')}
        description={t('portal.shifts.emptyPast.description')}
      />
    ) : (
      <StateCard
        icon={<CalendarClock />}
        title={t('portal.shifts.empty.title')}
        description={t('portal.shifts.empty.description')}
      />
    )
  }

  return (
    <>
      <PortalTableFrame>
        {content.map((shift) => (
          <ShiftRow key={shift.id} shift={shift} />
        ))}
      </PortalTableFrame>

      <div className="flex flex-wrap items-center justify-between gap-4">
        <p className="type-body-sm text-ink-secondary">
          {t(past ? 'shifts.countPast' : 'shifts.count', { count: totalElements })}
        </p>
        <Pagination
          page={page}
          totalPages={totalPages}
          disabled={shifts.isPlaceholderData}
          onPageChange={setPage}
        />
      </div>
    </>
  )
}

function PortalTableFrame({ children }: { children: ReactNode }) {
  const { t } = useTranslation()

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>{t('shifts.columns.shift')}</TableHead>
          <TableHead>{t('shifts.columns.location')}</TableHead>
          <TableHead>{t('shifts.columns.date')}</TableHead>
          <TableHead>{t('shifts.columns.time')}</TableHead>
          <TableHead>{t('shifts.columns.status')}</TableHead>
          <TableHead>{t('shifts.columns.spots')}</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>{children}</TableBody>
    </Table>
  )
}

function ShiftRow({ shift }: { shift: ClientShift }) {
  const { t, i18n } = useTranslation()

  return (
    <TableRow>
      <TableCell className="font-semibold">
        <Link to={`/portal/shifts/${shift.id}`} className="hover:underline">
          {shift.title}
        </Link>
      </TableCell>
      <TableCell>{shift.location.name}</TableCell>
      <TableCell className="tabular-nums">{formatShiftDate(shift.startsAt, i18n.language)}</TableCell>
      <TableCell className="tabular-nums">{formatShiftTime(t, i18n.language, shift)}</TableCell>
      <TableCell>
        <PortalStatusBadge status={shift.status} />
      </TableCell>
      <TableCell>
        <FillStatus shift={shift} />
      </TableCell>
    </TableRow>
  )
}

const SKELETON_ROWS = 5

function PortalTableSkeleton() {
  const { t } = useTranslation()

  return (
    <div role="status" aria-label={t('shifts.loading')}>
      <PortalTableFrame>
        {Array.from({ length: SKELETON_ROWS }, (_, row) => (
          <TableRow key={row}>
            <TableCell>
              <Skeleton className="h-3.5 w-36" />
            </TableCell>
            <TableCell>
              <Skeleton className="h-3.5 w-28" />
            </TableCell>
            <TableCell>
              <Skeleton className="h-3.5 w-24" />
            </TableCell>
            <TableCell>
              <Skeleton className="h-3.5 w-24" />
            </TableCell>
            <TableCell>
              <Skeleton className="h-6.5 w-24 rounded-full" />
            </TableCell>
            <TableCell>
              <Skeleton className="h-3.5 w-14" />
            </TableCell>
          </TableRow>
        ))}
      </PortalTableFrame>
    </div>
  )
}
