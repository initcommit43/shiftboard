import { useTranslation } from 'react-i18next'
import { Link } from 'react-router'

import { Button } from '@/components/ui/button'

export function NotFoundPage() {
  const { t } = useTranslation()

  return (
    <div className="flex max-w-md flex-col items-start gap-8 py-12">
      <div className="space-y-2">
        <h1 className="type-heading-lg">{t('notFound.title')}</h1>
        <p className="text-ink-secondary">{t('notFound.description')}</p>
      </div>
      <Button asChild variant="outline">
        <Link to="/">{t('notFound.back')}</Link>
      </Button>
    </div>
  )
}
