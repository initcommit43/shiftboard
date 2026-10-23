import { Inbox, LoaderCircle, TriangleAlert, Users } from 'lucide-react'
import type { ReactNode } from 'react'
import { useTranslation } from 'react-i18next'

import {
  AssignmentStatus,
  CancelledBy,
  type Shift,
  type ShiftAssignment,
} from '@/api/generated'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import { initials } from '@/lib/initials'

import { BroadcastToShift } from './broadcast-to-shift'
import { useDateTime } from './format'
import { useAssignmentDecision, useShiftAssignments, workerName } from './queries'
import { RemoveWorker } from './remove-worker'

const ASSIGNMENT_VARIANT = {
  [AssignmentStatus.PENDING]: 'open',
  [AssignmentStatus.CONFIRMED]: 'confirmed',
  [AssignmentStatus.COMPLETED]: 'confirmed',
  [AssignmentStatus.REJECTED]: 'cancelled',
  [AssignmentStatus.CANCELLED]: 'cancelled',
  [AssignmentStatus.NO_SHOW]: 'cancelled',
} as const

/** The claims on a shift: the pending ones to decide on first, then everyone else and what became of them. */
export function ClaimsSection({ shift }: { shift: Shift }) {
  const { t } = useTranslation()
  const assignments = useShiftAssignments(shift.id)

  if (assignments.isPending) {
    return (
      <div role="status" aria-label={t('shiftDetail.claims.loading')} className="space-y-4">
        <Skeleton className="h-6 w-48" />
        <Skeleton className="h-32 rounded-lg" />
      </div>
    )
  }

  if (assignments.isError) {
    return (
      <Card className="items-start">
        <div className="flex items-center gap-3">
          <TriangleAlert aria-hidden className="size-5 text-danger-text" />
          <p>{t('shiftDetail.claims.error')}</p>
        </div>
        <Button
          variant="outline"
          size="sm"
          disabled={assignments.isFetching}
          onClick={() => {
            void assignments.refetch()
          }}
        >
          {t('shiftDetail.error.retry')}
        </Button>
      </Card>
    )
  }

  const all = assignments.data.content
  const pending = all.filter((it) => it.status === AssignmentStatus.PENDING)
  const others = all.filter((it) => it.status !== AssignmentStatus.PENDING)
  const confirmed = all.filter((it) => it.status === AssignmentStatus.CONFIRMED).length

  return (
    <div className="space-y-8">
      <section aria-labelledby="claims-pending" className="space-y-4">
        <h2 id="claims-pending" className="type-heading-sm">
          {t('shiftDetail.claims.pending', { count: pending.length })}
        </h2>
        {pending.length === 0 ? (
          <EmptyRow icon={<Inbox />} text={t('shiftDetail.claims.noPending')} />
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>{t('shiftDetail.claims.columns.name')}</TableHead>
                <TableHead>{t('shiftDetail.claims.columns.phone')}</TableHead>
                <TableHead>{t('shiftDetail.claims.columns.claimedAt')}</TableHead>
                <TableHead>
                  <span className="sr-only">{t('shifts.columns.actions')}</span>
                </TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {pending.map((assignment) => (
                <PendingRow key={assignment.id} shiftId={shift.id} assignment={assignment} />
              ))}
            </TableBody>
          </Table>
        )}
      </section>

      <section aria-labelledby="claims-team" className="space-y-4">
        <div className="flex flex-wrap items-center justify-between gap-4">
          <h2 id="claims-team" className="type-heading-sm">
            {t('shiftDetail.claims.team')}
          </h2>
          {confirmed > 0 && <BroadcastToShift shiftId={shift.id} confirmed={confirmed} />}
        </div>
        {others.length === 0 ? (
          <EmptyRow icon={<Users />} text={t('shiftDetail.claims.noTeam')} />
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>{t('shiftDetail.claims.columns.name')}</TableHead>
                <TableHead>{t('shiftDetail.claims.columns.phone')}</TableHead>
                <TableHead>{t('shiftDetail.claims.columns.status')}</TableHead>
                <TableHead>{t('shiftDetail.claims.columns.decidedAt')}</TableHead>
                <TableHead>
                  <span className="sr-only">{t('shifts.columns.actions')}</span>
                </TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {others.map((assignment) => (
                <TeamRow key={assignment.id} shiftId={shift.id} assignment={assignment} />
              ))}
            </TableBody>
          </Table>
        )}
      </section>
    </div>
  )
}

export function EmptyRow({ icon, text }: { icon: ReactNode; text: string }) {
  return (
    <div className="flex items-center gap-3 rounded-lg border bg-surface-card px-6 py-5 text-ink-secondary">
      <span aria-hidden className="[&>svg]:size-5">
        {icon}
      </span>
      <p>{text}</p>
    </div>
  )
}

