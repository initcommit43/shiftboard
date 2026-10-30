import { useQueryClient } from '@tanstack/react-query'
import { type ReactNode, useEffect, useState } from 'react'

import { known } from '@/api/enums'
import { ConversationChange } from '@/api/generated'

import { followInboxEvents } from './inbox-events'
import { InboxLiveContext, messageKeys } from './queries'

/**
 * Holds the event stream of the agency's conversations while a staff user is
 * signed in, and reloads what a notice changed (ADR 0031). Below it, the
 * message queries poll only while the stream is down.
 */
export function LiveInbox({ children }: { children: ReactNode }) {
  const queryClient = useQueryClient()
  const [live, setLive] = useState(false)

  useEffect(() => {
    const controller = new AbortController()
    let reconnecting = false

    void followInboxEvents(
      {
        onOpen: () => {
          // Notices sent while the stream was down are lost: reload once.
          if (reconnecting) {
            void queryClient.invalidateQueries({ queryKey: messageKeys.all })
          }
          setLive(true)
        },
        onClose: () => {
          reconnecting = true
          setLive(false)
        },
        onNotice: ({ conversationId, change }) => {
          void queryClient.invalidateQueries({ queryKey: messageKeys.inboxPages })
          void queryClient.invalidateQueries({ queryKey: messageKeys.unread })
          // Read state does not show in a thread. Unknown changes reload like a new message.
          if (known(ConversationChange, change) !== ConversationChange.READ) {
            void queryClient.invalidateQueries({ queryKey: messageKeys.conversation(conversationId) })
          }
        },
      },
      controller.signal,
    )

    return () => {
      controller.abort()
    }
  }, [queryClient])

  return <InboxLiveContext value={live}>{children}</InboxLiveContext>
}
