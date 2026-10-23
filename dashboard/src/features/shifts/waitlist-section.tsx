import { Hourglass, TriangleAlert } from 'lucide-react'
import { useTranslation } from 'react-i18next'

import { type Shift, ShiftStatus, type WaitlistEntry } from '@/api/generated'
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
import { useAgencySettings } from '@/features/settings/queries'

import { EmptyRow, WorkerCell } from './claims-section'
import { useDateTime } from './format'
import { useShiftWaitlist } from './queries'
import { RemoveFromWaitlist } from './remove-from-waitlist'

/**
 * Whether the shift has a line to show: someone waits, or the agency uses the waitlist and
 * the shift is open for it. Switched off, the line stays visible until nobody is left (ADR 0029).
 */
function hasWaitlist(shift: Shift, waitlistOn: boolean) {
  return shift.waitingCount > 0 || (waitlistOn && shift.status === ShiftStatus.PUBLISHED)
}

/**
 * The waitlist of a shift in line order. First come, first served: the agency can take someone
 * off, but can't reorder the line or promote by hand. Who moves up shows up in the claims above.
 */
export function WaitlistSection({ shift }: { shift: Shift }) {
  const settings = useAgencySettings()

  if (!hasWaitlist(shift, settings.data?.waitlist === true)) {
    return null
  }
  return <Waitlist shift={shift} />
}

function Waitlist({ shift }: { shift: Shift }) {
  const { t } = useTranslation()
  const waitlist = useShiftWaitlist(shift.id)

  return (
    <section aria-labelledby="waitlist" className="space-y-4">
      <div className="space-y-1">
        <h2 id="waitlist" className="type-heading-sm">
          {t('shiftDetail.waitlist.title')}
        </h2>
        <p className="type-body-sm text-ink-secondary">{t('shiftDetail.waitlist.description')}</p>
      </div>
      {waitlist.isPending ? (
        <div role="status" aria-label={t('shiftDetail.waitlist.loading')}>
          <Skeleton className="h-32 rounded-lg" />
        </div>
      ) : waitlist.isError ? (
        <Card className="items-start">
          <div className="flex items-center gap-3">
            <TriangleAlert aria-hidden className="size-5 text-danger-text" />
            <p>{t('shiftDetail.waitlist.error')}</p>
          </div>
          <Button
            variant="outline"
            size="sm"
            disabled={waitlist.isFetching}
            onClick={() => {
              void waitlist.refetch()
            }}
          >
            {t('shiftDetail.error.retry')}
          </Button>
        </Card>
      ) : waitlist.data.content.length === 0 ? (
        <EmptyRow icon={<Hourglass />} text={t('shiftDetail.waitlist.empty')} />
      ) : (
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead className="w-16">{t('shiftDetail.waitlist.columns.position')}</TableHead>
              <TableHead>{t('shiftDetail.waitlist.columns.name')}</TableHead>
              <TableHead>{t('shiftDetail.waitlist.columns.phone')}</TableHead>
              <TableHead>{t('shiftDetail.waitlist.columns.joinedAt')}</TableHead>
              <TableHead>
                <span className="sr-only">{t('shifts.columns.actions')}</span>
              </TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {waitlist.data.content.map((entry) => (
              <WaitlistRow key={entry.id} shiftId={shift.id} entry={entry} />
            ))}
          </TableBody>
        </Table>
      )}
    </section>
  )
}

function WaitlistRow({ shiftId, entry }: { shiftId: string; entry: WaitlistEntry }) {
  const { t } = useTranslation()
  const dateTime = useDateTime()

  return (
    <TableRow>
      <TableCell className="type-body-md-bold tabular-nums">
        {t('shiftDetail.waitlist.position', { position: entry.position })}
      </TableCell>
      <WorkerCell assignment={entry} />
      <TableCell>{entry.worker.phone}</TableCell>
      <TableCell className="text-ink-secondary tabular-nums">
        {dateTime.format(entry.joinedAt)}
      </TableCell>
      <TableCell>
        <div className="flex items-center justify-end">
          <RemoveFromWaitlist shiftId={shiftId} entry={entry} />
        </div>
      </TableCell>
    </TableRow>
  )
}