export function WorkerCell({ assignment }: { assignment: Parameters<typeof workerName>[0] }) {
  const name = workerName(assignment)
  return (
    <TableCell>
      <div className="flex items-center gap-3">
        <span
          aria-hidden
          className="type-caption grid size-9 shrink-0 place-items-center rounded-full border bg-surface-soft font-semibold"
        >
          {initials(name)}
        </span>
        <span className="font-semibold">{name}</span>
      </div>
    </TableCell>
  )
}

function PendingRow({ shiftId, assignment }: { shiftId: string; assignment: ShiftAssignment }) {
  const { t } = useTranslation()
  const approve = useAssignmentDecision(shiftId, 'approve')
  const reject = useAssignmentDecision(shiftId, 'reject')
  const busy = approve.isPending || reject.isPending
  const dateTime = useDateTime()
  const name = workerName(assignment)

  return (
    <TableRow>
      <WorkerCell assignment={assignment} />
      <TableCell>{assignment.worker.phone}</TableCell>
      <TableCell className="text-ink-secondary tabular-nums">
        {dateTime.format(assignment.claimedAt)}
      </TableCell>
      <TableCell>
        <div className="flex items-center justify-end gap-2">
          <Button
            variant="ghost"
            size="sm"
            className="text-danger-text hover:bg-status-cancelled-bg"
            aria-label={t('shiftDetail.claims.rejectNamed', { name })}
            disabled={busy}
            onClick={() => {
              reject.mutate(assignment)
            }}
          >
            {reject.isPending && <LoaderCircle aria-hidden className="animate-spin" />}
            {t('shiftDetail.claims.reject')}
          </Button>
          <Button
            size="sm"
            aria-label={t('shiftDetail.claims.approveNamed', { name })}
            disabled={busy}
            onClick={() => {
              approve.mutate(assignment)
            }}
          >
            {approve.isPending && <LoaderCircle aria-hidden className="animate-spin" />}
            {t('shiftDetail.claims.approve')}
          </Button>
        </div>
      </TableCell>
    </TableRow>
  )
}

function statusLabel(t: ReturnType<typeof useTranslation>['t'], assignment: ShiftAssignment) {
  if (assignment.status === AssignmentStatus.CANCELLED) {
    return t(
      assignment.cancelledBy === CancelledBy.WORKER
        ? 'shiftDetail.claims.status.cancelledByWorker'
        : assignment.reason
          ? 'shiftDetail.claims.status.removed'
          : 'shiftDetail.claims.status.cancelledWithShift',
    )
  }
  return t(`shiftDetail.claims.status.${assignment.status}`)
}

function TeamRow({ shiftId, assignment }: { shiftId: string; assignment: ShiftAssignment }) {
  const { t } = useTranslation()
  const noShow = useAssignmentDecision(shiftId, 'noShow')
  const dateTime = useDateTime()
  const name = workerName(assignment)
  // Who checked in or has approved hours was there and can't be a no-show (ADR 0028).
  const attended = assignment.checkedInAt !== undefined || assignment.hours !== undefined

  return (
    <TableRow>
      <WorkerCell assignment={assignment} />
      <TableCell>{assignment.worker.phone}</TableCell>
      <TableCell className="whitespace-normal">
        <div className="flex flex-col items-start gap-1">
          <Badge variant={ASSIGNMENT_VARIANT[assignment.status]}>{statusLabel(t, assignment)}</Badge>
          {assignment.reason && (
            <span className="type-body-sm text-ink-secondary">
              {t('shiftDetail.claims.reason', { reason: assignment.reason })}
            </span>
          )}
        </div>
      </TableCell>
      <TableCell className="text-ink-secondary tabular-nums">
        {assignment.decidedAt && dateTime.format(assignment.decidedAt)}
      </TableCell>
      <TableCell>
        <div className="flex items-center justify-end gap-2">
          {assignment.status === AssignmentStatus.CONFIRMED && (
            <RemoveWorker shiftId={shiftId} assignment={assignment} />
          )}
          {assignment.status === AssignmentStatus.COMPLETED && !attended && (
            <Button
              variant="outline"
              size="sm"
              aria-label={t('shiftDetail.claims.noShowNamed', { name })}
              disabled={noShow.isPending}
              onClick={() => {
                noShow.mutate(assignment)
              }}
            >
              {noShow.isPending && <LoaderCircle aria-hidden className="animate-spin" />}
              {t('shiftDetail.claims.noShow')}
            </Button>
          )}
        </div>
      </TableCell>
    </TableRow>
  )
}
