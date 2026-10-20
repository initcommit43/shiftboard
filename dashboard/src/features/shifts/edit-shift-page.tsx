import { Lock, SearchX, TriangleAlert } from 'lucide-react'
import { useTranslation } from 'react-i18next'
import { Link, useParams } from 'react-router'

import { ApiError } from '@/api/errors'
import { PageHeader } from '@/components/page-header'
import { StateCard } from '@/components/state-card'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'

import { useShift, useShiftFormOptions } from './queries'
import { editDraftFrom, isEditable } from './shift-draft'
import { ShiftForm } from './shift-form'

/** Changes a draft, or a published shift that has not started (ADR 0026). */
export function EditShiftPage() {
  const { t } = useTranslation()
  const { shiftId = '' } = useParams()

  return (
    <div className="space-y-8">
      <PageHeader title={t('shiftEdit.title')} description={t('shiftEdit.description')} />
      <EditShift shiftId={shiftId} />
    </div>
  )
}

function EditShift({ shiftId }: { shiftId: string }) {
  const { t, i18n } = useTranslation()
  const shift = useShift(shiftId)
  const options = useShiftFormOptions()

  if (shift.isPending || options.isPending) {
    return (
      <div role="status" aria-label={t('shifts.form.loading')} className="max-w-[50rem]">
        <Card>
          <Skeleton className="h-5 w-32" />
          <Skeleton className="h-14 rounded-md" />
        </Card>
      </div>
    )
  }

  if (shift.isError && shift.error instanceof ApiError && shift.error.status === 404) {
    return (
      <StateCard
        icon={<SearchX />}
        title={t('shiftDetail.notFound.title')}
        description={t('shiftDetail.notFound.description')}
      />
    )
  }

  if (shift.isError || options.isError) {
    return (
      <StateCard
        icon={<TriangleAlert className="text-danger-text" />}
        title={t('shifts.form.error.title')}
        description={t('shifts.form.error.description')}
        action={
          <Button
            variant="outline"
            disabled={shift.isFetching || options.isFetching}
            onClick={() => {
              void shift.refetch()
              void options.refetch()
            }}
          >
            {t('shifts.error.retry')}
          </Button>
        }
      />
    )
  }

  if (!isEditable(shift.data)) {
    return (
      <StateCard
        icon={<Lock />}
        title={t('shiftEdit.notEditable.title')}
        description={t('shiftEdit.notEditable.description')}
        action={
          <Button asChild variant="outline">
            <Link to={`/shifts/${shiftId}`}>{t('shiftEdit.notEditable.back')}</Link>
          </Button>
        }
      />
    )
  }

  const { clients, qualifications } = options.data
  return (
    <ShiftForm
      clients={clients}
      qualifications={qualifications}
      initial={editDraftFrom(shift.data, clients, qualifications, i18n.language)}
      editing={shift.data}
    />
  )
}
