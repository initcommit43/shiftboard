import { LoaderCircle, Megaphone } from 'lucide-react'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'

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
import { useBroadcast } from '@/features/messages/queries'

const MAX_BODY = 2000

/** One message to everyone confirmed for the shift, each in their own conversation. */
export function BroadcastToShift({ shiftId, confirmed }: { shiftId: string; confirmed: number }) {
  const { t } = useTranslation()
  const broadcast = useBroadcast(shiftId)
  const [open, setOpen] = useState(false)
  const [body, setBody] = useState('')

  return (
    <AlertDialog
      open={open}
      onOpenChange={(next) => {
        if (!broadcast.isPending) {
          setOpen(next)
          setBody('')
        }
      }}
    >
      <AlertDialogTrigger asChild>
        <Button variant="outline" size="sm">
          <Megaphone aria-hidden />
          {t('broadcast.action')}
        </Button>
      </AlertDialogTrigger>
      <AlertDialogContent>
        <form
          className="contents"
          onSubmit={(event) => {
            event.preventDefault()
            const text = body.trim()
            if (!text) {
              return
            }
            broadcast.mutate(text, {
              onSuccess: () => {
                setOpen(false)
              },
            })
          }}
        >
          <AlertDialogHeader>
            <AlertDialogTitle>{t('broadcast.title')}</AlertDialogTitle>
            <AlertDialogDescription>
              {t('broadcast.description', { count: confirmed })}
            </AlertDialogDescription>
          </AlertDialogHeader>
          <div className="flex flex-col gap-2">
            <Label htmlFor="broadcast-body">{t('broadcast.message')}</Label>
            <Textarea
              id="broadcast-body"
              maxLength={MAX_BODY}
              placeholder={t('broadcast.placeholder')}
              value={body}
              onChange={(event) => {
                setBody(event.target.value)
              }}
            />
          </div>
          <AlertDialogFooter>
            <AlertDialogCancel asChild>
              <Button type="button" variant="outline" disabled={broadcast.isPending}>
                {t('broadcast.cancel')}
              </Button>
            </AlertDialogCancel>
            <Button type="submit" disabled={broadcast.isPending || !body.trim()}>
              {broadcast.isPending && <LoaderCircle aria-hidden className="animate-spin" />}
              {t('broadcast.send')}
            </Button>
          </AlertDialogFooter>
        </form>
      </AlertDialogContent>
    </AlertDialog>
  )
}
