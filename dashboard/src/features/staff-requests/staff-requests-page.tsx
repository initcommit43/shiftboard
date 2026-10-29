import { Inbox, TriangleAlert } from 'lucide-react'
import { type ReactNode, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Link, useSearchParams } from 'react-router'

import type { Known } from '@/api/enums'
import { type StaffRequest, StaffRequestStatus } from '@/api/generated'
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
import { formatShiftDate, formatShiftTime, useDateTime } from '@/features/shifts/format'

import { DeclineStaffRequest } from './decline-staff-request'
import { useStaffRequests } from './queries'
import { StaffRequestStatusBadge } from './status'

/** The tabs in order, each with its value of `?status=`; open requests need none. */
const TABS = [
  { status: StaffRequestStatus.OPEN, param: null },
  { status: StaffRequestStatus.ACCEPTED, param: 'accepted' },
  { status: StaffRequestStatus.DECLINED, param: 'declined' },
  { status: StaffRequestStatus.WITHDRAWN, param: 'withdrawn' },
] as const

type Status = Known<typeof StaffRequestStatus>

function useStatus(): Status {
  const [params] = useSearchParams()
  const param = params.get('status')
  return TABS.find((it) => it.param === param)?.status ?? StaffRequestStatus.OPEN
}

/** Clients' requests for staff: the open ones to handle, and the handled ones. */
export function StaffRequestsPage() {
  const { t } = useTranslation()
  const status = useStatus()

  return (
    <div className="space-y-8">
      <PageHeader title={t('staffRequests.title')} description={t(`staffRequests.descriptions.${status}`)} />
      <PeriodTabs
        label={t('staffRequests.tabs.label')}
        current={status}
        tabs={TABS.map((tab) => ({
          period: tab.status,
          to: tab.param ? `/staff-requests?status=${tab.param}` : '/staff-requests',
          label: t(`staffRequests.tabs.${tab.status}`),
        }))}
      />
      {/* A new tab starts on its first page. */}
      <RequestList key={status} status={status} />
    </div>
  )
}

function RequestList({ status }: { status: Status }) {
  const { t } = useTranslation()
  const [page, setPage] = useState(0)
  const requests = useStaffRequests(status, page)

  if (requests.isPending) {
    return <RequestTableSkeleton />
  }

  if (requests.isError) {
    return (
      <StateCard
        icon={<TriangleAlert className="text-danger-text" />}
        title={t('staffRequests.error.title')}
        description={t('staffRequests.error.description')}
        action={
          <Button
            variant="outline"
            disabled={requests.isFetching}
            onClick={() => {
              void requests.refetch()
            }}
          >
            {t('staffRequests.error.retry')}
          </Button>
        }
      />
    )
  }

  const { content, totalElements, totalPages } = requests.data

  // The last request of the last page was handled: step back to a page that still has rows.
  if (page > 0 && page >= totalPages) {
    setPage(Math.max(0, totalPages - 1))
  }

  if (totalElements === 0) {
    return (
      <StateCard
        icon={<Inbox />}
        title={t(`staffRequests.empty.${status}.title`)}
        description={t(`staffRequests.empty.${status}.description`)}
      />
    )
  }

  return (
    <>
      <RequestTableFrame>
        {content.map((request) => (
          <RequestRow key={request.id} request={request} />
        ))}
      </RequestTableFrame>

      <div className="flex flex-wrap items-center justify-between gap-4">
        <p className="type-body-sm text-ink-secondary">
          {t(`staffRequests.count.${status}`, { count: totalElements })}
        </p>
        <Pagination
          page={page}
          totalPages={totalPages}
          disabled={requests.isPlaceholderData}
          onPageChange={setPage}
        />
      </div>
    </>
  )
}

