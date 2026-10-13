import { CalendarPlus, Plus, TriangleAlert } from 'lucide-react'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Link } from 'react-router'

import { PageHeader } from '@/components/page-header'
import { Pagination } from '@/components/pagination'
import { StateCard } from '@/components/state-card'
import { Button } from '@/components/ui/button'

import { useUpcomingShifts } from './queries'
import { ShiftTable, ShiftTableSkeleton } from './shift-table'

export function ShiftsPage() {
  const { t } = useTranslation()

  return (
    <div className="space-y-8">
      <PageHeader
        title={t('shifts.title')}
        description={t('shifts.description')}
        action={
          <Button asChild>
            <Link to="/shifts/new">
              <Plus aria-hidden />
              {t('shifts.new')}
            </Link>
          </Button>
        }
      />
      <UpcomingShifts />
    </div>
  )
}

function UpcomingShifts() {
  const { t } = useTranslation()
  const [page, setPage] = useState(0)
  const shifts = useUpcomingShifts(page)

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
    return (
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
          {t('shifts.count', { count: totalElements })}
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
