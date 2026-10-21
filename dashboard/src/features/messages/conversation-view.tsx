import { useQueryClient } from '@tanstack/react-query'
import { CircleAlert, LoaderCircle, Megaphone, Send, TriangleAlert } from 'lucide-react'
import { useEffect, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Link } from 'react-router'

import { errorMessage } from '@/api/errors'
import { type ConversationPage, type Message, MessageType } from '@/api/generated'
import { Alert, AlertTitle } from '@/components/ui/alert'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Label } from '@/components/ui/label'
import { Skeleton } from '@/components/ui/skeleton'
import { Textarea } from '@/components/ui/textarea'
import { cn } from '@/lib/utils'

import { messageText } from './message-text'
import { useConversation, useReply } from './queries'

const MAX_BODY = 2000

/** The worker's name, from whichever inbox page lists the conversation. */
function useWorkerName(conversationId: string) {
  const queryClient = useQueryClient()
  const pages = queryClient.getQueriesData<ConversationPage>({ queryKey: ['messages', 'inbox'] })
  for (const [, page] of pages) {
    const found = page?.content.find((it) => it.id === conversationId)
    if (found) {
      return `${found.worker.firstName} ${found.worker.lastName}`
    }
  }
  return undefined
}

export function ConversationView({ conversationId }: { conversationId: string }) {
  const { t } = useTranslation()
  const conversation = useConversation(conversationId)
  const name = useWorkerName(conversationId)
  const end = useRef<HTMLDivElement>(null)
  const latest = conversation.data?.content.at(-1)?.id

  // Show the newest message when the conversation opens and when one arrives.
  useEffect(() => {
    end.current?.scrollIntoView({ block: 'end' })
  }, [latest])

  return (
    <Card className="gap-0 p-0">
      <div className="border-b px-6 py-4">
        <h2 className="type-heading-sm">{name ?? t('messages.conversation')}</h2>
      </div>
      <div className="max-h-[32rem] min-h-[20rem] overflow-y-auto px-6 py-4">
        {conversation.isPending ? (
          <div role="status" aria-label={t('messages.loadingConversation')} className="space-y-3">
            <Skeleton className="h-12 w-2/3 rounded-lg" />
            <Skeleton className="ml-auto h-12 w-1/2 rounded-lg" />
          </div>
        ) : conversation.isError ? (
          <div className="flex items-center gap-3">
            <TriangleAlert aria-hidden className="size-5 text-danger-text" />
            <p>{t('messages.conversationError')}</p>
            <Button
              variant="outline"
              size="sm"
              onClick={() => {
                void conversation.refetch()
              }}
            >
              {t('messages.error.retry')}
            </Button>
          </div>
        ) : (
          <ol aria-label={t('messages.thread')} className="space-y-3">
            {conversation.data.content.map((message) => (
              <li key={message.id}>
                <MessageBubble message={message} />
              </li>
            ))}
          </ol>
        )}
        <div ref={end} />
      </div>
      <ReplyForm conversationId={conversationId} />
    </Card>
  )
}

function ShiftTag({ message }: { message: Message }) {
  const { i18n } = useTranslation()
  if (!message.shift) {
    return null
  }
  const day = new Intl.DateTimeFormat(i18n.language, {
    weekday: 'short',
    day: '2-digit',
    month: '2-digit',
  }).format(message.shift.startsAt)

  return (
    <Link
      to={`/shifts/${message.shift.id}`}
      className="type-caption inline-flex rounded-full border bg-canvas px-3 py-1 text-ink hover:bg-surface-soft"
    >
      {message.shift.title} · {day}
    </Link>
  )
}

function MessageBubble({ message }: { message: Message }) {
  const { t, i18n } = useTranslation()
  const time = new Intl.DateTimeFormat(i18n.language, {
    dateStyle: 'short',
    timeStyle: 'short',
  }).format(message.createdAt)

  if (message.type === MessageType.SYSTEM) {
    return (
      <div className="flex flex-col items-center gap-1 text-center">
        <p className="type-body-sm rounded-full bg-surface-soft px-4 py-1.5 text-ink-secondary">
          {messageText(t, message)}
        </p>
        <div className="flex items-center gap-2">
          <ShiftTag message={message} />
          <span className="type-caption text-ink-tertiary tabular-nums">{time}</span>
        </div>
      </div>
    )
  }

  const own = !message.fromWorker
  const broadcast = message.type === MessageType.BROADCAST

  return (
    <div className={cn('flex flex-col gap-1', own ? 'items-end' : 'items-start')}>
      <div
        className={cn(
          'max-w-[80%] rounded-lg px-4 py-2.5 whitespace-pre-line',
          own ? 'bg-action text-on-action' : 'bg-surface-soft text-ink',
        )}
      >
        {broadcast && (
          <span className="type-caption mb-1 flex items-center gap-1.5 opacity-80">
            <Megaphone aria-hidden className="size-3.5" />
            {t('messages.broadcast')}
          </span>
        )}
        {message.body}
      </div>
      <div className="flex items-center gap-2">
        <ShiftTag message={message} />
        <span className="type-caption text-ink-tertiary tabular-nums">
          {own && message.senderName ? t('messages.sentBy', { name: message.senderName, time }) : time}
        </span>
      </div>
    </div>
  )
}

function ReplyForm({ conversationId }: { conversationId: string }) {
  const { t } = useTranslation()
  const reply = useReply(conversationId)
  const [body, setBody] = useState('')
  const id = `reply-${conversationId}`

  return (
    <form
      className="flex flex-col gap-3 border-t px-6 py-4"
      onSubmit={(event) => {
        event.preventDefault()
        const text = body.trim()
        if (!text) {
          return
        }
        reply.mutate(text, {
          onSuccess: () => {
            setBody('')
          },
        })
      }}
    >
      {reply.isError && (
        <Alert variant="destructive">
          <CircleAlert aria-hidden />
          <AlertTitle>{errorMessage(t, reply.error)}</AlertTitle>
        </Alert>
      )}
      <Label htmlFor={id} className="sr-only">
        {t('messages.reply')}
      </Label>
      <Textarea
        id={id}
        className="min-h-20"
        maxLength={MAX_BODY}
        placeholder={t('messages.replyPlaceholder')}
        value={body}
        onChange={(event) => {
          setBody(event.target.value)
        }}
      />
      <div className="flex justify-end">
        <Button type="submit" size="sm" disabled={reply.isPending || !body.trim()}>
          {reply.isPending ? (
            <LoaderCircle aria-hidden className="animate-spin" />
          ) : (
            <Send aria-hidden />
          )}
          {t('messages.send')}
        </Button>
      </div>
    </form>
  )
}