function RequestTableFrame({ children }: { children: ReactNode }) {
  const { t } = useTranslation()

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>{t('staffRequests.columns.client')}</TableHead>
          <TableHead>{t('shifts.columns.date')}</TableHead>
          <TableHead>{t('shifts.columns.time')}</TableHead>
          <TableHead>{t('shifts.columns.location')}</TableHead>
          <TableHead>{t('staffRequests.columns.role')}</TableHead>
          <TableHead>{t('staffRequests.columns.workerCount')}</TableHead>
          <TableHead>{t('staffRequests.columns.requestedBy')}</TableHead>
          <TableHead>
            <span className="sr-only">{t('staffRequests.columns.actions')}</span>
          </TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>{children}</TableBody>
    </Table>
  )
}

function RequestRow({ request }: { request: StaffRequest }) {
  const { t, i18n } = useTranslation()
  const dateTime = useDateTime()

  return (
    <TableRow>
      <TableCell className="font-semibold">{request.client.name}</TableCell>
      <TableCell className="tabular-nums">{formatShiftDate(request.startsAt, i18n.language)}</TableCell>
      <TableCell className="tabular-nums">{formatShiftTime(t, i18n.language, request)}</TableCell>
      <TableCell>{request.location.name}</TableCell>
      <TableCell className="max-w-[18rem]">
        <span className="font-semibold">{request.role}</span>
        {request.notes && (
          <span className="type-caption line-clamp-3 whitespace-pre-line text-ink-secondary">
            {request.notes}
          </span>
        )}
      </TableCell>
      <TableCell className="tabular-nums">{request.workerCount}</TableCell>
      <TableCell>
        {request.requestedBy}
        <span className="type-caption block text-ink-secondary">{dateTime.format(request.createdAt)}</span>
      </TableCell>
      <TableCell className="max-w-[18rem]">
        <Handling request={request} />
      </TableCell>
    </TableRow>
  )
}

/** What to do with an open request, or what became of a handled one. */
function Handling({ request }: { request: StaffRequest }) {
  const { t, i18n } = useTranslation()
  const dateTime = useDateTime()
  const named = { client: request.client.name, date: formatShiftDate(request.startsAt, i18n.language) }

  switch (request.status) {
    case StaffRequestStatus.OPEN:
      return (
        <div className="flex items-center justify-end gap-2">
          <Button asChild size="sm">
            <Link
              to={`/shifts/new?request=${request.id}`}
              aria-label={t('staffRequests.toShift.actionNamed', named)}
            >
              {t('staffRequests.toShift.action')}
            </Link>
          </Button>
          <DeclineStaffRequest request={request} />
        </div>
      )
    case StaffRequestStatus.ACCEPTED:
      return request.shiftId ? (
        <Link
          to={`/shifts/${request.shiftId}`}
          className="type-button-sm underline underline-offset-2 hover:text-ink-secondary"
        >
          {t('staffRequests.openShift')}
        </Link>
      ) : null
    case StaffRequestStatus.DECLINED:
      return (
        <span className="whitespace-pre-line text-ink-secondary">
          {request.declineReason && t('staffRequests.declineReason', { reason: request.declineReason })}
        </span>
      )
    case StaffRequestStatus.WITHDRAWN:
      return request.decidedAt ? (
        <span className="text-ink-secondary">
          {t('staffRequests.withdrawnAt', { date: dateTime.format(request.decidedAt) })}
        </span>
      ) : null
    default:
      return <StaffRequestStatusBadge status={request.status} audience="agency" />
  }
}

const SKELETON_ROWS = 5

function RequestTableSkeleton() {
  const { t } = useTranslation()

  return (
    <div role="status" aria-label={t('staffRequests.loading')}>
      <RequestTableFrame>
        {Array.from({ length: SKELETON_ROWS }, (_, row) => (
          <TableRow key={row}>
            {['w-32', 'w-24', 'w-24', 'w-28', 'w-32', 'w-8', 'w-28', 'w-40'].map((width, cell) => (
              <TableCell key={cell}>
                <Skeleton className={`h-3.5 ${width}`} />
              </TableCell>
            ))}
          </TableRow>
        ))}
      </RequestTableFrame>
    </div>
  )
}
