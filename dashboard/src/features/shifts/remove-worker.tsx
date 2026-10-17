import { CircleAlert, LoaderCircle } from 'lucide-react'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'

import { errorMessage } from '@/api/errors'
import type { ShiftAssignment } from '@/api/generated'
import { Alert, AlertTitle } from '@/components/ui/alert'
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
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'

import { useRemoveAssignment, workerName } from './queries'

const MAX_REASON = 500

/** Takes a confirmed worker off the shift. The reason is required and stays with the agency. */
export function RemoveWorker({
  shiftId,
  assignment,
}: {
  shiftId: string
  assignment: ShiftAssignment
}) {
  const { t } = useTranslation()
  const remove = useRemoveAssignment(shiftId)
  const [open, setOpen] = useState(false)
  const [reason, setReason] = useState('')
  const [missing, setMissing] = useState(false)
  const name = workerName(assignment)
  const id = `remove-reason-${assignment.id}`

  return (
    <AlertDialog
      open={open}
      onOpenChange={(next) => {
        if (!remove.isPending) {
          setOpen(next)
          setReason('')
          setMissing(false)
          remove.reset()
        }
      }}
    >
      <AlertDialogTrigger asChild>
        <Button
          variant="ghost"
          size="sm"
          className="text-danger-text hover:bg-status-cancelled-bg"
          aria-label={t('shiftDetail.remove.actionNamed', { name })}
        >
          {t('shiftDetail.remove.action')}
        </Button>
      </AlertDialogTrigger>
      <AlertDialogContent>
        <form
          noValidate
          className="contents"
          onSubmit={(event) => {
            event.preventDefault()
            const trimmed = reason.trim()
            if (!trimmed) {
              setMissing(true)
              document.getElementById(id)?.focus()
              return
            }
            remove.mutate(
              { assignment, reason: trimmed },
              {
                onSuccess: () => {
                  setOpen(false)
                },
              },
            )
          }}
        >
          <AlertDialogHeader>
            <AlertDialogTitle>{t('shiftDetail.remove.title', { name })}</AlertDialogTitle>
            <AlertDialogDescription>{t('shiftDetail.remove.description')}</AlertDialogDescription>
          </AlertDialogHeader>
          {remove.isError && (
            <Alert variant="destructive">
              <CircleAlert aria-hidden />
              <AlertTitle>{errorMessage(t, remove.error)}</AlertTitle>
            </Alert>
          )}
          <div className="flex flex-col gap-2">
            <Label htmlFor={id}>{t('shiftDetail.remove.reason')}</Label>
            <Textarea
              id={id}
              maxLength={MAX_REASON}
              value={reason}
              aria-invalid={missing}
              aria-describedby={missing ? `${id}-error` : undefined}
              placeholder={t('shiftDetail.remove.reasonPlaceholder')}
              onChange={(event) => {
                setReason(event.target.value)
                setMissing(false)
              }}
            />
            {missing && (
              <p id={`${id}-error`} className="type-body-sm text-danger-text">
                {t('shiftDetail.remove.reasonRequired')}
              </p>
            )}
          </div>
          <AlertDialogFooter>
            <AlertDialogCancel asChild>
              <Button type="button" variant="outline" disabled={remove.isPending}>
                {t('shiftDetail.remove.keep')}
              </Button>
            </AlertDialogCancel>
            <Button type="submit" variant="destructive" disabled={remove.isPending}>
              {remove.isPending && <LoaderCircle aria-hidden className="animate-spin" />}
              {t('shiftDetail.remove.confirm')}
            </Button>
          </AlertDialogFooter>
        </form>
      </AlertDialogContent>
    </AlertDialog>
  )
}
