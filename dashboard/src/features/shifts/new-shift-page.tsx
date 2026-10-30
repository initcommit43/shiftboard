import { Building2, CircleCheck, Inbox, SearchX, TriangleAlert } from 'lucide-react'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Link, useSearchParams } from 'react-router'

import { ApiError } from '@/api/errors'
import { type Client, type Qualification, StaffRequestStatus } from '@/api/generated'
import { PageHeader } from '@/components/page-header'
import { StateCard } from '@/components/state-card'
import { Alert, AlertTitle } from '@/components/ui/alert'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Label } from '@/components/ui/label'
import { NativeSelect } from '@/components/ui/native-select'
import { Skeleton } from '@/components/ui/skeleton'
import { useStaffRequest } from '@/features/staff-requests/queries'

import { formatShiftDate } from './format'
import { useShift, useShiftFormOptions, useShiftTemplates } from './queries'
import { draftFrom, requestDraft, shiftSource, templateSource } from './shift-draft'
import { ShiftForm } from './shift-form'

/**
 * A new shift. With `?from=<shift id>` it starts as a copy of that shift without its date;
 * with `?request=<request id>` it is filled in from a client's request for staff.
 */
export function NewShiftPage() {
  const { t } = useTranslation()
  const [params] = useSearchParams()
  const request = params.get('request')
  const from = request ? null : params.get('from')
  const heading = request ? 'shifts.form.fromRequest' : from ? 'shifts.form.duplicate' : 'shifts.form'

  return (
    <div className="space-y-8">
      <PageHeader title={t(`${heading}.title`)} description={t(`${heading}.description`)} />
      <NewShift from={from} request={request} />
    </div>
  )
}

