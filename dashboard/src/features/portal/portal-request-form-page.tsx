import { ArrowLeft, CircleAlert, LoaderCircle, MapPinOff, TriangleAlert } from 'lucide-react'
import { type ReactNode, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Link, useNavigate } from 'react-router'

import { ApiError, errorMessage } from '@/api/errors'
import type { Location } from '@/api/generated'
import { PageHeader } from '@/components/page-header'
import { StateCard } from '@/components/state-card'
import { Alert, AlertTitle } from '@/components/ui/alert'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { NativeSelect } from '@/components/ui/native-select'
import { Skeleton } from '@/components/ui/skeleton'
import { Textarea } from '@/components/ui/textarea'
import { useCurrentUser } from '@/features/auth/use-session'
import { formatShiftDate } from '@/features/shifts/format'
import { cn } from '@/lib/utils'

import { useClientLocations, useCreateClientStaffRequest } from './queries'
import {
  emptyRequestDraft,
  REQUEST_FIELDS,
  type RequestDraft,
  type RequestErrors,
  type RequestField,
  requestServerErrors,
  requestTimes,
  toStaffRequest,
  validateRequest,
} from './request-draft'

const fieldId = (field: RequestField) => `request-${field}`

function focusFirstError(errors: RequestErrors) {
  const field = REQUEST_FIELDS.find((it) => errors[it])
  if (field) {
    document.getElementById(fieldId(field))?.focus()
  }
}

/** A new request for staff, sent to the agency. */
export function PortalRequestFormPage() {
  const { t } = useTranslation()

  return (
    <div className="space-y-8">
      <Link
        to="/portal/requests"
        className="type-button-sm inline-flex items-center gap-2 text-ink-secondary hover:text-ink"
      >
        <ArrowLeft aria-hidden className="size-4" />
        {t('portal.requests.form.back')}
      </Link>
      <PageHeader title={t('portal.requests.form.title')} description={t('portal.requests.form.description')} />
      <NewRequest />
    </div>
  )
}

function NewRequest() {
  const { t } = useTranslation()
  const { agency } = useCurrentUser()
  const locations = useClientLocations()

  if (locations.isPending) {
    return <FormSkeleton />
  }

  if (locations.isError) {
    return (
      <StateCard
        icon={<TriangleAlert className="text-danger-text" />}
        title={t('portal.requests.form.error.title')}
        description={t('portal.requests.form.error.description')}
        action={
          <Button
            variant="outline"
            disabled={locations.isFetching}
            onClick={() => {
              void locations.refetch()
            }}
          >
            {t('portal.requests.error.retry')}
          </Button>
        }
      />
    )
  }

  if (locations.data.length === 0) {
    return (
      <StateCard
        icon={<MapPinOff />}
        title={t('portal.requests.form.noLocations.title')}
        description={t('portal.requests.form.noLocations.description', { agency: agency.name })}
      />
    )
  }

  return <RequestForm locations={locations.data} />
}

function Section({ title, children }: { title: string; children: ReactNode }) {
  return (
    <Card>
      <h2 className="type-heading-sm">{title}</h2>
      <div className="grid gap-4 sm:grid-cols-6">{children}</div>
    </Card>
  )
}

