import { CircleAlert, LoaderCircle } from 'lucide-react'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { toast } from 'sonner'

import { ApiError, errorMessage } from '@/api/errors'
import type { StaffRequest } from '@/api/generated'
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
import { formatShiftDate } from '@/features/shifts/format'

import { useDeclineStaffRequest } from './queries'

const MAX_REASON = 500

/** Declines an open request. The reason is required: the client reads it in the portal. */
export function DeclineStaffRequest({ request }: { request: StaffRequest }) {
  const { t, i18n } = useTranslation()
  const decline = useDeclineStaffRequest()
  const [open, setOpen] = useState(false)
  const [reason, setReason] = useState('')
  const [missing, setMissing] = useState(false)
  const id = `decline-reason-${request.id}`
  const named = { client: request.client.name, date: formatShiftDate(request.startsAt, i18n.language) }

  return (
    <AlertDialog
      open={open}
      onOpenChange={(next) => {
        if (!decline.isPending) {
          setOpen(next)
          setReason('')
          setMissing(false)
          decline.reset()
        }
      }}
    >
      <AlertDialogTrigger asChild>
        <Button
          variant="ghost"
          size="sm"
          className="text-danger-text hover:bg-status-cancelled-bg"
          aria-label={t('staffRequests.decline.actionNamed', named)}
        >
          {t('staffRequests.decline.action')}
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
            decline.mutate(
              { request, reason: trimmed },
              {
                onSuccess: () => {
                  setOpen(false)
                },
                onError: (error) => {
                  // Withdrawn or handled in the meantime: there is nothing left to decline.
                  if (error instanceof ApiError && error.status === 409) {
                    toast.error(errorMessage(t, error))
                    setOpen(false)
                  }
                },
              },
            )
          }}
        >
          <AlertDialogHeader>
            <AlertDialogTitle>{t('staffRequests.decline.title', named)}</AlertDialogTitle>
            <AlertDialogDescription>{t('staffRequests.decline.description')}</AlertDialogDescription>
          </AlertDialogHeader>
          {decline.isError && (
            <Alert variant="destructive">
              <CircleAlert aria-hidden />
              <AlertTitle>{errorMessage(t, decline.error)}</AlertTitle>
            </Alert>
          )}
          <div className="flex flex-col gap-2">
            <Label htmlFor={id}>{t('staffRequests.decline.reason')}</Label>
            <Textarea
              id={id}
              maxLength={MAX_REASON}
              value={reason}
              aria-invalid={missing}
              aria-describedby={missing ? `${id}-error` : `${id}-hint`}
              placeholder={t('staffRequests.decline.reasonPlaceholder')}
              onChange={(event) => {
                setReason(event.target.value)
                setMissing(false)
              }}
            />
            {missing ? (
              <p id={`${id}-error`} className="type-body-sm text-danger-text">
                {t('staffRequests.decline.reasonRequired')}
              </p>
            ) : (
              <p id={`${id}-hint`} className="type-body-sm text-ink-secondary">
                {t('staffRequests.decline.reasonHint')}
              </p>
            )}
          </div>
          <AlertDialogFooter>
            <AlertDialogCancel asChild>
              <Button type="button" variant="outline" disabled={decline.isPending}>
                {t('staffRequests.decline.keep')}
              </Button>
            </AlertDialogCancel>
            <Button type="submit" variant="destructive" disabled={decline.isPending}>
              {decline.isPending && <LoaderCircle aria-hidden className="animate-spin" />}
              {t('staffRequests.decline.confirm')}
            </Button>
          </AlertDialogFooter>
        </form>
      </AlertDialogContent>
    </AlertDialog>
  )
}
