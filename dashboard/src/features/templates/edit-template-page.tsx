import { SearchX, TriangleAlert } from 'lucide-react'
import { useTranslation } from 'react-i18next'
import { Link, useParams } from 'react-router'

import { PageHeader } from '@/components/page-header'
import { StateCard } from '@/components/state-card'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'
import { useShiftFormOptions, useShiftTemplates } from '@/features/shifts/queries'
import { draftFrom, templateSource } from '@/features/shifts/shift-draft'
import { ShiftForm } from '@/features/shifts/shift-form'

export function EditTemplatePage() {
  const { t } = useTranslation()
  const { templateId = '' } = useParams()

  return (
    <div className="space-y-8">
      <PageHeader title={t('templates.edit.title')} description={t('templates.edit.description')} />
      <EditTemplate templateId={templateId} />
    </div>
  )
}

function EditTemplate({ templateId }: { templateId: string }) {
  const { t, i18n } = useTranslation()
  // There is no single-template endpoint; the list holds them all and is usually cached already.
  const templates = useShiftTemplates()
  const options = useShiftFormOptions()

  if (templates.isPending || options.isPending) {
    return (
      <div role="status" aria-label={t('shifts.form.loading')} className="max-w-[50rem]">
        <Card>
          <Skeleton className="h-5 w-32" />
          <Skeleton className="h-14 rounded-md" />
        </Card>
      </div>
    )
  }

  if (templates.isError || options.isError) {
    return (
      <StateCard
        icon={<TriangleAlert className="text-danger-text" />}
        title={t('shifts.form.error.title')}
        description={t('shifts.form.error.description')}
        action={
          <Button
            variant="outline"
            disabled={templates.isFetching || options.isFetching}
            onClick={() => {
              void templates.refetch()
              void options.refetch()
            }}
          >
            {t('shifts.error.retry')}
          </Button>
        }
      />
    )
  }

  const template = templates.data.content.find((it) => it.id === templateId)
  if (!template) {
    return (
      <StateCard
        icon={<SearchX />}
        title={t('templates.edit.notFound.title')}
        description={t('templates.edit.notFound.description')}
        action={
          <Button asChild variant="outline">
            <Link to="/templates">{t('templates.edit.notFound.back')}</Link>
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
      initial={draftFrom(templateSource(template), clients, qualifications, i18n.language)}
      template={{ id: template.id, name: template.name }}
    />
  )
}
