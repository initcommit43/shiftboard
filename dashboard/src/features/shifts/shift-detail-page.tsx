import { ArrowLeft, Copy, LoaderCircle, Pencil, SearchX, TriangleAlert } from 'lucide-react'
import type { ReactNode } from 'react'
import { useTranslation } from 'react-i18next'
import { Link, useParams } from 'react-router'

import { ApiError } from '@/api/errors'
import { type Shift, ShiftStatus } from '@/api/generated'
import { StateCard } from '@/components/state-card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'
import { HoursSection } from '@/features/hours/hours-section'

import { CancelShift } from './cancel-shift'
import { ClaimsSection } from './claims-section'
import { formatShiftDate, formatShiftTime, STATUS_VARIANT } from './format'
import { usePublishShift, useShift } from './queries'
import { SaveAsTemplate } from './save-as-template'
import { isEditable, shiftSource, sourceToTemplate } from './shift-draft'

export function ShiftDetailPage() {
  const { shiftId = '' } = useParams()
  const { t } = useTranslation()
  const shift = useShift(shiftId)

  return (
    <div className="space-y-8">
      <Link
        to="/shifts"
        className="type-button-sm inline-flex items-center gap-2 text-ink-secondary hover:text-ink"
      >
        <ArrowLeft aria-hidden className="size-4" />
        {t('shiftDetail.back')}
      </Link>
      {shift.isPending ? (
        <ShiftDetailSkeleton />
      ) : shift.isError ? (
        shift.error instanceof ApiError && shift.error.status === 404 ? (
          <StateCard
            icon={<SearchX />}
            title={t('shiftDetail.notFound.title')}
            description={t('shiftDetail.notFound.description')}
          />
        ) : (
          <StateCard
            icon={<TriangleAlert className="text-danger-text" />}
            title={t('shiftDetail.error.title')}
            description={t('shiftDetail.error.description')}
            action={
              <Button
                variant="outline"
                disabled={shift.isFetching}
                onClick={() => {
                  void shift.refetch()
                }}
              >
                {t('shiftDetail.error.retry')}
              </Button>
            }
          />
        )
      ) : (
        <ShiftDetail shift={shift.data} />
      )}
    </div>
  )
}

/** A draft or published shift can be called off until it has ended. */
function isCancellable(shift: Shift) {
  return (
    (shift.status === ShiftStatus.DRAFT || shift.status === ShiftStatus.PUBLISHED) &&
    shift.endsAt.getTime() > Date.now()
  )
}

function ShiftDetail({ shift }: { shift: Shift }) {
  const { t, i18n } = useTranslation()
  const publish = usePublishShift()
  const money = new Intl.NumberFormat(i18n.language, { style: 'currency', currency: 'EUR' })

  return (
    <>
      <div className="flex flex-wrap items-end justify-between gap-4">
        <div className="space-y-2">
          <h1 className="type-heading-lg">{shift.title}</h1>
          <p className="text-ink-secondary">
            {shift.client.name} · {shift.location.name}, {shift.location.address}
          </p>
        </div>
        <div className="flex flex-wrap gap-2">
          {isEditable(shift) && (
            <Button asChild variant="outline">
              <Link to={`/shifts/${shift.id}/edit`}>
                <Pencil aria-hidden />
                {t('shiftDetail.edit')}
              </Link>
            </Button>
          )}
          <Button asChild variant="outline">
            <Link to={`/shifts/new?from=${shift.id}`}>
              <Copy aria-hidden />
              {t('shiftDetail.duplicate')}
            </Link>
          </Button>
          <SaveAsTemplate
            defaultName={shift.title}
            prepare={() => sourceToTemplate(shiftSource(shift))}
          />
          {isCancellable(shift) && <CancelShift shift={shift} />}
          {shift.status === ShiftStatus.DRAFT && (
            <Button
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
      </div>

      <Card className="p-6">
        <dl className="grid gap-6 sm:grid-cols-5">
          <Fact label={t('shifts.columns.date')}>{formatShiftDate(shift.startsAt, i18n.language)}</Fact>
          <Fact label={t('shifts.columns.time')}>{formatShiftTime(t, i18n.language, shift)}</Fact>
          <Fact label={t('shifts.columns.status')}>
            <Badge variant={STATUS_VARIANT[shift.status]}>{t(`shifts.status.${shift.status}`)}</Badge>
          </Fact>
          <Fact label={t('shifts.columns.spots')}>
            {t('shifts.spots', { taken: shift.takenSlots, total: shift.slots })}
          </Fact>
          <Fact label={t('shiftDetail.hourlyRate')}>{money.format(shift.hourlyRateCents / 100)}</Fact>
        </dl>
        {shift.description && (
          <p className="whitespace-pre-line text-ink-secondary">{shift.description}</p>
        )}
      </Card>

      <ClaimsSection shift={shift} />

      <HoursSection shift={shift} />
    </>
  )
}

function Fact({ label, children }: { label: string; children: ReactNode }) {
  return (
    <div className="space-y-1">
      <dt className="type-body-sm text-ink-secondary">{label}</dt>
      <dd className="type-body-md-bold tabular-nums">{children}</dd>
    </div>
  )
}

function ShiftDetailSkeleton() {
  const { t } = useTranslation()

  return (
    <div role="status" aria-label={t('shiftDetail.loading')} className="space-y-8">
      <div className="space-y-3">
        <Skeleton className="h-9 w-72" />
        <Skeleton className="h-4 w-96" />
      </div>
      <Card className="p-6">
        <div className="grid gap-6 sm:grid-cols-5">
          {Array.from({ length: 5 }, (_, index) => (
            <div key={index} className="space-y-2">
              <Skeleton className="h-3.5 w-16" />
              <Skeleton className="h-4 w-24" />
            </div>
          ))}
        </div>
      </Card>
    </div>
  )
}
