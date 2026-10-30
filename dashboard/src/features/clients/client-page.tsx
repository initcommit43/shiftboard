import { ArrowLeft, KeyRound, SearchX, TriangleAlert } from 'lucide-react'
import { useTranslation } from 'react-i18next'
import { Link, useParams } from 'react-router'

import { ApiError } from '@/api/errors'
import type { Client } from '@/api/generated'
import { PageHeader } from '@/components/page-header'
import { StateCard } from '@/components/state-card'
import { Button } from '@/components/ui/button'
import { Skeleton } from '@/components/ui/skeleton'

import { ClientPortalGate } from './client-portal-gate'
import { ClientUserTable, ClientUserTableSkeleton } from './client-user-table'
import { InviteClientUser } from './invite-client-user'
import { useClient, useClientUsers } from './queries'

/** A client and the people there who have access to the portal. */
export function ClientPage() {
  const { t } = useTranslation()

  return (
    <div className="space-y-8">
      <Link
        to="/clients"
        className="type-button-sm inline-flex items-center gap-2 text-ink-secondary hover:text-ink"
      >
        <ArrowLeft aria-hidden className="size-4" />
        {t('clients.back')}
      </Link>
      <ClientPortalGate>
        <ClientAccess />
      </ClientPortalGate>
    </div>
  )
}

function ClientAccess() {
  const { clientId = '' } = useParams()
  const { t } = useTranslation()
  const client = useClient(clientId)
  const users = useClientUsers(clientId)

  if (client.isPending) {
    return (
      <div className="space-y-8">
        <div className="space-y-3">
          <Skeleton className="h-9 w-72" />
          <Skeleton className="h-4 w-96" />
        </div>
        <ClientUserTableSkeleton />
      </div>
    )
  }

  if (client.isError) {
    return <LoadError retrying={client.isFetching} onRetry={() => void client.refetch()} />
  }

  const found = client.data
  if (found === null || (users.error instanceof ApiError && users.error.code === 'client_not_found')) {
    return (
      <StateCard
        icon={<SearchX />}
        title={t('clients.notFound.title')}
        description={t('clients.notFound.description')}
      />
    )
  }

  return (
    <>
      <PageHeader
        title={found.name}
        description={t('clients.users.description', { client: found.name })}
        action={<InviteClientUser clientId={clientId} clientName={found.name} />}
      />
      <Users client={found} users={users} />
    </>
  )
}

function Users({ client, users }: { client: Client; users: ReturnType<typeof useClientUsers> }) {
  const { t } = useTranslation()

  if (users.isPending) {
    return <ClientUserTableSkeleton />
  }

  if (users.isError) {
    return <LoadError retrying={users.isFetching} onRetry={() => void users.refetch()} />
  }

  if (users.data.length === 0) {
    return (
      <StateCard
        icon={<KeyRound />}
        title={t('clients.users.empty.title')}
        description={t('clients.users.empty.description', { client: client.name })}
      />
    )
  }

  return <ClientUserTable clientId={client.id} users={users.data} />
}

function LoadError({ retrying, onRetry }: { retrying: boolean; onRetry: () => void }) {
  const { t } = useTranslation()

  return (
    <StateCard
      icon={<TriangleAlert className="text-danger-text" />}
      title={t('clients.users.error.title')}
      description={t('clients.users.error.description')}
      action={
        <Button variant="outline" disabled={retrying} onClick={onRetry}>
          {t('clients.error.retry')}
        </Button>
      }
    />
  )
}
