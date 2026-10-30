import { LoaderCircle } from 'lucide-react'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'

import type { StaffRequest } from '@/api/generated'
import {
  AlertDialog,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from '@/components/ui/alert-dialog'
import { Button } from '@/components/ui/button'
import { formatShiftDate } from '@/features/shifts/format'

import { useWithdrawClientStaffRequest } from './queries'

/** Takes back an open request, after a confirmation. */
export function WithdrawRequest({ request }: { request: StaffRequest }) {
  const { t, i18n } = useTranslation()
  const withdraw = useWithdrawClientStaffRequest()
  const [open, setOpen] = useState(false)
  const date = formatShiftDate(request.startsAt, i18n.language)

  return (
    <AlertDialog
      open={open}
      onOpenChange={(next) => {
        if (!withdraw.isPending) {
          setOpen(next)
        }
      }}
    >
      <AlertDialogTrigger asChild>
        <Button
          variant="ghost"
          size="sm"
          className="text-danger-text hover:bg-status-cancelled-bg"
          aria-label={t('portal.requests.withdraw.actionNamed', { role: request.role, date })}
        >
          {t('portal.requests.withdraw.action')}
        </Button>
      </AlertDialogTrigger>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>{t('portal.requests.withdraw.title')}</AlertDialogTitle>
          <AlertDialogDescription>
            {t('portal.requests.withdraw.description', { role: request.role, date })}
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel asChild>
            <Button variant="outline" disabled={withdraw.isPending}>
              {t('portal.requests.withdraw.keep')}
            </Button>
          </AlertDialogCancel>
          <Button
            variant="destructive"
            disabled={withdraw.isPending}
            onClick={() => {
              withdraw.mutate(request, {
                onSettled: () => {
                  setOpen(false)
                },
              })
            }}
          >
            {withdraw.isPending && <LoaderCircle aria-hidden className="animate-spin" />}
            {t('portal.requests.withdraw.confirm')}
          </Button>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  )
}
