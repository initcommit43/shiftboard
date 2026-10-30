import { CalendarPlus, History, Plus, TriangleAlert } from 'lucide-react'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Link, useSearchParams } from 'react-router'

import { ShiftPeriod } from '@/api/generated'
import { PageHeader } from '@/components/page-header'
import { Pagination } from '@/components/pagination'
import { PeriodTabs } from '@/components/period-tabs'
import { StateCard } from '@/components/state-card'
import { Button } from '@/components/ui/button'

import { useShifts } from './queries'
import { ShiftTable, ShiftTableSkeleton } from './shift-table'

const PERIOD_PARAM = 'period'

/** Upcoming by default; `?period=past` shows the shifts that have ended. */
function usePeriod(): ShiftPeriod {
  const [params] = useSearchParams()
  return params.get(PERIOD_PARAM) === 'past' ? ShiftPeriod.PAST : ShiftPeriod.UPCOMING
}

export function ShiftsPage() {
  const { t } = useTranslation()
  const period = usePeriod()

  return (
    <div className="space-y-8">
      <PageHeader
        title={t('shifts.title')}
        description={t(period === ShiftPeriod.PAST ? 'shifts.descriptionPast' : 'shifts.description')}
        action={
          <Button asChild>
            <Link to="/shifts/new">
              <Plus aria-hidden />
              {t('shifts.new')}
            </Link>
          </Button>
        }
      />
      <ShiftPeriodTabs period={period} />
      {/* A new period starts on its first page. */}
      <ShiftList key={period} period={period} />
    </div>
  )
}

function ShiftPeriodTabs({ period }: { period: ShiftPeriod }) {
  const { t } = useTranslation()

  return (
    <PeriodTabs
      label={t('shifts.periods.label')}
      current={period}
      tabs={[
        { period: ShiftPeriod.UPCOMING, to: '/shifts', label: t('shifts.periods.upcoming') },
        { period: ShiftPeriod.PAST, to: '/shifts?period=past', label: t('shifts.periods.past') },
      ]}
    />
  )
}

function ShiftList({ period }: { period: ShiftPeriod }) {
  const { t } = useTranslation()
  const [page, setPage] = useState(0)
  const shifts = useShifts(period, page)
  const past = period === ShiftPeriod.PAST

  if (shifts.isPending) {
    return <ShiftTableSkeleton />
  }

  if (shifts.isError) {
    return (
      <StateCard
        icon={<TriangleAlert className="text-danger-text" />}
        title={t('shifts.error.title')}
        description={t('shifts.error.description')}
        action={
          <Button
            variant="outline"
            disabled={shifts.isFetching}
            onClick={() => {
              void shifts.refetch()
            }}
          >
            {t('shifts.error.retry')}
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
        title={t('shifts.emptyPast.title')}
        description={t('shifts.emptyPast.description')}
      />
    ) : (
      <StateCard
        icon={<CalendarPlus />}
        title={t('shifts.empty.title')}
        description={t('shifts.empty.description')}
      />
    )
  }

  return (
    <>
      <ShiftTable shifts={content} />

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
