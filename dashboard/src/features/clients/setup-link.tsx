import { Copy } from 'lucide-react'
import { useId } from 'react'
import { useTranslation } from 'react-i18next'
import { toast } from 'sonner'

import type { ClientUserInvitation } from '@/api/generated'
import {
  AlertDialog,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { useDateTime } from '@/features/shifts/format'

import { fullName, setupLink } from './queries'

/**
 * The setup link of a fresh invitation, to copy and pass on. It is shown only
 * now: the API keeps a hash of the code, so a lost link means a new one.
 */
export function SetupLinkContent({
  invitation,
  renewed = false,
}: {
  invitation: ClientUserInvitation
  renewed?: boolean
}) {
  const { t } = useTranslation()
  const id = useId()
  const dateTime = useDateTime()
  const link = setupLink(invitation.setupCode)
  const name = fullName(invitation.user)

  return (
    <>
      <AlertDialogHeader>
        <AlertDialogTitle>{t('clients.users.link.title', { name })}</AlertDialogTitle>
        <AlertDialogDescription>
          {t(renewed ? 'clients.users.link.descriptionRenewed' : 'clients.users.link.description', {
            name,
            expiresAt: dateTime.format(invitation.expiresAt),
          })}
        </AlertDialogDescription>
      </AlertDialogHeader>
      <div className="flex flex-col gap-2">
        <Label htmlFor={id}>{t('clients.users.link.label')}</Label>
        <div className="flex gap-2">
          <Input
            id={id}
            readOnly
            value={link}
            onFocus={(event) => {
              event.target.select()
            }}
          />
          <Button
            type="button"
            variant="outline"
            className="h-14 shrink-0"
            onClick={() => {
              void copy(link).then(
                () => toast.success(t('clients.users.link.copied')),
                () => toast.error(t('clients.users.link.copyFailed')),
              )
            }}
          >
            <Copy aria-hidden />
            {t('clients.users.link.copy')}
          </Button>
        </div>
        <p className="type-body-sm text-ink-secondary">{t('clients.users.link.hint')}</p>
      </div>
      <AlertDialogFooter>
        <AlertDialogCancel asChild>
          <Button>{t('clients.users.link.done')}</Button>
        </AlertDialogCancel>
      </AlertDialogFooter>
    </>
  )
}

async function copy(text: string) {
  // The clipboard is missing outside secure contexts.
  // eslint-disable-next-line @typescript-eslint/no-unnecessary-condition
  if (!navigator.clipboard) {
    throw new Error('Clipboard unavailable')
  }
  await navigator.clipboard.writeText(text)
}

/** The new setup link of a user who hasn't set a password yet. */
export function SetupLinkDialog({
  invitation,
  onClose,
}: {
  invitation: ClientUserInvitation | null
  onClose: () => void
}) {
  return (
    <AlertDialog
      open={invitation !== null}
      onOpenChange={(open) => {
        if (!open) {
          onClose()
        }
      }}
    >
      <AlertDialogContent>
        {invitation && <SetupLinkContent invitation={invitation} renewed />}
      </AlertDialogContent>
    </AlertDialog>
  )
}
