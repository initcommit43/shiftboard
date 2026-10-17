import { CircleAlert, Info, LoaderCircle, TriangleAlert } from 'lucide-react'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'

import { errorMessage } from '@/api/errors'
import type { AgencySettings } from '@/api/generated'
import { PageHeader } from '@/components/page-header'
import { StateCard } from '@/components/state-card'
import { Alert, AlertTitle } from '@/components/ui/alert'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Skeleton } from '@/components/ui/skeleton'
import { useCurrentUser } from '@/features/auth/use-session'

import { useAgencySettings, useSaveAgencySettings } from './queries'

const MAX_DEADLINE_HOURS = 336

export function SettingsPage() {
  const { t } = useTranslation()

  return (
    <div className="space-y-8">
      <PageHeader title={t('settings.title')} description={t('settings.description')} />
      <Settings />
    </div>
  )
}

function Settings() {
  const { t } = useTranslation()
  const settings = useAgencySettings()

  if (settings.isPending) {
    return (
      <div role="status" aria-label={t('settings.loading')} className="max-w-[40rem]">
        <Card>
          <Skeleton className="h-6 w-64" />
          <Skeleton className="h-14 rounded-md" />
        </Card>
      </div>
    )
  }

  if (settings.isError) {
    return (
      <StateCard
        icon={<TriangleAlert className="text-danger-text" />}
        title={t('settings.error.title')}
        description={t('settings.error.description')}
        action={
          <Button
            variant="outline"
            disabled={settings.isFetching}
            onClick={() => {
              void settings.refetch()
            }}
          >
            {t('settings.error.retry')}
          </Button>
        }
      />
    )
  }

  return <SettingsForm saved={settings.data} />
}

function parseHours(value: string) {
  const hours = Number(value)
  return value.trim() !== '' && Number.isInteger(hours) && hours >= 0 && hours <= MAX_DEADLINE_HOURS
    ? hours
    : undefined
}

function SettingsForm({ saved }: { saved: AgencySettings }) {
  const { t } = useTranslation()
  const { role } = useCurrentUser()
  const save = useSaveAgencySettings()
  const [autoConfirm, setAutoConfirm] = useState(saved.autoConfirm)
  const [hours, setHours] = useState(String(saved.cancellationDeadlineHours))
  const [invalid, setInvalid] = useState(false)
  const readOnly = role !== 'ADMIN'

  return (
    <form
      noValidate
      className="flex max-w-[40rem] flex-col gap-6"
      onSubmit={(event) => {
        event.preventDefault()
        const cancellationDeadlineHours = parseHours(hours)
        if (cancellationDeadlineHours === undefined) {
          setInvalid(true)
          document.getElementById('settings-deadline')?.focus()
          return
        }
        save.mutate({ autoConfirm, cancellationDeadlineHours })
      }}
    >
      {readOnly && (
        <Alert>
          <Info aria-hidden />
          <AlertTitle>{t('settings.adminsOnly')}</AlertTitle>
        </Alert>
      )}
      {save.isError && (
        <Alert variant="destructive">
          <CircleAlert aria-hidden />
          <AlertTitle>{errorMessage(t, save.error)}</AlertTitle>
        </Alert>
      )}

      <Card>
        <div className="flex items-start gap-4">
          <input
            id="settings-auto-confirm"
            type="checkbox"
            className="mt-1 size-5 shrink-0 accent-action"
            checked={autoConfirm}
            disabled={readOnly}
            aria-describedby="settings-auto-confirm-hint"
            onChange={(event) => {
              setAutoConfirm(event.target.checked)
            }}
          />
          <div className="space-y-1">
            <Label htmlFor="settings-auto-confirm" className="type-body-md-bold text-ink">
              {t('settings.autoConfirm')}
            </Label>
            <p id="settings-auto-confirm-hint" className="type-body-sm text-ink-secondary">
              {t('settings.autoConfirmHint')}
            </p>
          </div>
        </div>

        <div className="flex flex-col gap-2">
          <Label htmlFor="settings-deadline">{t('settings.deadline')}</Label>
          <Input
            id="settings-deadline"
            type="number"
            inputMode="numeric"
            min={0}
            max={MAX_DEADLINE_HOURS}
            step={1}
            className="max-w-40"
            value={hours}
            disabled={readOnly}
            aria-invalid={invalid}
            aria-describedby={invalid ? 'settings-deadline-error' : 'settings-deadline-hint'}
            onChange={(event) => {
              setHours(event.target.value)
              setInvalid(false)
            }}
          />
          {invalid ? (
            <p id="settings-deadline-error" className="type-body-sm text-danger-text">
              {t('settings.deadlineInvalid')}
            </p>
          ) : (
            <p id="settings-deadline-hint" className="type-body-sm text-ink-secondary">
              {t('settings.deadlineHint')}
            </p>
          )}
        </div>
      </Card>

      {!readOnly && (
        <div>
          <Button type="submit" disabled={save.isPending}>
            {save.isPending && <LoaderCircle aria-hidden className="animate-spin" />}
            {t('settings.save')}
          </Button>
        </div>
      )}
    </form>
  )
}