function NewShift({ from, request }: { from: string | null; request: string | null }) {
  const { t } = useTranslation()
  const options = useShiftFormOptions()

  if (options.isPending) {
    return <FormSkeleton />
  }

  if (options.isError) {
    return (
      <LoadError
        retrying={options.isFetching}
        retry={() => {
          void options.refetch()
        }}
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

  if (request) {
    return <FromRequest key={request} requestId={request} {...options.data} />
  }

  if (from) {
    // Keyed, so that duplicating another shift starts over with its values.
    return <DuplicateShift key={from} shiftId={from} {...options.data} />
  }

  return <FromTemplate {...options.data} />
}

/** A new shift, empty or filled in from a template the dispatcher picks. */
function FromTemplate({
  clients,
  qualifications,
}: {
  clients: Client[]
  qualifications: Qualification[]
}) {
  const { t, i18n } = useTranslation()
  const templates = useShiftTemplates()
  const [templateId, setTemplateId] = useState('')
  const template = templates.data?.content.find((it) => it.id === templateId)
  const count = templates.data?.content.length ?? 0

  return (
    <div className="flex flex-col gap-6">
      <div className="flex max-w-[50rem] flex-col gap-2">
        <Label htmlFor="shift-template">{t('templates.use.label')}</Label>
        <div className="sm:max-w-sm">
          <NativeSelect
            id="shift-template"
            value={templateId}
            disabled={count === 0}
            aria-describedby="shift-template-hint"
            onChange={(event) => {
              setTemplateId(event.target.value)
            }}
          >
            <option value="">
              {t(templates.isPending ? 'templates.use.loading' : 'templates.use.none')}
            </option>
            {templates.data?.content.map((it) => (
              <option key={it.id} value={it.id}>
                {it.name}
              </option>
            ))}
          </NativeSelect>
        </div>
        <p id="shift-template-hint" className="type-body-sm text-ink-secondary">
          {templates.isError ? (
            <>
              {t('templates.use.error')}{' '}
              <button
                type="button"
                className="text-ink underline underline-offset-2 hover:text-ink-secondary disabled:opacity-50"
                disabled={templates.isFetching}
                onClick={() => {
                  void templates.refetch()
                }}
              >
                {t('shifts.error.retry')}
              </button>
            </>
          ) : templates.isPending ? null : count === 0 ? (
            t('templates.use.empty')
          ) : (
            t('templates.use.hint')
          )}
        </p>
      </div>
      {/* Keyed, so that picking a template starts the form over with its values. */}
      <ShiftForm
        key={template?.id ?? 'empty'}
        clients={clients}
        qualifications={qualifications}
        {...(template && {
          initial: draftFrom(templateSource(template), clients, qualifications, i18n.language),
        })}
      />
    </div>
  )
}

function DuplicateShift({
  shiftId,
  clients,
  qualifications,
}: {
  shiftId: string
  clients: Client[]
  qualifications: Qualification[]
}) {
  const { t, i18n } = useTranslation()
  const shift = useShift(shiftId)

  if (shift.isPending) {
    return <FormSkeleton />
  }

  if (shift.isError) {
    if (shift.error instanceof ApiError && shift.error.status === 404) {
      return (
        <StateCard
          icon={<SearchX />}
          title={t('shiftDetail.notFound.title')}
          description={t('shiftDetail.notFound.description')}
        />
      )
    }
    return (
      <LoadError
        retrying={shift.isFetching}
        retry={() => {
          void shift.refetch()
        }}
      />
    )
  }

  return (
    <ShiftForm
      clients={clients}
      qualifications={qualifications}
      initial={draftFrom(shiftSource(shift.data), clients, qualifications, i18n.language)}
    />
  )
}

/** A new shift filled in from a client's request; saving it closes the request. */
function FromRequest({
  requestId,
  clients,
  qualifications,
}: {
  requestId: string
  clients: Client[]
  qualifications: Qualification[]
}) {
  const { t, i18n } = useTranslation()
  const request = useStaffRequest(requestId)

  if (request.isPending) {
    return <FormSkeleton />
  }

  if (request.isError) {
    if (request.error instanceof ApiError && request.error.status === 404) {
      return (
        <StateCard
          icon={<SearchX />}
          title={t('staffRequests.notFound.title')}
          description={t('staffRequests.notFound.description')}
          action={<BackToRequests />}
        />
      )
    }
    return (
      <LoadError
        retrying={request.isFetching}
        retry={() => {
          void request.refetch()
        }}
      />
    )
  }

  if (request.data.status !== StaffRequestStatus.OPEN) {
    return (
      <StateCard
        icon={<CircleCheck />}
        title={t('staffRequests.notOpen.title')}
        description={t('staffRequests.notOpen.description')}
        action={<BackToRequests />}
      />
    )
  }

  return (
    <div className="flex flex-col gap-6">
      <Alert className="max-w-[50rem]">
        <Inbox aria-hidden />
        <AlertTitle>
          {t('shifts.form.fromRequest.notice', {
            client: request.data.client.name,
            name: request.data.requestedBy,
            date: formatShiftDate(request.data.createdAt, i18n.language),
          })}
        </AlertTitle>
        <p className="col-start-2">{t('shifts.form.fromRequest.noticeHint')}</p>
      </Alert>
      <ShiftForm
        clients={clients}
        qualifications={qualifications}
        initial={requestDraft(request.data, clients)}
        staffRequest={request.data}
      />
    </div>
  )
}

function BackToRequests() {
  const { t } = useTranslation()

  return (
    <Button asChild variant="outline">
      <Link to="/staff-requests">{t('staffRequests.back')}</Link>
    </Button>
  )
}

function FormSkeleton() {
  const { t } = useTranslation()

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

function LoadError({ retrying, retry }: { retrying: boolean; retry: () => void }) {
  const { t } = useTranslation()

  return (
    <StateCard
      icon={<TriangleAlert className="text-danger-text" />}
      title={t('shifts.form.error.title')}
      description={t('shifts.form.error.description')}
      action={
        <Button variant="outline" disabled={retrying} onClick={retry}>
          {t('shifts.error.retry')}
        </Button>
      }
    />
  )
}
