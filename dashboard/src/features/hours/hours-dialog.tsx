import { CircleAlert, LoaderCircle } from 'lucide-react'
import { type ReactNode, useState } from 'react'
import { useTranslation } from 'react-i18next'

import { ApiError, errorMessage } from '@/api/errors'
import type { Shift, ShiftAssignment } from '@/api/generated'
import { Alert, AlertTitle } from '@/components/ui/alert'
import {
  AlertDialog,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { workerName } from '@/features/shifts/queries'
import { cn } from '@/lib/utils'

import { formatHours, formatMoney, formatTime } from './format'
import {
  grossCents,
  HOURS_FIELDS,
  type HoursDraft,
  hoursDraftFrom,
  type HoursErrors,
  type HoursField,
  hoursServerErrors,
  hoursTimes,
  toHoursRequest,
  validateHours,
  workedMinutes,
} from './hours-draft'
import { useApproveHours } from './queries'

const MAX_BREAK = 1440

/**
 * "Stunden erfassen", or "Stunden ändern" once approved: start, end and break of one worker,
 * prefilled from check-in and check-out or the planned times. Saving approves them.
 */
export function HoursDialog({ shift, assignment }: { shift: Shift; assignment: ShiftAssignment }) {
  const { t } = useTranslation()
  const approve = useApproveHours(shift.id)
  const [draft, setDraft] = useState<HoursDraft | null>(null)
  const [errors, setErrors] = useState<HoursErrors>({})
  const name = workerName(assignment)
  const approved = assignment.hours !== undefined

  return (
    <>
      <Button
        variant={approved ? 'ghost' : 'outline'}
        size="sm"
        aria-label={t(approved ? 'hours.approve.changeNamed' : 'hours.approve.actionNamed', { name })}
        onClick={() => {
          setDraft(hoursDraftFrom(shift, assignment))
          setErrors({})
          approve.reset()
        }}
      >
        {t(approved ? 'hours.approve.change' : 'hours.approve.action')}
      </Button>
      <AlertDialog
        open={draft !== null}
        onOpenChange={(open) => {
          if (!open && !approve.isPending) {
            setDraft(null)
          }
        }}
      >
        <AlertDialogContent className="sm:max-w-lg">
          {draft && (
            <HoursForm
              shift={shift}
              assignment={assignment}
              draft={draft}
              errors={errors}
              pending={approve.isPending}
              // Field errors are shown on their fields, everything else above them.
              failure={
                approve.isError &&
                !(approve.error instanceof ApiError && approve.error.fieldErrors.length > 0)
                  ? approve.error
                  : null
              }
              onChange={(changes) => {
                setDraft({ ...draft, ...changes })
                // A changed field is no longer wrong until it is checked again.
                setErrors((current) =>
                  Object.fromEntries(Object.entries(current).filter(([field]) => !(field in changes))),
                )
              }}
              onSubmit={() => {
                const found = validateHours(draft)
                setErrors(found)
                if (Object.keys(found).length > 0) {
                  focusFirstError(assignment.id, found)
                  return
                }
                approve.mutate(
                  { assignment, request: toHoursRequest(draft) },
                  {
                    onSuccess: () => {
                      setDraft(null)
                    },
                    onError: (error) => {
                      if (error instanceof ApiError) {
                        const rejected = hoursServerErrors(error.fieldErrors)
                        setErrors(rejected)
                        focusFirstError(assignment.id, rejected)
                      }
                    },
                  },
                )
              }}
              title={t('hours.dialog.title', { name })}
            />
          )}
        </AlertDialogContent>
      </AlertDialog>
    </>
  )
}

const fieldId = (assignmentId: string, field: HoursField) => `hours-${assignmentId}-${field}`

function focusFirstError(assignmentId: string, errors: HoursErrors) {
  const field = HOURS_FIELDS.find((it) => errors[it])
  if (field) {
    document.getElementById(fieldId(assignmentId, field))?.focus()
  }
}

function HoursForm({
  shift,
  assignment,
  draft,
  errors,
  pending,
  failure,
  title,
  onChange,
  onSubmit,
}: {
  shift: Shift
  assignment: ShiftAssignment
  draft: HoursDraft
  errors: HoursErrors
  pending: boolean
  failure: Error | null
  title: string
  onChange: (changes: Partial<HoursDraft>) => void
  onSubmit: () => void
}) {
  const { t, i18n } = useTranslation()
  const times = hoursTimes(draft)
  const worked = workedMinutes(draft)
  const time = (date: Date) => formatTime(i18n.language, date)

  const startHint = [
    t('hours.dialog.planned', { time: time(shift.startsAt) }),
    assignment.checkedInAt && t('hours.dialog.checkedIn', { time: time(assignment.checkedInAt) }),
  ]
  const endHint = [
    times?.endsNextDay && t('hours.dialog.endsNextDay'),
    t('hours.dialog.planned', { time: time(shift.endsAt) }),
    assignment.checkedOutAt && t('hours.dialog.checkedOut', { time: time(assignment.checkedOutAt) }),
  ]

  /** Label, control and error message of one field, wired up for assistive technology. */
  function field(
    name: HoursField,
    className: string,
    control: (props: {
      id: string
      'aria-invalid': boolean
      'aria-describedby': string | undefined
    }) => ReactNode,
    hint?: (string | false | undefined)[],
  ) {
    const id = fieldId(assignment.id, name)
    const error = errors[name]
    const hintText = hint?.filter(Boolean).join(' · ')
    const describedBy = error ? `${id}-error` : hintText ? `${id}-hint` : undefined

    return (
      <div className={cn('flex flex-col gap-2', className)}>
        <Label htmlFor={id}>{t(`hours.dialog.fields.${name}`)}</Label>
        {control({ id, 'aria-invalid': Boolean(error), 'aria-describedby': describedBy })}
        {error ? (
          <p id={`${id}-error`} className="type-body-sm text-danger-text">
            {t(`hours.dialog.errors.${error}`)}
          </p>
        ) : (
          hintText && (
            <p id={`${id}-hint`} className="type-body-sm text-ink-secondary">
              {hintText}
            </p>
          )
        )}
      </div>
    )
  }

  return (
    <form
      noValidate
      className="contents"
      onSubmit={(event) => {
        event.preventDefault()
        onSubmit()
      }}
    >
      <AlertDialogHeader>
        <AlertDialogTitle>{title}</AlertDialogTitle>
        <AlertDialogDescription>{t('hours.dialog.description')}</AlertDialogDescription>
      </AlertDialogHeader>
      {failure && (
        <Alert variant="destructive">
          <CircleAlert aria-hidden />
          <AlertTitle>{errorMessage(t, failure)}</AlertTitle>
        </Alert>
      )}
      <div className="grid gap-4 sm:grid-cols-2">
        {field('date', 'sm:col-span-2', (props) => (
          <Input
            {...props}
            type="date"
            value={draft.date}
            onChange={(event) => {
              onChange({ date: event.target.value })
            }}
          />
        ))}
        {field(
          'startTime',
          '',
          (props) => (
            <Input
              {...props}
              type="time"
              value={draft.startTime}
              onChange={(event) => {
                onChange({ startTime: event.target.value })
              }}
            />
          ),
          startHint,
        )}
        {field(
          'endTime',
          '',
          (props) => (
            <Input
              {...props}
              type="time"
              value={draft.endTime}
              onChange={(event) => {
                onChange({ endTime: event.target.value })
              }}
            />
          ),
          endHint,
        )}
        {field(
          'breakMinutes',
          'sm:col-span-2',
          (props) => (
            <Input
              {...props}
              type="number"
              inputMode="numeric"
              min={0}
              max={MAX_BREAK}
              value={draft.breakMinutes}
              onChange={(event) => {
                onChange({ breakMinutes: event.target.value })
              }}
            />
          ),
          [t('hours.dialog.breakHint')],
        )}
      </div>
      <dl aria-live="polite" className="grid grid-cols-2 gap-4 rounded-md bg-surface-soft px-4 py-3">
        <div className="space-y-1">
          <dt className="type-body-sm text-ink-secondary">{t('hours.dialog.worked')}</dt>
          <dd className="type-body-md-bold tabular-nums">
            {worked === null ? '–' : formatHours(t, i18n.language, worked)}
          </dd>
        </div>
        <div className="space-y-1">
          <dt className="type-body-sm text-ink-secondary">
            {t('hours.dialog.gross', { rate: formatMoney(i18n.language, shift.hourlyRateCents) })}
          </dt>
          <dd className="type-body-md-bold tabular-nums">
            {worked === null ? '–' : formatMoney(i18n.language, grossCents(worked, shift.hourlyRateCents))}
          </dd>
        </div>
      </dl>
      <AlertDialogFooter>
        <AlertDialogCancel asChild>
          <Button type="button" variant="outline" disabled={pending}>
            {t('hours.dialog.cancel')}
          </Button>
        </AlertDialogCancel>
        <Button type="submit" disabled={pending}>
          {pending && <LoaderCircle aria-hidden className="animate-spin" />}
          {t('hours.dialog.save')}
        </Button>
      </AlertDialogFooter>
    </form>
  )
}
