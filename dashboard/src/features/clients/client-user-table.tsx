import { LoaderCircle } from 'lucide-react'
import { type ReactNode, useState } from 'react'
import { useTranslation } from 'react-i18next'

import { known } from '@/api/enums'
import { type ClientUser, type ClientUserInvitation, ClientUserStatus } from '@/api/generated'
import { Badge } from '@/components/ui/badge'
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

import { DeactivateClientUser } from './deactivate-client-user'
import { fullName, useRenewSetupLink } from './queries'
import { SetupLinkDialog } from './setup-link'

const STATUS_VARIANT = {
  [ClientUserStatus.INVITED]: 'open',
  [ClientUserStatus.ACTIVE]: 'confirmed',
  [ClientUserStatus.DEACTIVATED]: 'cancelled',
} as const

function StatusBadge({ status }: { status: ClientUserStatus }) {
  const { t } = useTranslation()
  const value = known(ClientUserStatus, status)

  return value ? (
    <Badge variant={STATUS_VARIANT[value]}>{t(`clients.users.status.${value}`)}</Badge>
  ) : (
    <Badge>{t('unknownValue')}</Badge>
  )
}

function ClientUserTableFrame({ children }: { children: ReactNode }) {
  const { t } = useTranslation()

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>{t('clients.users.columns.name')}</TableHead>
          <TableHead>{t('clients.users.columns.email')}</TableHead>
          <TableHead>{t('clients.users.columns.status')}</TableHead>
          <TableHead>
            <span className="sr-only">{t('clients.users.columns.actions')}</span>
          </TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>{children}</TableBody>
    </Table>
  )
}

export function ClientUserTable({ clientId, users }: { clientId: string; users: ClientUser[] }) {
  const renew = useRenewSetupLink(clientId)
  const [renewed, setRenewed] = useState<ClientUserInvitation | null>(null)

  return (
    <>
      <ClientUserTableFrame>
        {users.map((user) => (
          <ClientUserRow
            key={user.id}
            clientId={clientId}
            user={user}
            renewing={renew.isPending && renew.variables.id === user.id}
            renewDisabled={renew.isPending}
            onRenew={() => {
              renew.mutate(user, { onSuccess: setRenewed })
            }}
          />
        ))}
      </ClientUserTableFrame>
      <SetupLinkDialog
        invitation={renewed}
        onClose={() => {
          setRenewed(null)
        }}
      />
    </>
  )
}

function ClientUserRow({
  clientId,
  user,
  renewing,
  renewDisabled,
  onRenew,
}: {
  clientId: string
  user: ClientUser
  renewing: boolean
  renewDisabled: boolean
  onRenew: () => void
}) {
  const { t } = useTranslation()
  const name = fullName(user)
  const status = known(ClientUserStatus, user.status)

  return (
    <TableRow>
      <TableCell className="font-semibold">{name}</TableCell>
      <TableCell>{user.email}</TableCell>
      <TableCell>
        <StatusBadge status={user.status} />
      </TableCell>
      <TableCell>
        <div className="flex justify-end gap-2">
          {status === ClientUserStatus.INVITED && (
            <Button
              variant="outline"
              size="sm"
              aria-label={t('clients.users.renew.actionNamed', { name })}
              disabled={renewDisabled}
              onClick={onRenew}
            >
              {renewing && <LoaderCircle aria-hidden className="animate-spin" />}
              {t('clients.users.renew.action')}
            </Button>
          )}
          {(status === ClientUserStatus.INVITED || status === ClientUserStatus.ACTIVE) && (
            <DeactivateClientUser clientId={clientId} user={user} />
          )}
        </div>
      </TableCell>
    </TableRow>
  )
}

const SKELETON_ROWS = 3

export function ClientUserTableSkeleton() {
  const { t } = useTranslation()

  return (
    <div role="status" aria-label={t('clients.users.loading')}>
      <ClientUserTableFrame>
        {Array.from({ length: SKELETON_ROWS }, (_, row) => (
          <TableRow key={row}>
            <TableCell>
              <Skeleton className="h-3.5 w-36" />
            </TableCell>
            <TableCell>
              <Skeleton className="h-3.5 w-48" />
            </TableCell>
            <TableCell>
              <Skeleton className="h-6.5 w-24 rounded-full" />
            </TableCell>
            <TableCell>
              <div className="flex justify-end">
                <Skeleton className="h-9 w-32 rounded-full" />
              </div>
            </TableCell>
          </TableRow>
        ))}
      </ClientUserTableFrame>
    </div>
  )
}
