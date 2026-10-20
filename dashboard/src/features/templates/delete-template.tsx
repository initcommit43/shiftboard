import { LoaderCircle, Trash2 } from 'lucide-react'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'

import type { ShiftTemplate } from '@/api/generated'
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
import { useDeleteShiftTemplate } from '@/features/shifts/queries'

/** Deletes a template after a confirmation; shifts created from it stay as they are. */
export function DeleteTemplate({ template }: { template: ShiftTemplate }) {
  const { t } = useTranslation()
  const remove = useDeleteShiftTemplate()
  const [open, setOpen] = useState(false)

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
          size="icon-sm"
          className="text-danger-text"
          aria-label={t('templates.delete.actionNamed', { name: template.name })}
          title={t('templates.delete.action')}
        >
          <Trash2 aria-hidden />
        </Button>
      </AlertDialogTrigger>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>
            {t('templates.delete.title', { name: template.name })}
          </AlertDialogTitle>
          <AlertDialogDescription>{t('templates.delete.description')}</AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel asChild>
            <Button variant="outline" disabled={remove.isPending}>
              {t('templates.delete.keep')}
            </Button>
          </AlertDialogCancel>
          <Button
            variant="destructive"
            disabled={remove.isPending}
            onClick={() => {
              remove.mutate(template, {
                onSettled: () => {
                  setOpen(false)
                },
              })
            }}
          >
            {remove.isPending && <LoaderCircle aria-hidden className="animate-spin" />}
            {t('templates.delete.confirm')}
          </Button>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  )
}
