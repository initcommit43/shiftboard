import { LoaderCircle } from 'lucide-react'
import { useTranslation } from 'react-i18next'

/** Shown while the session is restored after a page load. */
export function SessionLoading() {
  const { t } = useTranslation()

  return (
    <div
      role="status"
      aria-label={t('shell.sessionLoading')}
      className="grid min-h-svh place-items-center"
    >
      <LoaderCircle aria-hidden className="size-6 animate-spin text-muted-foreground" />
    </div>
  )
}
