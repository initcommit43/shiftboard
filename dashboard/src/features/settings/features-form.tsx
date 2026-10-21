import { CircleAlert, LoaderCircle } from 'lucide-react'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'

import { errorMessage } from '@/api/errors'
import type { AgencyFeatures } from '@/api/generated'
import { Alert, AlertTitle } from '@/components/ui/alert'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Label } from '@/components/ui/label'
import { useCurrentUser } from '@/features/auth/use-session'

import { useAgencyFeatures, useSaveAgencyFeatures } from './queries'

/** Optional features of the agency. Shown once loaded; the workflow settings above carry the page's states. */
export function FeaturesForm() {
  const features = useAgencyFeatures()

  if (!features.isSuccess) {
    return null
  }
  return <Features saved={features.data} />
}

function Features({ saved }: { saved: AgencyFeatures }) {
  const { t } = useTranslation()
  const { role } = useCurrentUser()
  const save = useSaveAgencyFeatures()
  const [contactButton, setContactButton] = useState(saved.contactButton)
  const [checkIn, setCheckIn] = useState(saved.checkIn ?? false)
  const readOnly = role !== 'ADMIN'

  return (
    <form
      className="flex max-w-[40rem] flex-col gap-6"
      onSubmit={(event) => {
        event.preventDefault()
        save.mutate({ contactButton, checkIn })
      }}
    >
      <h2 className="type-heading-sm">{t('settings.features.title')}</h2>
      {save.isError && (
        <Alert variant="destructive">
          <CircleAlert aria-hidden />
          <AlertTitle>{errorMessage(t, save.error)}</AlertTitle>
        </Alert>
      )}
      <Card>
        <Feature
          id="settings-contact-button"
          label={t('settings.features.contactButton')}
          hint={t('settings.features.contactButtonHint')}
          checked={contactButton}
          disabled={readOnly}
          onChange={setContactButton}
        />
        <Feature
          id="settings-check-in"
          label={t('settings.features.checkIn')}
          hint={t('settings.features.checkInHint')}
          checked={checkIn}
          disabled={readOnly}
          onChange={setCheckIn}
        />
      </Card>
      {!readOnly && (
        <div>
          <Button type="submit" disabled={save.isPending}>
            {save.isPending && <LoaderCircle aria-hidden className="animate-spin" />}
            {t('settings.features.save')}
          </Button>
        </div>
      )}
    </form>
  )
}

function Feature({
  id,
  label,
  hint,
  checked,
  disabled,
  onChange,
}: {
  id: string
  label: string
  hint: string
  checked: boolean
  disabled: boolean
  onChange: (checked: boolean) => void
}) {
  return (
    <div className="flex items-start gap-4">
      <input
        id={id}
        type="checkbox"
        className="mt-1 size-5 shrink-0 accent-action"
        checked={checked}
        disabled={disabled}
        aria-describedby={`${id}-hint`}
        onChange={(event) => {
          onChange(event.target.checked)
        }}
      />
      <div className="space-y-1">
        <Label htmlFor={id} className="type-body-md-bold text-ink">
          {label}
        </Label>
        <p id={`${id}-hint`} className="type-body-sm text-ink-secondary">
          {hint}
        </p>
      </div>
    </div>
  )
}
