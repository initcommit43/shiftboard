import { LoaderCircle } from 'lucide-react'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'

import type { Worker } from '@/api/generated'
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
import { useCurrentUser } from '@/features/auth/use-session'

import { fullName, useRejectSignup } from './queries'

/** The "reject" action of a row. Rejecting always goes through a confirmation. */
export function RejectSignup({ worker, disabled }: { worker: Worker; disabled: boolean }) {
  const { t } = useTranslation()
  const { agency } = useCurrentUser()
  const reject = useRejectSignup()
  const [open, setOpen] = useState(false)
  const name = fullName(worker)

  return (
    <AlertDialog
      open={open}
      onOpenChange={(next) => {
        if (!reject.isPending) {
          setOpen(next)
        }
      }}
    >
      <AlertDialogTrigger asChild>
        <Button
          variant="ghost"
          className="text-destructive hover:bg-destructive/10 hover:text-destructive dark:hover:bg-destructive/20"
          aria-label={t('signups.rejectNamed', { name })}
          disabled={disabled}
        >
          {t('signups.reject')}
        </Button>
      </AlertDialogTrigger>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>{t('signups.rejectDialog.title')}</AlertDialogTitle>
          <AlertDialogDescription>
            {t('signups.rejectDialog.description', { name, agency: agency.name })}
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel asChild>
            <Button variant="outline" disabled={reject.isPending}>
              {t('signups.rejectDialog.cancel')}
            </Button>
          </AlertDialogCancel>
          <Button
            variant="destructive"
            disabled={reject.isPending}
            onClick={() => {
              reject.mutate(worker, {
                onSettled: () => {
                  setOpen(false)
                },
              })
            }}
          >
            {reject.isPending && <LoaderCircle aria-hidden className="animate-spin" />}
            {t('signups.rejectDialog.confirm')}
          </Button>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  )
}
