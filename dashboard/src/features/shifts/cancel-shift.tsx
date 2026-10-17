import { LoaderCircle } from 'lucide-react'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'

import type { Shift } from '@/api/generated'
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

import { useCancelShift } from './queries'

/** Calls off the whole shift, after a confirmation that says who is affected. */
export function CancelShift({ shift }: { shift: Shift }) {
  const { t } = useTranslation()
  const cancel = useCancelShift()
  const [open, setOpen] = useState(false)

  return (
    <AlertDialog
      open={open}
      onOpenChange={(next) => {
        if (!cancel.isPending) {
          setOpen(next)
        }
      }}
    >
      <AlertDialogTrigger asChild>
        <Button variant="outline" className="text-danger-text">
          {t('shiftDetail.cancel.action')}
        </Button>
      </AlertDialogTrigger>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>{t('shiftDetail.cancel.title')}</AlertDialogTitle>
          <AlertDialogDescription>
            {t('shiftDetail.cancel.description', { title: shift.title, count: shift.takenSlots })}
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel asChild>
            <Button variant="outline" disabled={cancel.isPending}>
              {t('shiftDetail.cancel.keep')}
            </Button>
          </AlertDialogCancel>
          <Button
            variant="destructive"
            disabled={cancel.isPending}
            onClick={() => {
              cancel.mutate(shift, {
                onSettled: () => {
                  setOpen(false)
                },
              })
            }}
          >
            {cancel.isPending && <LoaderCircle aria-hidden className="animate-spin" />}
            {t('shiftDetail.cancel.confirm')}
          </Button>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  )
}
