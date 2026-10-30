import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { createContext, useContext } from 'react'
import { useTranslation } from 'react-i18next'
import { toast } from 'sonner'

import { messagesApi } from '@/api/client'
import { errorMessage } from '@/api/errors'

export const PAGE_SIZE = 20

/** A conversation shows its latest messages; the API caps a page at 100. */
const MESSAGES_SIZE = 50

/** While the event stream is down, new messages still arrive without a page reload. */
export const POLL_MS = 15_000

/** True while the event stream is open (see LiveInbox); polling is off then. */
export const InboxLiveContext = createContext(false)

function usePollInterval() {
  return useContext(InboxLiveContext) ? false : POLL_MS
}

export const messageKeys = {
  all: ['messages'] as const,
  inboxPages: ['messages', 'inbox'] as const,
  inbox: (page: number) => ['messages', 'inbox', page] as const,
  unread: ['messages', 'unread'] as const,
  conversation: (conversationId: string) => ['messages', 'conversation', conversationId] as const,
}

export function useInbox(page: number) {
  const refetchInterval = usePollInterval()

  return useQuery({
    queryKey: messageKeys.inbox(page),
    queryFn: ({ signal }) => messagesApi.listConversations({ page, size: PAGE_SIZE }, { signal }),
    placeholderData: keepPreviousData,
    refetchInterval,
  })
}

/** Unread worker messages for the navigation badge. */
export function useUnreadMessageCount() {
  const refetchInterval = usePollInterval()

  return useQuery({
    queryKey: messageKeys.unread,
    queryFn: ({ signal }) => messagesApi.getInboxUnreadCount({ signal }),
    select: (data) => data.unreadCount,
    refetchInterval,
  }).data
}

/** The latest messages, oldest first, as a chat shows them. Reading them marks them as read. */
export function useConversation(conversationId: string) {
  const queryClient = useQueryClient()
  const refetchInterval = usePollInterval()

  return useQuery({
    queryKey: messageKeys.conversation(conversationId),
    queryFn: async ({ signal }) => {
      const page = await messagesApi.listConversationMessages(
        { conversationId, size: MESSAGES_SIZE },
        { signal },
      )
      // Reading changed the unread counts.
      void queryClient.invalidateQueries({ queryKey: messageKeys.unread })
      void queryClient.invalidateQueries({ queryKey: messageKeys.inboxPages })
      return { ...page, content: [...page.content].reverse() }
    },
    refetchInterval,
  })
}

export function useReply(conversationId: string) {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (body: string) =>
      messagesApi.replyToConversation({ conversationId, messageRequest: { body } }),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: messageKeys.all }),
  })
}

export function useBroadcast(shiftId: string) {
  const { t } = useTranslation()
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (body: string) =>
      messagesApi.broadcastToShift({ shiftId, broadcastRequest: { body } }),
    onSuccess: (result) => {
      toast.success(t('broadcast.sent', { count: result.recipients }))
      return queryClient.invalidateQueries({ queryKey: messageKeys.all })
    },
    onError: (error) => {
      toast.error(errorMessage(t, error))
    },
  })
}
