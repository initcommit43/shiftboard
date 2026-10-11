import { useTranslation } from 'react-i18next'

import { cn } from '@/lib/utils'

/** The wordmark. There is no logo yet, so the name set in the display face is the brand. */
export function Brand({ size = 'sm' }: { size?: 'sm' | 'lg' }) {
  const { t } = useTranslation()

  return (
    <span className={cn('lowercase', size === 'lg' ? 'type-heading-md' : 'type-heading-sm')}>
      {t('app.name')}
    </span>
  )
}
