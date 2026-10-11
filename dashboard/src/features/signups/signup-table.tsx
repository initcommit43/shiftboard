import { LoaderCircle } from 'lucide-react'
import type { ReactNode } from 'react'
import { useTranslation } from 'react-i18next'

import type { Worker } from '@/api/generated'
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
import { initials } from '@/lib/initials'

import { fullName, useApproveSignup } from './queries'
import { RejectSignup } from './reject-signup'

function SignupTableFrame({ children }: { children: ReactNode }) {
  const { t } = useTranslation()

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>{t('signups.columns.name')}</TableHead>
          <TableHead>{t('signups.columns.email')}</TableHead>
          <TableHead>{t('signups.columns.phone')}</TableHead>
          <TableHead>{t('signups.columns.qualifications')}</TableHead>
          <TableHead>{t('signups.columns.registeredAt')}</TableHead>
          <TableHead>
            <span className="sr-only">{t('signups.columns.actions')}</span>
          </TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>{children}</TableBody>
    </Table>
  )
}

export function SignupTable({ workers }: { workers: Worker[] }) {
  return (
    <SignupTableFrame>
      {workers.map((worker) => (
        <SignupRow key={worker.id} worker={worker} />
      ))}
    </SignupTableFrame>
  )
}

function SignupRow({ worker }: { worker: Worker }) {
  const { t, i18n } = useTranslation()
  const approve = useApproveSignup()
  const name = fullName(worker)

  return (
    <TableRow>
      <TableCell>
        <div className="flex items-center gap-3">
          <span
            aria-hidden
            className="type-caption grid size-9 shrink-0 place-items-center rounded-full border bg-surface-soft font-semibold"
          >
            {initials(name)}
          </span>
          <span className="font-semibold">{name}</span>
        </div>
      </TableCell>
      <TableCell>{worker.email}</TableCell>
      <TableCell>{worker.phone}</TableCell>
      <TableCell className="whitespace-normal">
        <div className="flex flex-wrap gap-1">
          {worker.qualifications.map((qualification) => (
            <Badge key={qualification.id}>{qualification.name}</Badge>
          ))}
        </div>
      </TableCell>
      <TableCell className="text-ink-secondary tabular-nums">
        {new Intl.DateTimeFormat(i18n.language, {
          dateStyle: 'medium',
          timeStyle: 'short',
        }).format(worker.createdAt)}
      </TableCell>
      <TableCell>
        <div className="flex items-center justify-end gap-2">
          <RejectSignup worker={worker} disabled={approve.isPending} />
          <Button
            size="sm"
            aria-label={t('signups.approveNamed', { name })}
            disabled={approve.isPending}
            onClick={() => {
              approve.mutate(worker)
            }}
          >
            {approve.isPending && <LoaderCircle aria-hidden className="animate-spin" />}
            {t('signups.approve')}
          </Button>
        </div>
      </TableCell>
    </TableRow>
  )
}

const SKELETON_ROWS = 5

export function SignupTableSkeleton() {
  const { t } = useTranslation()

  return (
    <div role="status" aria-label={t('signups.loading')}>
      <SignupTableFrame>
        {Array.from({ length: SKELETON_ROWS }, (_, row) => (
          <TableRow key={row}>
            <TableCell>
              <div className="flex items-center gap-3">
                <Skeleton className="size-9 rounded-full" />
                <Skeleton className="h-3.5 w-22" />
              </div>
            </TableCell>
            <TableCell>
              <Skeleton className="h-3.5 w-38" />
            </TableCell>
            <TableCell>
              <Skeleton className="h-3.5 w-26" />
            </TableCell>
            <TableCell>
              <Skeleton className="h-6.5 w-24 rounded-full" />
            </TableCell>
            <TableCell>
              <Skeleton className="h-3.5 w-28" />
            </TableCell>
            <TableCell>
              <div className="flex justify-end gap-2">
                <Skeleton className="h-9 w-22 rounded-full" />
                <Skeleton className="h-9 w-24 rounded-full" />
              </div>
            </TableCell>
          </TableRow>
        ))}
      </SignupTableFrame>
    </div>
  )
}
