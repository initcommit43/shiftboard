import { ArrowLeft, Ban, SearchX, TriangleAlert, Users } from 'lucide-react'
import type { ReactNode } from 'react'
import { useTranslation } from 'react-i18next'
import { Link, useParams } from 'react-router'

import { ApiError } from '@/api/errors'
import { type ClientShiftDetail, ShiftStatus } from '@/api/generated'
import { StateCard } from '@/components/state-card'
import { Alert, AlertTitle } from '@/components/ui/alert'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'
import { formatShiftDate, formatShiftTime } from '@/features/shifts/format'
import { initials } from '@/lib/initials'

import { useClientShift } from './queries'
import { FillStatus, PortalStatusBadge } from './shift-status'

/** One of the client's shifts and who is coming. */
export function PortalShiftDetailPage() {
  const { shiftId = '' } = useParams()
  const { t } = useTranslation()
  const shift = useClientShift(shiftId)

  return (
    <div className="space-y-8">
      <Link
        to="/portal"
        className="type-button-sm inline-flex items-center gap-2 text-ink-secondary hover:text-ink"
      >
        <ArrowLeft aria-hidden className="size-4" />
        {t('portal.detail.back')}
      </Link>
      {shift.isPending ? (
        <DetailSkeleton />
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
        <Detail shift={shift.data} />
      )}
    </div>
  )
}

function Detail({ shift }: { shift: ClientShiftDetail }) {
  const { t, i18n } = useTranslation()
  const cancelled = shift.status === ShiftStatus.CANCELLED

  return (
    <>
      <div className="space-y-2">
        <h1 className="type-heading-lg">{shift.title}</h1>
        <p className="text-ink-secondary">
          {shift.location.name}, {shift.location.address}
        </p>
      </div>

      {cancelled && (
        <Alert variant="destructive">
          <Ban aria-hidden />
          <AlertTitle>{t('portal.detail.cancelled')}</AlertTitle>
        </Alert>
      )}

      <Card className="p-6">
        <dl className="grid gap-6 sm:grid-cols-4">
          <Fact label={t('shifts.columns.date')}>{formatShiftDate(shift.startsAt, i18n.language)}</Fact>
          <Fact label={t('shifts.columns.time')}>{formatShiftTime(t, i18n.language, shift)}</Fact>
          <Fact label={t('shifts.columns.status')}>
            <PortalStatusBadge status={shift.status} />
          </Fact>
          <Fact label={t('shifts.columns.spots')}>
            <FillStatus shift={shift} />
          </Fact>
        </dl>
        {shift.description && <p className="whitespace-pre-line text-ink-secondary">{shift.description}</p>}
      </Card>

      {!cancelled && <Team shift={shift} />}
    </>
  )
}

function Team({ shift }: { shift: ClientShiftDetail }) {
  const { t } = useTranslation()
  const workers = shift.confirmedWorkers

  return (
    <section aria-labelledby="portal-team" className="space-y-4">
      <div className="space-y-1">
        <h2 id="portal-team" className="type-heading-sm">
          {t('portal.detail.team')}
        </h2>
        <p className="type-body-sm text-ink-secondary">{t('portal.detail.teamHint')}</p>
      </div>
      {workers.length === 0 ? (
        <StateCard
          icon={<Users />}
          title={t('portal.detail.noTeam.title')}
          description={t('portal.detail.noTeam.description')}
        />
      ) : (
        <Card className="p-2">
          <ul aria-labelledby="portal-team" className="divide-y">
            {workers.map((worker, index) => {
              const name = `${worker.firstName} ${worker.lastName}`
              return (
                // Names are all there is; two people may share one.
                <li key={`${String(index)}-${name}`} className="flex items-center gap-3 px-4 py-3">
                  <span
                    aria-hidden
                    className="type-caption grid size-9 shrink-0 place-items-center rounded-full border bg-surface-soft font-semibold"
                  >
                    {initials(name)}
                  </span>
                  <span className="font-semibold">{name}</span>
                </li>
              )
            })}
          </ul>
        </Card>
      )}
    </section>
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

function DetailSkeleton() {
  const { t } = useTranslation()

  return (
    <div role="status" aria-label={t('shiftDetail.loading')} className="space-y-8">
      <div className="space-y-3">
        <Skeleton className="h-9 w-72" />
        <Skeleton className="h-4 w-96" />
      </div>
      <Card className="p-6">
        <div className="grid gap-6 sm:grid-cols-4">
          {Array.from({ length: 4 }, (_, index) => (
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
