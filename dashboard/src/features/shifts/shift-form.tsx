import { CircleAlert, Info, LoaderCircle } from 'lucide-react'
import { type ReactNode, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Link, useNavigate } from 'react-router'

import { ApiError, errorMessage } from '@/api/errors'
import type { Client, Qualification } from '@/api/generated'
import { Alert, AlertTitle } from '@/components/ui/alert'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { NativeSelect } from '@/components/ui/native-select'
import { Textarea } from '@/components/ui/textarea'
import { cn } from '@/lib/utils'

import { formatShiftDate } from './format'
import { useCreateShift } from './queries'
import { SaveAsTemplate } from './save-as-template'
import {
  DRAFT_FIELDS,
  type DraftErrors,
  type DraftField,
  emptyDraft,
  type MissingField,
  serverErrors,
  type ShiftDraft,
  shiftTimes,
  soleLocationId,
  TEMPLATE_REQUEST_FIELDS,
  toShiftRequest,
  toTemplateRequest,
  validate,
  validateTemplate,
} from './shift-draft'

const fieldId = (field: DraftField) => `shift-${field}`

function focusFirstError(errors: DraftErrors) {
  const field = DRAFT_FIELDS.find((it) => errors[it])
  if (field) {
    document.getElementById(fieldId(field))?.focus()
  }
}

function Section({ title, children }: { title: string; children: ReactNode }) {
  return (
    <Card>
      <h2 className="type-heading-sm">{title}</h2>
      <div className="grid gap-4 sm:grid-cols-6">{children}</div>
    </Card>
  )
}