function RequestForm({ locations }: { locations: Location[] }) {
  const { t, i18n } = useTranslation()
  const navigate = useNavigate()
  const create = useCreateClientStaffRequest()
  const [draft, setDraft] = useState(() => emptyRequestDraft(locations))
  const [errors, setErrors] = useState<RequestErrors>({})
  const times = requestTimes(draft)

  function change(changes: Partial<RequestDraft>) {
    setDraft((current) => ({ ...current, ...changes }))
    // A changed field is no longer wrong until it is checked again; a new day or start can fix a past start.
    setErrors((current) =>
      Object.fromEntries(
        Object.entries(current).filter(
          ([field, error]) =>
            !(field in changes) &&
            !(error === 'in_past' && ('date' in changes || 'startTime' in changes)),
        ),
      ),
    )
  }

  function submit() {
    const found = validateRequest(draft)
    setErrors(found)
    if (Object.keys(found).length > 0) {
      focusFirstError(found)
      return
    }
    create.mutate(toStaffRequest(draft), {
      onSuccess: () => {
        void navigate('/portal/requests')
      },
      onError: (error) => {
        if (error instanceof ApiError) {
          const rejected = requestServerErrors(error.fieldErrors)
          setErrors(rejected)
          focusFirstError(rejected)
        }
      },
    })
  }

  function field(
    name: RequestField,
    className: string,
    control: (props: {
      id: string
      'aria-invalid': boolean
      'aria-describedby': string | undefined
    }) => ReactNode,
    hint?: string,
  ) {
    const id = fieldId(name)
    const error = errors[name]
    const describedBy = error ? `${id}-error` : hint ? `${id}-hint` : undefined

    return (
      <div className={cn('flex flex-col gap-2', className)}>
        <Label htmlFor={id}>{t(`portal.requests.form.fields.${name}`)}</Label>
        {control({ id, 'aria-invalid': Boolean(error), 'aria-describedby': describedBy })}
        {error ? (
          <p id={`${id}-error`} className="type-body-sm text-danger-text">
            {t(`portal.requests.form.errors.${error}`)}
          </p>
        ) : (
          hint && (
            <p id={`${id}-hint`} className="type-body-sm text-ink-secondary">
              {hint}
            </p>
          )
        )}
      </div>
    )
  }

  return (
    <form
      noValidate
      className="flex max-w-[50rem] flex-col gap-6"
      onSubmit={(event) => {
        event.preventDefault()
        submit()
      }}
    >
      {create.isError && (
        <Alert variant="destructive">
          <CircleAlert aria-hidden />
          <AlertTitle>{errorMessage(t, create.error)}</AlertTitle>
        </Alert>
      )}

      <Section title={t('portal.requests.form.sections.what')}>
        {field(
          'locationId',
          'sm:col-span-3',
          (props) => (
            <NativeSelect
              {...props}
              value={draft.locationId}
              onChange={(event) => {
                change({ locationId: event.target.value })
              }}
            >
              <option value="">{t('shifts.form.choose')}</option>
              {locations.map((location) => (
                <option key={location.id} value={location.id}>
                  {location.name}
                </option>
              ))}
            </NativeSelect>
          ),
          locations.find((location) => location.id === draft.locationId)?.address,
        )}
        {field('workerCount', 'sm:col-span-3', (props) => (
          <Input
            {...props}
            type="number"
            min={1}
            max={500}
            value={draft.workerCount}
            onChange={(event) => {
              change({ workerCount: event.target.value })
            }}
          />
        ))}
        {field(
          'role',
          'sm:col-span-6',
          (props) => (
            <Input
              {...props}
              maxLength={120}
              placeholder={t('portal.requests.form.rolePlaceholder')}
              value={draft.role}
              onChange={(event) => {
                change({ role: event.target.value })
              }}
            />
          ),
          t('portal.requests.form.roleHint'),
        )}
        {field(
          'notes',
          'sm:col-span-6',
          (props) => (
            <Textarea
              {...props}
              maxLength={2000}
              value={draft.notes}
              onChange={(event) => {
                change({ notes: event.target.value })
              }}
            />
          ),
          t('portal.requests.form.notesHint'),
        )}
      </Section>

      <Section title={t('portal.requests.form.sections.time')}>
        {field('date', 'sm:col-span-2', (props) => (
          <Input
            {...props}
            type="date"
            value={draft.date}
            onChange={(event) => {
              change({ date: event.target.value })
            }}
          />
        ))}
        {field('startTime', 'sm:col-span-2', (props) => (
          <Input
            {...props}
            type="time"
            value={draft.startTime}
            onChange={(event) => {
              change({ startTime: event.target.value })
            }}
          />
        ))}
        {field(
          'endTime',
          'sm:col-span-2',
          (props) => (
            <Input
              {...props}
              type="time"
              value={draft.endTime}
              onChange={(event) => {
                change({ endTime: event.target.value })
              }}
            />
          ),
          times?.endsNextDay
            ? t('shifts.form.endsNextDay', { date: formatShiftDate(times.endsAt, i18n.language) })
            : undefined,
        )}
        <Label className="text-ink sm:col-span-6">
          <input
            type="checkbox"
            className="size-4 accent-action"
            checked={draft.endIsEstimate}
            onChange={(event) => {
              change({ endIsEstimate: event.target.checked })
            }}
          />
          {t('portal.requests.form.endIsEstimate')}
        </Label>
      </Section>

      <div className="flex flex-wrap items-center gap-3">
        <Button type="submit" disabled={create.isPending}>
          {create.isPending && <LoaderCircle aria-hidden className="animate-spin" />}
          {t('portal.requests.form.send')}
        </Button>
        <Button asChild variant="ghost">
          <Link to="/portal/requests">{t('shifts.form.cancel')}</Link>
        </Button>
      </div>
    </form>
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
