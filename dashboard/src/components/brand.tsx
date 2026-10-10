import { CalendarCheck } from 'lucide-react'
import { useTranslation } from 'react-i18next'

import { cn } from '@/lib/utils'

export function Brand({ size = 'sm' }: { size?: 'sm' | 'lg' }) {
  const { t } = useTranslation()
  const large = size === 'lg'

  return (
    <div className="flex items-center gap-3">
      <span
        aria-hidden
        className={cn(
          'grid place-items-center rounded-lg bg-primary text-primary-foreground',
          large ? 'size-10' : 'size-8',
        )}
      >
        <CalendarCheck className={large ? 'size-[1.4rem]' : 'size-[1.125rem]'} />
      </span>
      <span
        className={cn(
          'font-semibold',
          large ? 'text-xl leading-7 tracking-[-0.0125rem]' : 'text-lg leading-[1.625rem]',
        )}
      >
        {t('app.name')}
      </span>
    </div>
  )
}
