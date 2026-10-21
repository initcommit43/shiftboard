import { Inbox, MessageSquare, TriangleAlert } from 'lucide-react'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { NavLink, useParams } from 'react-router'

import type { Conversation } from '@/api/generated'
import { PageHeader } from '@/components/page-header'
import { Pagination } from '@/components/pagination'
import { StateCard } from '@/components/state-card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Skeleton } from '@/components/ui/skeleton'
import { initials } from '@/lib/initials'
import { cn } from '@/lib/utils'

import { ConversationView } from './conversation-view'
import { messagePreview } from './message-text'
import { useInbox } from './queries'

/** The shared inbox: every worker conversation, the most recent first, and the open one beside it. */
export function MessagesPage() {
  const { t } = useTranslation()
  const { conversationId } = useParams()

  return (
    <div className="space-y-8">
      <PageHeader title={t('messages.title')} description={t('messages.description')} />
      <div className="grid gap-6 lg:grid-cols-[22rem_1fr]">
        <ConversationList selected={conversationId} />
        {conversationId ? (
          <ConversationView key={conversationId} conversationId={conversationId} />
        ) : (
          <StateCard
            icon={<MessageSquare />}
            title={t('messages.choose.title')}
            description={t('messages.choose.description')}
          />
        )}
      </div>
    </div>
  )
}

function ConversationList({ selected }: { selected: string | undefined }) {
  const { t } = useTranslation()
  const [page, setPage] = useState(0)
  const inbox = useInbox(page)

  if (inbox.isPending) {
    return (
      <div role="status" aria-label={t('messages.loading')} className="space-y-2">
        {Array.from({ length: 4 }, (_, index) => (
          <Skeleton key={index} className="h-18 rounded-lg" />
        ))}
      </div>
    )
  }

  if (inbox.isError) {
    return (
      <StateCard
        icon={<TriangleAlert className="text-danger-text" />}
        title={t('messages.error.title')}
        description={t('messages.error.description')}
        action={
          <Button
            variant="outline"
            disabled={inbox.isFetching}
            onClick={() => {
              void inbox.refetch()
            }}
          >
            {t('messages.error.retry')}
          </Button>
        }
      />
    )
  }

  const { content, totalPages } = inbox.data
  if (content.length === 0) {
    return (
      <StateCard
        icon={<Inbox />}
        title={t('messages.empty.title')}
        description={t('messages.empty.description')}
      />
    )
  }

  return (
    <nav aria-label={t('messages.conversations')} className="space-y-4">
      <ul className="space-y-2">
        {content.map((conversation) => (
          <li key={conversation.id}>
            <ConversationLink conversation={conversation} selected={conversation.id === selected} />
          </li>
        ))}
      </ul>
      {totalPages > 1 && (
        <Pagination
          page={page}
          totalPages={totalPages}
          disabled={inbox.isPlaceholderData}
          onPageChange={setPage}
        />
      )}
    </nav>
  )
}

function ConversationLink({
  conversation,
  selected,
}: {
  conversation: Conversation
  selected: boolean
}) {
  const { t, i18n } = useTranslation()
  const name = `${conversation.worker.firstName} ${conversation.worker.lastName}`
  const when = new Intl.DateTimeFormat(i18n.language, {
    dateStyle: 'short',
    timeStyle: 'short',
  }).format(conversation.lastMessage.createdAt)

  return (
    <NavLink
      to={`/messages/${conversation.id}`}
      aria-current={selected ? 'page' : undefined}
      className={cn(
        'flex items-start gap-3 rounded-lg border bg-surface-card px-4 py-3 transition-colors hover:bg-surface-soft',
        selected && 'border-hairline-strong bg-surface-soft',
      )}
    >
      <span
        aria-hidden
        className="type-caption grid size-9 shrink-0 place-items-center rounded-full border bg-surface-soft font-semibold"
      >
        {initials(name)}
      </span>
      <span className="min-w-0 flex-1">
        <span className="flex items-baseline justify-between gap-2">
          <span className="truncate font-semibold">{name}</span>
          <span className="type-caption shrink-0 text-ink-secondary tabular-nums">{when}</span>
        </span>
        <span className="type-body-sm block truncate text-ink-secondary">
          {messagePreview(t, conversation.lastMessage)}
        </span>
      </span>
      {conversation.unreadCount > 0 && (
        <Badge variant="feature">
          <span aria-hidden>{conversation.unreadCount}</span>
          <span className="sr-only">
            {t('messages.unread', { count: conversation.unreadCount })}
          </span>
        </Badge>
      )}
    </NavLink>
  )
}