export function ShiftForm({
  clients,
  qualifications,
  initial,
}: {
  clients: Client[]
  qualifications: Qualification[]
  /** A draft filled in from a shift or template, with what of it no longer exists. */
  initial?: { draft: ShiftDraft; missing: MissingField[] }
}) {
  const { t, i18n } = useTranslation()
  const navigate = useNavigate()
  const create = useCreateShift()
  const [draft, setDraft] = useState(() => initial?.draft ?? emptyDraft(clients))
  const [errors, setErrors] = useState<DraftErrors>({})

  const locations = clients.find((client) => client.id === draft.clientId)?.locations ?? []
  const times = shiftTimes(draft)

  function change(changes: Partial<ShiftDraft>) {
    setDraft((current) => ({ ...current, ...changes }))
    // A changed field is no longer wrong until it is checked again.
    setErrors((current) =>
      Object.fromEntries(Object.entries(current).filter(([field]) => !(field in changes))),
    )
  }

  function submit(publish: boolean) {
    const found = validate(draft)
    setErrors(found)
    if (Object.keys(found).length > 0) {
      focusFirstError(found)
      return
    }
    create.mutate(toShiftRequest(draft, publish), {
      onSuccess: () => {
        void navigate('/shifts')
      },
      onError: (error) => {
        if (error instanceof ApiError) {
          const rejected = serverErrors(error.fieldErrors)
          setErrors(rejected)
          focusFirstError(rejected)
        }
      },
    })
  }

  /** Label, control and error message of one field, wired up for assistive technology. */
  function field(
    name: DraftField,
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
        <Label htmlFor={id}>{t(`shifts.form.fields.${name}`)}</Label>
        {control({ id, 'aria-invalid': Boolean(error), 'aria-describedby': describedBy })}
        {error ? (
          <p id={`${id}-error`} className="type-body-sm text-danger-text">
            {t(`shifts.form.errors.${error}`)}
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

  const publishing = create.isPending && create.variables.publish === true
  const savingDraft = create.isPending && !publishing

  return (
    <form
      noValidate
      className="flex max-w-[50rem] flex-col gap-6"
      onSubmit={(event) => {
        event.preventDefault()
        submit(true)
      }}
    >
      {initial && initial.missing.length > 0 && (
        <Alert>
          <Info aria-hidden />
          <AlertTitle>
            {t('shifts.form.missing', {
              fields: new Intl.ListFormat(i18n.language).format(
                initial.missing.map((name) => t(`shifts.form.fields.${name}`)),
              ),
            })}
          </AlertTitle>
        </Alert>
      )}

      {create.isError && (
        <Alert variant="destructive">
          <CircleAlert aria-hidden />
          <AlertTitle>{errorMessage(t, create.error)}</AlertTitle>
        </Alert>
      )}

      <Section title={t('shifts.form.sections.assignment')}>
        {field('clientId', 'sm:col-span-3', (props) => (
          <NativeSelect
            {...props}
            value={draft.clientId}
            onChange={(event) => {
              const clientId = event.target.value
              change({ clientId, locationId: soleLocationId(clients, clientId) })
            }}
          >
            <option value="">{t('shifts.form.choose')}</option>
            {clients.map((client) => (
              <option key={client.id} value={client.id}>
                {client.name}
              </option>
            ))}
          </NativeSelect>
        ))}
        {field(
          'locationId',
          'sm:col-span-3',
          (props) => (
            <NativeSelect
              {...props}
              value={draft.locationId}
              disabled={!draft.clientId}
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
        {field('title', 'sm:col-span-6', (props) => (
          <Input
            {...props}
            maxLength={120}
            placeholder={t('shifts.form.titlePlaceholder')}
            value={draft.title}
            onChange={(event) => {
              change({ title: event.target.value })
            }}
          />
        ))}
        {field(
          'description',
          'sm:col-span-6',
          (props) => (
            <Textarea
              {...props}
              maxLength={2000}
              value={draft.description}
              onChange={(event) => {
                change({ description: event.target.value })
              }}
            />
          ),
          t('shifts.form.descriptionHint'),
        )}
      </Section>

      <Section title={t('shifts.form.sections.time')}>
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
            ? t('shifts.form.endsNextDay', {
                date: formatShiftDate(times.endsAt, i18n.language),
              })
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
          {t('shifts.form.endIsEstimate')}
        </Label>
      </Section>

      <Section title={t('shifts.form.sections.terms')}>
        {field(
          'hourlyRate',
          'sm:col-span-3',
          (props) => (
            <Input
              {...props}
              inputMode="decimal"
              placeholder={t('shifts.form.hourlyRatePlaceholder')}
              value={draft.hourlyRate}
              onChange={(event) => {
                change({ hourlyRate: event.target.value })
              }}
            />
          ),
          t('shifts.form.hourlyRateHint'),
        )}
        {field('slots', 'sm:col-span-3', (props) => (
          <Input
            {...props}
            type="number"
            min={1}
            max={500}
            value={draft.slots}
            onChange={(event) => {
              change({ slots: event.target.value })
            }}
          />
        ))}
        {qualifications.length > 0 && (
          <fieldset className="flex flex-col gap-2 sm:col-span-6">
            <legend className="type-body-sm mb-2 text-ink-secondary">
              {t('shifts.form.fields.qualificationIds')}
            </legend>
            <div className="flex flex-wrap gap-2">
              {qualifications.map((qualification) => (
                <label
                  key={qualification.id}
                  className="type-button-sm inline-flex h-9 cursor-pointer items-center rounded-full border bg-surface-soft px-4 text-ink transition-colors has-checked:border-action has-checked:bg-action has-checked:text-on-action has-focus-visible:outline-2 has-focus-visible:outline-offset-2 has-focus-visible:outline-focus-ring"
                >
                  <input
                    type="checkbox"
                    className="sr-only"
                    checked={draft.qualificationIds.includes(qualification.id)}
                    onChange={(event) => {
                      change({
                        qualificationIds: event.target.checked
                          ? [...draft.qualificationIds, qualification.id]
                          : draft.qualificationIds.filter((id) => id !== qualification.id),
                      })
                    }}
                  />
                  {qualification.name}
                </label>
              ))}
            </div>
            <p
              className={cn(
                'type-body-sm',
                errors.qualificationIds ? 'text-danger-text' : 'text-ink-secondary',
              )}
            >
              {errors.qualificationIds
                ? t(`shifts.form.errors.${errors.qualificationIds}`)
                : t('shifts.form.qualificationsHint')}
            </p>
          </fieldset>
        )}
      </Section>

      <div className="flex flex-wrap items-center gap-3">
        <Button type="submit" disabled={create.isPending}>
          {publishing && <LoaderCircle aria-hidden className="animate-spin" />}
          {t('shifts.form.publish')}
        </Button>
        <Button
          type="button"
          variant="outline"
          disabled={create.isPending}
          onClick={() => {
            submit(false)
          }}
        >
          {savingDraft && <LoaderCircle aria-hidden className="animate-spin" />}
          {t('shifts.form.saveDraft')}
        </Button>
        <SaveAsTemplate
          defaultName={draft.title.trim()}
          prepare={() => {
            const found = validateTemplate(draft)
            setErrors(found)
            if (Object.keys(found).length > 0) {
              focusFirstError(found)
              return null
            }
            return toTemplateRequest(draft)
          }}
          onFieldErrors={(fieldErrors) => {
            const rejected = serverErrors(fieldErrors, TEMPLATE_REQUEST_FIELDS)
            setErrors(rejected)
            focusFirstError(rejected)
          }}
        />
        <Button asChild variant="ghost">
          <Link to="/shifts">{t('shifts.form.cancel')}</Link>
        </Button>
      </div>
    </form>
  )
}
