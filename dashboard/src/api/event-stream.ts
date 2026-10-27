/** One server-sent event: its name and its data lines joined by newlines. */
export interface ServerSentEvent {
  event: string
  data: string
}

/**
 * Parses the `text/event-stream` format as browsers do for `EventSource`
 * (HTML standard, "Server-sent events"): one field per line, a blank line ends
 * an event, lines starting with a colon are comments such as `: ping`. Takes
 * the text in chunks of any size; an event that is not complete yet waits for
 * the next chunk.
 */
export function createEventStreamParser(onEvent: (event: ServerSentEvent) => void) {
  let buffer = ''
  let started = false
  let eventName = ''
  let data: string[] = []

  function processLine(line: string) {
    if (line === '') {
      // An event without data lines is not dispatched.
      if (data.length > 0) {
        onEvent({ event: eventName || 'message', data: data.join('\n') })
      }
      eventName = ''
      data = []
      return
    }
    if (line.startsWith(':')) {
      return
    }
    const colon = line.indexOf(':')
    const field = colon === -1 ? line : line.slice(0, colon)
    let value = colon === -1 ? '' : line.slice(colon + 1)
    if (value.startsWith(' ')) {
      value = value.slice(1)
    }
    if (field === 'event') {
      eventName = value
    } else if (field === 'data') {
      data.push(value)
    }
    // `id` and `retry` are not used: notices are not replayed, and reconnecting has its own backoff.
  }

  return (chunk: string) => {
    buffer += chunk
    if (!started && buffer !== '') {
      started = true
      if (buffer.startsWith('﻿')) {
        buffer = buffer.slice(1)
      }
    }
    let start = 0
    for (let index = 0; index < buffer.length; index++) {
      const char = buffer[index]
      if (char !== '\n' && char !== '\r') {
        continue
      }
      // A carriage return at the end of the chunk may be the first half of CRLF.
      if (char === '\r' && index === buffer.length - 1) {
        break
      }
      processLine(buffer.slice(start, index))
      if (char === '\r' && buffer[index + 1] === '\n') {
        index++
      }
      start = index + 1
    }
    buffer = buffer.slice(start)
  }
}

/**
 * Reads an event stream body until the server ends it or the signal aborts.
 * Rejects when the connection fails.
 */
export async function readEventStream(
  body: ReadableStream<Uint8Array>,
  onEvent: (event: ServerSentEvent) => void,
  signal: AbortSignal,
): Promise<void> {
  const reader = body.getReader()
  const decoder = new TextDecoder()
  const parse = createEventStreamParser(onEvent)
  const cancel = () => {
    reader.cancel().catch(() => undefined)
  }
  signal.addEventListener('abort', cancel, { once: true })
  try {
    for (;;) {
      const { done, value } = await reader.read()
      if (done || signal.aborted) {
        return
      }
      parse(decoder.decode(value, { stream: true }))
    }
  } finally {
    signal.removeEventListener('abort', cancel)
  }
}
