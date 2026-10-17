import { LoaderCircle } from 'lucide-react'
import type { ReactNode } from 'react'
import { useTranslation } from 'react-i18next'
import { Link } from 'react-router'

import { type Shift, ShiftStatus } from '@/api/generated'
import { Badge } from '@/components/ui/badge'
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

import { formatShiftDate, formatShiftTime, STATUS_VARIANT } from './format'
import { usePublishShift } from './queries'


function ShiftTableFrame({ children }: { children: ReactNode }) {
  const { t } = useTranslation()

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>{t('shifts.columns.shift')}</TableHead>
          <TableHead>{t('shifts.columns.client')}</TableHead>
          <TableHead>{t('shifts.columns.location')}</TableHead>
          <TableHead>{t('shifts.columns.date')}</TableHead>
          <TableHead>{t('shifts.columns.time')}</TableHead>
          <TableHead>{t('shifts.columns.status')}</TableHead>
          <TableHead>{t('shifts.columns.spots')}</TableHead>
          <TableHead>
            <span className="sr-only">{t('shifts.columns.actions')}</span>
          </TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>{children}</TableBody>
    </Table>
  )
}

export function ShiftTable({ shifts }: { shifts: Shift[] }) {
  return (
    <ShiftTableFrame>
      {shifts.map((shift) => (
        <ShiftRow key={shift.id} shift={shift} />
      ))}
    </ShiftTableFrame>
  )
}

function ShiftRow({ shift }: { shift: Shift }) {
  const { t, i18n } = useTranslation()
  const publish = usePublishShift()
  const full = shift.takenSlots >= shift.slots

  return (
    <TableRow>
      <TableCell className="font-semibold">
        <Link to={`/shifts/${shift.id}`} className="hover:underline">
          {shift.title}
        </Link>
      </TableCell>
      <TableCell>{shift.client.name}</TableCell>
      <TableCell>{shift.location.name}</TableCell>
      <TableCell className="tabular-nums">{formatShiftDate(shift.startsAt, i18n.language)}</TableCell>
      <TableCell className="tabular-nums">{formatShiftTime(t, i18n.language, shift)}</TableCell>
      <TableCell>
        <Badge variant={STATUS_VARIANT[shift.status]}>{t(`shifts.status.${shift.status}`)}</Badge>
      </TableCell>
      <TableCell>
        <div className="flex items-center gap-2">
          <span className="tabular-nums">
            {t('shifts.spots', { taken: shift.takenSlots, total: shift.slots })}
          </span>
          {full && <Badge variant="confirmed">{t('shifts.full')}</Badge>}
        </div>
      </TableCell>
      <TableCell>
        <div className="flex justify-end">
          {shift.status === ShiftStatus.DRAFT && (
            <Button
              variant="outline"
              size="sm"
              aria-label={t('shifts.publishNamed', { title: shift.title })}
              disabled={publish.isPending}
              onClick={() => {
                publish.mutate(shift)
              }}
            >
              {publish.isPending && <LoaderCircle aria-hidden className="animate-spin" />}
              {t('shifts.publish')}
            </Button>
          )}
        </div>
      </TableCell>
    </TableRow>
  )
}

const SKELETON_ROWS = 5

export function ShiftTableSkeleton() {
  const { t } = useTranslation()

  return (
    <div role="status" aria-label={t('shifts.loading')}>
      <ShiftTableFrame>
        {Array.from({ length: SKELETON_ROWS }, (_, row) => (
          <TableRow key={row}>
            <TableCell>
              <Skeleton className="h-3.5 w-36" />
            </TableCell>
            <TableCell>
              <Skeleton className="h-3.5 w-28" />
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
            <TableCell>
              <div className="flex justify-end">
                <Skeleton className="h-9 w-32 rounded-full" />
              </div>
            </TableCell>
          </TableRow>
        ))}
      </ShiftTableFrame>
    </div>
  )
}
