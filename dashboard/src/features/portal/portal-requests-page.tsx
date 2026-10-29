import { Inbox, Plus, TriangleAlert } from 'lucide-react'
import { type ReactNode, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Link } from 'react-router'

import { type StaffRequest, StaffRequestStatus } from '@/api/generated'
import { PageHeader } from '@/components/page-header'
import { Pagination } from '@/components/pagination'
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
import { StaffRequestStatusBadge } from '@/features/staff-requests/status'

import { useClientStaffRequests } from './queries'
import { WithdrawRequest } from './withdraw-request'

/** The staff the client has asked the agency for, newest first. */
export function PortalRequestsPage() {
  const { t } = useTranslation()
  const { agency } = useCurrentUser()

  return (
    <div className="space-y-8">
      <PageHeader
        title={t('portal.requests.title')}
        description={t('portal.requests.description', { agency: agency.name })}
        action={
          <Button asChild>
            <Link to="/portal/requests/new">
              <Plus aria-hidden />
              {t('portal.requests.new')}
            </Link>
          </Button>
        }
      />
      <RequestList />
    </div>
  )
}

function RequestList() {
  const { t } = useTranslation()
  const [page, setPage] = useState(0)
  const requests = useClientStaffRequests(page)

  if (requests.isPending) {
    return <RequestTableSkeleton />
  }

  if (requests.isError) {
    return (
      <StateCard
        icon={<TriangleAlert className="text-danger-text" />}
        title={t('portal.requests.error.title')}
        description={t('portal.requests.error.description')}
        action={
          <Button
            variant="outline"
            disabled={requests.isFetching}
            onClick={() => {
              void requests.refetch()
            }}
          >
            {t('portal.requests.error.retry')}
          </Button>
        }
      />
    )
  }

  const { content, totalElements, totalPages } = requests.data

  if (page > 0 && page >= totalPages) {
    setPage(Math.max(0, totalPages - 1))
  }

  if (totalElements === 0) {
    return (
      <StateCard
        icon={<Inbox />}
        title={t('portal.requests.empty.title')}
        description={t('portal.requests.empty.description')}
        action={
          <Button asChild variant="outline">
            <Link to="/portal/requests/new">{t('portal.requests.new')}</Link>
          </Button>
        }
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
          {t('portal.requests.count', { count: totalElements })}
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
          <TableHead>{t('portal.requests.columns.role')}</TableHead>
          <TableHead>{t('shifts.columns.location')}</TableHead>
          <TableHead>{t('shifts.columns.date')}</TableHead>
          <TableHead>{t('shifts.columns.time')}</TableHead>
          <TableHead>{t('portal.requests.columns.workerCount')}</TableHead>
          <TableHead>{t('shifts.columns.status')}</TableHead>
          <TableHead>
            <span className="sr-only">{t('portal.requests.columns.outcome')}</span>
          </TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>{children}</TableBody>
    </Table>
  )
}

function RequestRow({ request }: { request: StaffRequest }) {
  const { t, i18n } = useTranslation()

  return (
    <TableRow>
      <TableCell>
        <span className="font-semibold">{request.role}</span>
        <span className="type-caption block text-ink-secondary">
          {t('portal.requests.requestedBy', { name: request.requestedBy })}
        </span>
      </TableCell>
      <TableCell>{request.location.name}</TableCell>
      <TableCell className="tabular-nums">{formatShiftDate(request.startsAt, i18n.language)}</TableCell>
      <TableCell className="tabular-nums">{formatShiftTime(t, i18n.language, request)}</TableCell>
      <TableCell className="tabular-nums">
        {t('portal.requests.people', { count: request.workerCount })}
      </TableCell>
      <TableCell>
        <StaffRequestStatusBadge status={request.status} audience="client" />
      </TableCell>
      <TableCell className="max-w-[20rem]">
        <Outcome request={request} />
      </TableCell>
    </TableRow>
  )
}

/** What became of the request: a way to withdraw it, the shift, or why it was declined. */
function Outcome({ request }: { request: StaffRequest }) {
  const { t } = useTranslation()

  switch (request.status) {
    case StaffRequestStatus.OPEN:
      return <WithdrawRequest request={request} />
    case StaffRequestStatus.ACCEPTED:
      // Clients see the shift once the agency has published it.
      return request.shiftId ? (
        <Link
          to={`/portal/shifts/${request.shiftId}`}
          className="type-button-sm underline underline-offset-2 hover:text-ink-secondary"
        >
          {t('portal.requests.toShift')}
        </Link>
      ) : (
        <span className="text-ink-secondary">{t('portal.requests.preparing')}</span>
      )
    case StaffRequestStatus.DECLINED:
      return (
        <span className="whitespace-pre-line text-ink-secondary">
          {request.declineReason
            ? t('portal.requests.declineReason', { reason: request.declineReason })
            : t('portal.requests.declinedNoReason')}
        </span>
      )
    default:
      return null
  }
}

const SKELETON_ROWS = 5

function RequestTableSkeleton() {
  const { t } = useTranslation()

  return (
    <div role="status" aria-label={t('portal.requests.loading')}>
      <RequestTableFrame>
        {Array.from({ length: SKELETON_ROWS }, (_, row) => (
          <TableRow key={row}>
            <TableCell>
              <Skeleton className="h-3.5 w-32" />
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
              <Skeleton className="h-3.5 w-14" />
            </TableCell>
            <TableCell>
              <Skeleton className="h-6.5 w-24 rounded-full" />
            </TableCell>
            <TableCell>
              <Skeleton className="h-3.5 w-24" />
            </TableCell>
          </TableRow>
        ))}
      </RequestTableFrame>
    </div>
  )
}
