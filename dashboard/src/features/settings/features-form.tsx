import { CircleAlert, LoaderCircle } from 'lucide-react'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'

import { errorMessage } from '@/api/errors'
import type { AgencyFeatures } from '@/api/generated'
import { Alert, AlertTitle } from '@/components/ui/alert'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { useCurrentUser } from '@/features/auth/use-session'

import { useAgencyFeatures, useSaveAgencyFeatures } from './queries'
import { SettingCheckbox } from './setting-checkbox'

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
  const [clientPortal, setClientPortal] = useState(saved.clientPortal ?? false)
  const readOnly = role !== 'ADMIN'

  return (
    <form
      className="flex max-w-[40rem] flex-col gap-6"
      onSubmit={(event) => {
        event.preventDefault()
        save.mutate({ contactButton, checkIn, clientPortal })
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
        <SettingCheckbox
          id="settings-contact-button"
          label={t('settings.features.contactButton')}
          hint={t('settings.features.contactButtonHint')}
          checked={contactButton}
          disabled={readOnly}
          onChange={setContactButton}
        />
        <SettingCheckbox
          id="settings-check-in"
          label={t('settings.features.checkIn')}
          hint={t('settings.features.checkInHint')}
          checked={checkIn}
          disabled={readOnly}
          onChange={setCheckIn}
        />
        <SettingCheckbox
          id="settings-client-portal"
          label={t('settings.features.clientPortal')}
          hint={t('settings.features.clientPortalHint')}
          checked={clientPortal}
          disabled={readOnly}
          onChange={setClientPortal}
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
