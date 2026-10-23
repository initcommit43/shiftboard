import { LoaderCircle } from 'lucide-react'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'

import type { WaitlistEntry } from '@/api/generated'
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

import { useRemoveFromWaitlist, workerName } from './queries'

/**
 * Takes a worker off the waitlist after a confirmation; the worker gets a system message.
 * The dialog closes either way: after an error the refreshed line shows what happened.
 */
export function RemoveFromWaitlist({ shiftId, entry }: { shiftId: string; entry: WaitlistEntry }) {
  const { t } = useTranslation()
  const remove = useRemoveFromWaitlist(shiftId)
  const [open, setOpen] = useState(false)
  const name = workerName(entry)

  return (
    <AlertDialog
      open={open}
      onOpenChange={(next) => {
        if (!remove.isPending) {
          setOpen(next)
        }
      }}
    >
      <AlertDialogTrigger asChild>
        <Button
          variant="ghost"
          size="sm"
          className="text-danger-text hover:bg-status-cancelled-bg"
          aria-label={t('shiftDetail.waitlist.remove.actionNamed', { name })}
        >
          {t('shiftDetail.waitlist.remove.action')}
        </Button>
      </AlertDialogTrigger>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>{t('shiftDetail.waitlist.remove.title', { name })}</AlertDialogTitle>
          <AlertDialogDescription>
            {t('shiftDetail.waitlist.remove.description', { name })}
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel asChild>
            <Button variant="outline" disabled={remove.isPending}>
              {t('shiftDetail.waitlist.remove.keep')}
            </Button>
          </AlertDialogCancel>
          <Button
            variant="destructive"
            disabled={remove.isPending}
            onClick={() => {
              remove.mutate(entry, {
                onSettled: () => {
                  setOpen(false)
                },
              })
            }}
          >
            {remove.isPending && <LoaderCircle aria-hidden className="animate-spin" />}
            {t('shiftDetail.waitlist.remove.confirm')}
          </Button>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  )
}
