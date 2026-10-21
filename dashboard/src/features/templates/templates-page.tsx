import { BookmarkPlus, Pencil, TriangleAlert } from 'lucide-react'
import type { ReactNode } from 'react'
import { useTranslation } from 'react-i18next'
import { Link } from 'react-router'

import type { Client, ShiftTemplate } from '@/api/generated'
import { PageHeader } from '@/components/page-header'
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
import { useShiftFormOptions, useShiftTemplates } from '@/features/shifts/queries'
import { templateSource } from '@/features/shifts/shift-draft'

import { DeleteTemplate } from './delete-template'

export function TemplatesPage() {
  const { t } = useTranslation()

  return (
    <div className="space-y-8">
      <PageHeader title={t('templates.list.title')} description={t('templates.list.description')} />
      <TemplateList />
    </div>
  )
}

function TemplateList() {
  const { t } = useTranslation()
  const templates = useShiftTemplates()
  // Templates hold ids; the names come from the clients the shift form offers.
  const options = useShiftFormOptions()

  if (templates.isPending || options.isPending) {
    return <TemplateTableSkeleton />
  }

  if (templates.isError || options.isError) {
    return (
      <StateCard
        icon={<TriangleAlert className="text-danger-text" />}
        title={t('templates.list.error.title')}
        description={t('templates.list.error.description')}
        action={
          <Button
            variant="outline"
            disabled={templates.isFetching || options.isFetching}
            onClick={() => {
              void templates.refetch()
              void options.refetch()
            }}
          >
            {t('shifts.error.retry')}
          </Button>
        }
      />
    )
  }

  const { content } = templates.data

  if (content.length === 0) {
    return (
      <StateCard
        icon={<BookmarkPlus />}
        title={t('templates.list.empty.title')}
        description={t('templates.list.empty.description')}
        action={
          <Button asChild variant="outline">
            <Link to="/shifts/new">{t('templates.list.empty.action')}</Link>
          </Button>
        }
      />
    )
  }

  return (
    <>
      <TemplateTableFrame>
        {content.map((template) => (
          <TemplateRow key={template.id} template={template} clients={options.data.clients} />
        ))}
      </TemplateTableFrame>
      <p className="type-body-sm text-ink-secondary">
        {t('templates.list.count', { count: content.length })}
      </p>
    </>
  )
}

function TemplateTableFrame({ children }: { children: ReactNode }) {
  const { t } = useTranslation()

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>{t('templates.list.columns.name')}</TableHead>
          <TableHead>{t('shifts.columns.client')}</TableHead>
          <TableHead>{t('shifts.columns.location')}</TableHead>
          <TableHead>{t('shifts.columns.time')}</TableHead>
          <TableHead>{t('templates.list.columns.rate')}</TableHead>
          <TableHead>{t('templates.list.columns.slots')}</TableHead>
          <TableHead>
            <span className="sr-only">{t('shifts.columns.actions')}</span>
          </TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>{children}</TableBody>
    </Table>
  )
}

function TemplateRow({ template, clients }: { template: ShiftTemplate; clients: Client[] }) {
  const { t, i18n } = useTranslation()
  const client = clients.find((it) => it.id === template.clientId)
  const location = client?.locations.find((it) => it.id === template.locationId)
  const { startTime, endTime } = templateSource(template)
  const end = endTime < startTime ? t('templates.list.nextDay', { time: endTime }) : endTime
  const money = new Intl.NumberFormat(i18n.language, {
    style: 'currency',
    currency: 'EUR',
  })
  const gone = <span className="text-ink-tertiary">{t('templates.list.gone')}</span>

  return (
    <TableRow>
      <TableCell className="font-semibold">
        <Link to={`/templates/${template.id}`} className="hover:underline">
          {template.name}
        </Link>
        <span className="type-body-sm block font-normal text-ink-secondary">{template.title}</span>
      </TableCell>
      <TableCell>{client?.name ?? gone}</TableCell>
      <TableCell>{location?.name ?? gone}</TableCell>
      <TableCell className="tabular-nums">
        {t('shifts.time.range', {
          start: startTime,
          end: template.endIsEstimate ? t('shifts.time.estimated', { time: end }) : end,
        })}
      </TableCell>
      <TableCell className="tabular-nums">{money.format(template.hourlyRateCents / 100)}</TableCell>
      <TableCell className="tabular-nums">{template.slots}</TableCell>
      <TableCell>
        <div className="flex justify-end gap-1">
          <Button asChild variant="ghost" size="icon-sm">
            <Link
              to={`/templates/${template.id}`}
              aria-label={t('templates.edit.actionNamed', { name: template.name })}
              title={t('templates.edit.action')}
            >
              <Pencil aria-hidden />
            </Link>
          </Button>
          <DeleteTemplate template={template} />
        </div>
      </TableCell>
    </TableRow>
  )
}

const SKELETON_ROWS = 4

function TemplateTableSkeleton() {
  const { t } = useTranslation()

  return (
    <div role="status" aria-label={t('templates.list.loading')}>
      <TemplateTableFrame>
        {Array.from({ length: SKELETON_ROWS }, (_, row) => (
          <TableRow key={row}>
            <TableCell>
              <Skeleton className="h-3.5 w-36" />
            </TableCell>
            <TableCell>
              <Skeleton className="h-3.5 w-28" />
            </TableCell>
            <TableCell>
              <Skeleton className="h-3.5 w-28" />
            </TableCell>
            <TableCell>
              <Skeleton className="h-3.5 w-24" />
            </TableCell>
            <TableCell>
              <Skeleton className="h-3.5 w-14" />
            </TableCell>
            <TableCell>
              <Skeleton className="h-3.5 w-8" />
            </TableCell>
            <TableCell>
              <div className="flex justify-end">
                <Skeleton className="h-9 w-20 rounded-full" />
              </div>
            </TableCell>
          </TableRow>
        ))}
      </TemplateTableFrame>
    </div>
  )
}
