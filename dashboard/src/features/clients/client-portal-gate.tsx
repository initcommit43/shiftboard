import { LoaderCircle, PowerOff } from 'lucide-react'
import type { ReactNode } from 'react'
import { useTranslation } from 'react-i18next'
import { Link } from 'react-router'

import { Role } from '@/api/generated'
import { StateCard } from '@/components/state-card'
import { Button } from '@/components/ui/button'
import { useCurrentUser } from '@/features/auth/use-session'
import { useAgencyFeatures } from '@/features/settings/queries'

/**
 * Shows the client screens only while the client portal is switched on. If the
 * features can't be loaded, the screens show and the API has the last word.
 */
export function ClientPortalGate({ children }: { children: ReactNode }) {
  const { t } = useTranslation()
  const { role } = useCurrentUser()
  const features = useAgencyFeatures()

  if (features.isPending) {
    return (
      <div role="status" aria-label={t('clients.loading')} className="grid place-items-center py-24">
        <LoaderCircle aria-hidden className="size-6 animate-spin text-ink-tertiary" />
      </div>
    )
  }

  if (features.isSuccess && features.data.clientPortal !== true) {
    return (
      <StateCard
        icon={<PowerOff />}
        title={t('clients.portalOff.title')}
        description={t(
          role === Role.ADMIN ? 'clients.portalOff.descriptionAdmin' : 'clients.portalOff.description',
        )}
        action={
          role === Role.ADMIN && (
            <Button asChild variant="outline">
              <Link to="/settings">{t('clients.portalOff.toSettings')}</Link>
            </Button>
          )
        }
      />
    )
  }

  return children
}
