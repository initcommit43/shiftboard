import { useTranslation } from 'react-i18next'

import { Button } from '@/components/ui/button'

/** Previous and next for a paged list. Renders nothing while everything fits on one page. */
export function Pagination({
  page,
  totalPages,
  disabled = false,
  onPageChange,
}: {
  /** The current page, starting at 0. */
  page: number
  totalPages: number
  disabled?: boolean
  onPageChange: (page: number) => void
}) {
  const { t } = useTranslation()

  if (totalPages <= 1) {
    return null
  }
  return (
    <nav aria-label={t('pagination.label')} className="flex items-center gap-2">
      <span className="type-body-sm mr-2 text-ink-secondary tabular-nums">
        {t('pagination.page', { page: page + 1, total: totalPages })}
      </span>
      <Button
        variant="outline"
        size="sm"
        disabled={page === 0 || disabled}
        onClick={() => {
          onPageChange(page - 1)
        }}
      >
        {t('pagination.previous')}
      </Button>
      <Button
        variant="outline"
        size="sm"
        disabled={page >= totalPages - 1 || disabled}
        onClick={() => {
          onPageChange(page + 1)
        }}
      >
        {t('pagination.next')}
      </Button>
    </nav>
  )
}
