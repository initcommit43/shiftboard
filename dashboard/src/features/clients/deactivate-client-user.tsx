import { LoaderCircle } from 'lucide-react'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'

import type { ClientUser } from '@/api/generated'
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

import { fullName, useDeactivateClientUser } from './queries'

/** Ends a client user's access, after a confirmation. */
export function DeactivateClientUser({ clientId, user }: { clientId: string; user: ClientUser }) {
  const { t } = useTranslation()
  const deactivate = useDeactivateClientUser(clientId)
  const [open, setOpen] = useState(false)
  const name = fullName(user)

  return (
    <AlertDialog
      open={open}
      onOpenChange={(next) => {
        if (!deactivate.isPending) {
          setOpen(next)
        }
      }}
    >
      <AlertDialogTrigger asChild>
        <Button
          variant="ghost"
          size="sm"
          className="text-danger-text hover:bg-status-cancelled-bg"
          aria-label={t('clients.users.deactivate.actionNamed', { name })}
        >
          {t('clients.users.deactivate.action')}
        </Button>
      </AlertDialogTrigger>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>{t('clients.users.deactivate.title', { name })}</AlertDialogTitle>
          <AlertDialogDescription>
            {t('clients.users.deactivate.description', { name })}
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel asChild>
            <Button variant="outline" disabled={deactivate.isPending}>
              {t('clients.users.deactivate.keep')}
            </Button>
          </AlertDialogCancel>
          <Button
            variant="destructive"
            disabled={deactivate.isPending}
            onClick={() => {
              deactivate.mutate(user, {
                onSettled: () => {
                  setOpen(false)
                },
              })
            }}
          >
            {deactivate.isPending && <LoaderCircle aria-hidden className="animate-spin" />}
            {t('clients.users.deactivate.confirm')}
          </Button>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  )
}
