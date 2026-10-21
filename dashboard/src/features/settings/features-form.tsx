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
  const readOnly = role !== 'ADMIN'

  return (
    <form
      className="flex max-w-[40rem] flex-col gap-6"
      onSubmit={(event) => {
        event.preventDefault()
        save.mutate({ contactButton })
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
        <div className="flex items-start gap-4">
          <input
            id="settings-contact-button"
            type="checkbox"
            className="mt-1 size-5 shrink-0 accent-action"
            checked={contactButton}
            disabled={readOnly}
            aria-describedby="settings-contact-button-hint"
            onChange={(event) => {
              setContactButton(event.target.checked)
            }}
          />
          <div className="space-y-1">
            <Label htmlFor="settings-contact-button" className="type-body-md-bold text-ink">
              {t('settings.features.contactButton')}
            </Label>
            <p id="settings-contact-button-hint" className="type-body-sm text-ink-secondary">
              {t('settings.features.contactButtonHint')}
            </p>
          </div>
        </div>
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
