import { Building2, ChevronRight, TriangleAlert } from 'lucide-react'
import { type ReactNode, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Link } from 'react-router'

import type { Client } from '@/api/generated'
import { PageHeader } from '@/components/page-header'
import { Pagination } from '@/components/pagination'
import { StateCard } from '@/components/state-card'
import { Button } from '@/components/ui/button'
import { Skeleton } from '@/components/ui/skeleton'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'

import { ClientPortalGate } from './client-portal-gate'
import { useClients } from './queries'

export function ClientsPage() {
  const { t } = useTranslation()

  return (
    <div className="space-y-8">
      <PageHeader title={t('clients.title')} description={t('clients.description')} />
      <ClientPortalGate>
        <ClientList />
      </ClientPortalGate>
    </div>
  )
}

function ClientList() {
  const { t } = useTranslation()
  const [page, setPage] = useState(0)
  const clients = useClients(page)

  if (clients.isPending) {
    return <ClientTableSkeleton />
  }

  if (clients.isError) {
    return (
      <StateCard
        icon={<TriangleAlert className="text-danger-text" />}
        title={t('clients.error.title')}
        description={t('clients.error.description')}
        action={
          <Button
            variant="outline"
            disabled={clients.isFetching}
            onClick={() => {
              void clients.refetch()
            }}
          >
            {t('clients.error.retry')}
          </Button>
        }
      />
    )
  }

  const { content, totalElements, totalPages } = clients.data

  if (totalElements === 0) {
    return (
      <StateCard
        icon={<Building2 />}
        title={t('clients.empty.title')}
        description={t('clients.empty.description')}
      />
    )
  }

  return (
    <>
      <ClientTableFrame>
        {content.map((client) => (
          <ClientRow key={client.id} client={client} />
        ))}
      </ClientTableFrame>

      <div className="flex flex-wrap items-center justify-between gap-4">
        <p className="type-body-sm text-ink-secondary">
          {t('clients.count', { count: totalElements })}
        </p>
        <Pagination
          page={page}
          totalPages={totalPages}
          disabled={clients.isPlaceholderData}
          onPageChange={setPage}
        />
      </div>
    </>
  )
}

function ClientTableFrame({ children }: { children: ReactNode }) {
  const { t } = useTranslation()

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>{t('clients.columns.name')}</TableHead>
          <TableHead>{t('clients.columns.locations')}</TableHead>
          <TableHead>
            <span className="sr-only">{t('clients.columns.actions')}</span>
          </TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>{children}</TableBody>
    </Table>
  )
}

function ClientRow({ client }: { client: Client }) {
  const { t } = useTranslation()

  return (
    <TableRow>
      <TableCell className="font-semibold">
        <Link to={`/clients/${client.id}`} className="hover:underline">
          {client.name}
        </Link>
      </TableCell>
      <TableCell className="whitespace-normal text-ink-secondary">
        {client.locations.map((it) => it.name).join(', ')}
      </TableCell>
      <TableCell>
        <div className="flex justify-end">
          <Button asChild variant="ghost" size="sm">
            <Link to={`/clients/${client.id}`} aria-label={t('clients.accessNamed', { name: client.name })}>
              {t('clients.access')}
              <ChevronRight aria-hidden />
            </Link>
          </Button>
        </div>
      </TableCell>
    </TableRow>
  )
}

const SKELETON_ROWS = 5

function ClientTableSkeleton() {
  const { t } = useTranslation()

  return (
    <div role="status" aria-label={t('clients.loading')}>
      <ClientTableFrame>
        {Array.from({ length: SKELETON_ROWS }, (_, row) => (
          <TableRow key={row}>
            <TableCell>
              <Skeleton className="h-3.5 w-40" />
            </TableCell>
            <TableCell>
              <Skeleton className="h-3.5 w-56" />
            </TableCell>
            <TableCell>
              <div className="flex justify-end">
                <Skeleton className="h-9 w-28 rounded-full" />
              </div>
            </TableCell>
          </TableRow>
        ))}
      </ClientTableFrame>
    </div>
  )
}
