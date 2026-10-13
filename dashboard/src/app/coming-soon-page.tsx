import { Hammer } from 'lucide-react'
import { useTranslation } from 'react-i18next'

import { PageHeader } from '@/components/page-header'
import { StateCard } from '@/components/state-card'

/** Placeholder for the areas of the navigation that later slices fill. */
export function ComingSoonPage({ area }: { area: 'messages' | 'settings' }) {
  const { t } = useTranslation()

  return (
    <div className="space-y-8">
      <PageHeader title={t(`shell.nav.${area}`)} />
      <StateCard
        icon={<Hammer />}
        title={t('comingSoon.title')}
        description={t('comingSoon.description')}
      />
    </div>
  )
}
