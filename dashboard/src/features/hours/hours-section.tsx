import { Clock } from 'lucide-react'
import { useTranslation } from 'react-i18next'

import {
  AssignmentStatus,
  HoursStatus,
  type Shift,
  type ShiftAssignment,
  ShiftStatus,
} from '@/api/generated'
import { Badge } from '@/components/ui/badge'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import { formatShiftTime } from '@/features/shifts/format'
import { useShiftAssignments, workerName } from '@/features/shifts/queries'

import { formatHours, formatMoney, formatTime, HOURS_STATUS_VARIANT } from './format'
import { HoursDialog } from './hours-dialog'

/** Hours exist for a shift that took place: published or completed, and started. */
function hasStarted(shift: Shift) {
  return (
    (shift.status === ShiftStatus.PUBLISHED || shift.status === ShiftStatus.COMPLETED) &&
    shift.startsAt.getTime() <= Date.now()
  )
}

/** Who held a confirmed spot works and gets hours; no-shows and cancelled claims do not. */
function hasWorked(assignment: ShiftAssignment) {
  return (
    assignment.status === AssignmentStatus.CONFIRMED ||
    assignment.status === AssignmentStatus.COMPLETED
  )
}

/**
 * The hours of a started shift: everyone who held a confirmed spot, with the planned times,
 * check-in and check-out, and whether the hours are approved. The claims section above
 * carries loading and error.
 */
export function HoursSection({ shift }: { shift: Shift }) {
  const { t } = useTranslation()
  const assignments = useShiftAssignments(shift.id)

  if (!hasStarted(shift) || !assignments.isSuccess) {
    return null
  }

  const worked = assignments.data.content.filter(hasWorked)

  return (
    <section aria-labelledby="hours" className="space-y-4">
      <div className="space-y-1">
        <h2 id="hours" className="type-heading-sm">
          {t('hours.section.title')}
        </h2>
        <p className="type-body-sm text-ink-secondary">{t('hours.section.description')}</p>
      </div>
      {worked.length === 0 ? (
        <div className="flex items-center gap-3 rounded-lg border bg-surface-card px-6 py-5 text-ink-secondary">
          <Clock aria-hidden className="size-5" />
          <p>{t('hours.section.empty')}</p>
        </div>
      ) : (
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>{t('hours.columns.name')}</TableHead>
              <TableHead>{t('hours.columns.planned')}</TableHead>
              <TableHead>{t('hours.columns.checkedIn')}</TableHead>
              <TableHead>{t('hours.columns.checkedOut')}</TableHead>
              <TableHead>{t('hours.columns.hours')}</TableHead>
              <TableHead>
                <span className="sr-only">{t('shifts.columns.actions')}</span>
              </TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {worked.map((assignment) => (
              <HoursRow key={assignment.id} shift={shift} assignment={assignment} />
            ))}
          </TableBody>
        </Table>
      )}
    </section>
  )
}

function HoursRow({ shift, assignment }: { shift: Shift; assignment: ShiftAssignment }) {
  const { t, i18n } = useTranslation()
  const { hours } = assignment
  const status = hours ? HoursStatus.APPROVED : HoursStatus.OPEN

  return (
    <TableRow>
      <TableCell className="font-semibold">{workerName(assignment)}</TableCell>
      <TableCell className="tabular-nums">
        {formatShiftTime(t, i18n.language, { ...shift, endIsEstimate: false })}
      </TableCell>
      <TableCell className="tabular-nums">
        <Stamp at={assignment.checkedInAt} missing={t('hours.section.notCheckedIn')} />
      </TableCell>
      <TableCell className="tabular-nums">
        <Stamp at={assignment.checkedOutAt} missing={t('hours.section.notCheckedOut')} />
      </TableCell>
      <TableCell className="whitespace-normal">
        <div className="flex flex-col items-start gap-1">
          <Badge variant={HOURS_STATUS_VARIANT[status]}>{t(`hours.status.${status}`)}</Badge>
          {hours && (
            <span className="type-body-sm text-ink-secondary tabular-nums">
              {t('hours.section.approved', {
                hours: formatHours(t, i18n.language, hours.workedMinutes),
                gross: formatMoney(i18n.language, hours.grossCents),
                time: t('shifts.time.range', {
                  start: formatTime(i18n.language, hours.startedAt),
                  end: formatTime(i18n.language, hours.endedAt),
                }),
                break: hours.breakMinutes,
              })}
            </span>
          )}
        </div>
      </TableCell>
      <TableCell>
        <div className="flex justify-end">
          <HoursDialog shift={shift} assignment={assignment} />
        </div>
      </TableCell>
    </TableRow>
  )
}

function Stamp({ at, missing }: { at: Date | undefined; missing: string }) {
  const { i18n } = useTranslation()

  if (!at) {
    return (
      <span className="text-ink-tertiary">
        <span aria-hidden>–</span>
        <span className="sr-only">{missing}</span>
      </span>
    )
  }
  return formatTime(i18n.language, at)
}
