import { apiBasePath, messagesApi, renewAccessToken } from '@/api/client'
import { readEventStream } from '@/api/event-stream'
import { type ConversationEvent, ConversationEventFromJSON } from '@/api/generated'

/** The first reconnect waits this long, each further failure twice as long, up to the cap. */
export const RECONNECT_BASE_MS = 1_000
export const RECONNECT_MAX_MS = 30_000

/** The server pings every 25 seconds; a connection without any bytes for this long is dead. */
export const SILENCE_TIMEOUT_MS = 60_000

export interface InboxEventHandlers {
  /** The stream is open: notices arrive from now on. */
  onOpen: () => void
  /** The stream is closed; it reconnects unless it gave up. */
  onClose: () => void
  onNotice: (notice: ConversationEvent) => void
}

type Outcome = 'ended' | 'failed' | 'unauthorized' | 'forbidden'

/**
 * Follows the staff event stream of the agency's conversations (ADR 0031)
 * until the signal aborts. Reconnects with exponential backoff when the
 * stream fails or ends. After a 401 it refreshes the tokens like every other
 * request and reconnects right away; it gives up on a 403 and when the
 * session cannot be continued.
 */
export async function followInboxEvents(handlers: InboxEventHandlers, signal: AbortSignal) {
  let failures = 0
  let renewed = false
  const aborted = () => signal.aborted
  while (!aborted()) {
    const { outcome, opened, authorization } = await connect(handlers, signal)
    if (aborted()) {
      return
    }
    if (opened) {
      handlers.onClose()
      failures = 0
    }
    if (outcome === 'forbidden') {
      return
    }
    // A second 401 right after renewing waits like any failure before it renews again.
    if (outcome === 'unauthorized' && !renewed) {
      if (!(await renewAccessToken(authorization))) {
        return
      }
      renewed = true
      continue
    }
    renewed = false
    const delay = Math.min(RECONNECT_BASE_MS * 2 ** failures, RECONNECT_MAX_MS)
    failures++
    await sleep(delay, signal)
  }
}

/**
 * One connection. A watchdog aborts it when no bytes arrive for the silence
 * timeout, as a connection that died without closing never ends on its own;
 * that counts as a failure.
 */
async function connect(handlers: InboxEventHandlers, signal: AbortSignal) {
  const connection = new AbortController()
  const abort = () => {
    connection.abort()
  }
  signal.addEventListener('abort', abort, { once: true })
  let watchdog: ReturnType<typeof setTimeout> | undefined
  const watch = () => {
    clearTimeout(watchdog)
    watchdog = setTimeout(abort, SILENCE_TIMEOUT_MS)
  }

  watch()
  try {
    const result = await openAndRead(handlers, connection.signal, watch)
    // Aborted while the caller still listens: the watchdog gave up on it.
    const silent = connection.signal.aborted && !signal.aborted
    return silent ? { ...result, outcome: 'failed' as const } : result
  } finally {
    clearTimeout(watchdog)
    signal.removeEventListener('abort', abort)
  }
}

async function openAndRead(handlers: InboxEventHandlers, signal: AbortSignal, onBytes: () => void) {
  const { path, headers } = await messagesApi.streamInboxEventsRequestOpts()
  const authorization = headers['Authorization'] ?? null
  const result = (outcome: Outcome, opened = false) => ({ outcome, opened, authorization })

  let response: Response
  try {
    response = await fetch(`${apiBasePath}${path}`, {
      headers: { ...headers, Accept: 'text/event-stream' },
      cache: 'no-store',
      signal,
    })
  } catch {
    return result('failed')
  }
  if (response.status === 401) {
    return result('unauthorized')
  }
  if (response.status === 403) {
    return result('forbidden')
  }
  if (!response.ok || !response.body) {
    return result('failed')
  }

  handlers.onOpen()
  try {
    await readEventStream(
      response.body,
      ({ event, data }) => {
        const notice = event === 'conversation' ? parseNotice(data) : undefined
        if (notice) {
          handlers.onNotice(notice)
        }
      },
      signal,
      onBytes,
    )
    return result('ended', true)
  } catch {
    return result('failed', true)
  }
}

/** The notice in an event's data, or undefined when it is not one. */
function parseNotice(data: string): ConversationEvent | undefined {
  try {
    const notice = ConversationEventFromJSON(JSON.parse(data))
    return typeof notice.conversationId === 'string' ? notice : undefined
  } catch {
    return undefined
  }
}

function sleep(ms: number, signal: AbortSignal) {
  return new Promise<void>((resolve) => {
    const done = () => {
      clearTimeout(timer)
      signal.removeEventListener('abort', done)
      resolve()
    }
    const timer = setTimeout(done, ms)
    signal.addEventListener('abort', done, { once: true })
  })
}
