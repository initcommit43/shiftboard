import { CircleAlert, RefreshCw } from 'lucide-react'
import { useTranslation } from 'react-i18next'

import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'
import { cn } from '@/lib/utils'

import { usePing } from './use-ping'

export function SystemStatusPage() {
  const { t } = useTranslation()

  return (
    <div className="mx-auto max-w-3xl space-y-8">
      <div className="space-y-1.5">
        <h1 className="text-2xl font-semibold tracking-tight">{t('systemStatus.title')}</h1>
        <p className="text-muted-foreground">{t('systemStatus.description')}</p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>{t('systemStatus.card.title')}</CardTitle>
          <CardDescription>{t('systemStatus.card.description')}</CardDescription>
        </CardHeader>
        <CardContent>
          <ApiStatus />
        </CardContent>
      </Card>
    </div>
  )
}

function ApiStatus() {
  const { t } = useTranslation()
  const ping = usePing()

  if (ping.isPending) {
    return (
      <div role="status" aria-label={t('systemStatus.loading')} className="space-y-4">
        <Skeleton className="h-6 w-28" />
        <Skeleton className="h-10 w-56" />
      </div>
    )
  }

  if (ping.isError) {
    return (
      <Alert variant="destructive">
        <CircleAlert aria-hidden />
        <AlertTitle>{t('systemStatus.error.title')}</AlertTitle>
        <AlertDescription>
          <p>{t('systemStatus.error.description')}</p>
          <Button
            variant="outline"
            size="sm"
            className="mt-2 text-foreground"
            disabled={ping.isFetching}
            onClick={() => {
              void ping.refetch()
            }}
          >
            <RefreshCw aria-hidden className={cn(ping.isFetching && 'animate-spin')} />
            {t('systemStatus.error.retry')}
          </Button>
        </AlertDescription>
      </Alert>
    )
  }

  return (
    <div className="space-y-4">
      <p className="inline-flex items-center gap-2 rounded-full bg-success/10 px-2.5 py-1 text-sm font-medium text-success">
        <span aria-hidden className="size-2 rounded-full bg-success" />
        {t('systemStatus.success.badge')}
      </p>
      <dl className="flex gap-10 text-sm">
        <div>
          <dt className="text-muted-foreground">{t('systemStatus.success.status')}</dt>
          <dd className="font-medium">{ping.data.status}</dd>
        </div>
        <div>
          <dt className="text-muted-foreground">{t('systemStatus.success.version')}</dt>
          <dd className="font-medium tabular-nums">{ping.data.version}</dd>
        </div>
      </dl>
    </div>
  )
}
