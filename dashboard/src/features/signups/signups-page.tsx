import { Inbox, TriangleAlert } from 'lucide-react'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'

import { PageHeader } from '@/components/page-header'
import { StateCard } from '@/components/state-card'
import { Button } from '@/components/ui/button'

import { usePendingSignups } from './queries'
import { SignupTable, SignupTableSkeleton } from './signup-table'

export function SignupsPage() {
  const { t } = useTranslation()

  return (
    <div className="space-y-6">
      <PageHeader title={t('signups.title')} description={t('signups.description')} />
      <PendingSignups />
    </div>
  )
}

function PendingSignups() {
  const { t } = useTranslation()
  const [page, setPage] = useState(0)
  const signups = usePendingSignups(page)

  if (signups.isPending) {
    return <SignupTableSkeleton />
  }

  if (signups.isError) {
    return (
      <StateCard
        icon={<TriangleAlert className="text-destructive" />}
        title={t('signups.error.title')}
        description={t('signups.error.description')}
        action={
          <Button
            variant="outline"
            disabled={signups.isFetching}
            onClick={() => {
              void signups.refetch()
            }}
          >
            {t('signups.error.retry')}
          </Button>
        }
      />
    )
  }

  const { content, totalElements, totalPages } = signups.data

  // The last signup of the last page was decided: step back to a page that still has rows.
  if (page > 0 && page >= totalPages) {
    setPage(Math.max(0, totalPages - 1))
  }

  if (totalElements === 0) {
    return (
      <StateCard
        icon={<Inbox />}
        title={t('signups.empty.title')}
        description={t('signups.empty.description')}
      />
    )
  }

  return (
    <>
      <SignupTable workers={content} />

      <div className="flex flex-wrap items-center justify-between gap-4">
        <p className="text-sm text-muted-foreground">
          {t('signups.count', { count: totalElements })}
        </p>
        {totalPages > 1 && (
          <nav aria-label={t('signups.pagination.label')} className="flex items-center gap-2">
            <span className="mr-2 text-sm text-muted-foreground">
              {t('signups.pagination.page', { page: page + 1, total: totalPages })}
            </span>
            <Button
              variant="outline"
              disabled={page === 0 || signups.isPlaceholderData}
              onClick={() => {
                setPage(page - 1)
              }}
            >
              {t('signups.pagination.previous')}
            </Button>
            <Button
              variant="outline"
              disabled={page >= totalPages - 1 || signups.isPlaceholderData}
              onClick={() => {
                setPage(page + 1)
              }}
            >
              {t('signups.pagination.next')}
            </Button>
          </nav>
        )}
      </div>
    </>
  )
}
