import { Building2, TriangleAlert } from 'lucide-react'
import { useTranslation } from 'react-i18next'

import { PageHeader } from '@/components/page-header'
import { StateCard } from '@/components/state-card'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'

import { useShiftFormOptions } from './queries'
import { ShiftForm } from './shift-form'

export function NewShiftPage() {
  const { t } = useTranslation()

  return (
    <div className="space-y-8">
      <PageHeader title={t('shifts.form.title')} description={t('shifts.form.description')} />
      <NewShift />
    </div>
  )
}

function NewShift() {
  const { t } = useTranslation()
  const options = useShiftFormOptions()

  if (options.isPending) {
    return (
      <div role="status" aria-label={t('shifts.form.loading')} className="max-w-[50rem]">
        <Card>
          <Skeleton className="h-5 w-32" />
          <div className="grid gap-4 sm:grid-cols-2">
            <Skeleton className="h-14 rounded-md" />
            <Skeleton className="h-14 rounded-md" />
            <Skeleton className="h-14 rounded-md sm:col-span-2" />
            <Skeleton className="h-28 rounded-md sm:col-span-2" />
          </div>
        </Card>
      </div>
    )
  }

  if (options.isError) {
    return (
      <StateCard
        icon={<TriangleAlert className="text-danger-text" />}
        title={t('shifts.form.error.title')}
        description={t('shifts.form.error.description')}
        action={
          <Button
            variant="outline"
            disabled={options.isFetching}
            onClick={() => {
              void options.refetch()
            }}
          >
            {t('shifts.error.retry')}
          </Button>
        }
      />
    )
  }

  if (options.data.clients.length === 0) {
    return (
      <StateCard
        icon={<Building2 />}
        title={t('shifts.form.noClients.title')}
        description={t('shifts.form.noClients.description')}
      />
    )
  }

  return <ShiftForm clients={options.data.clients} qualifications={options.data.qualifications} />
}
