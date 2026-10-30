import { describe, expect, it } from 'vitest'

import { createEventStreamParser, readEventStream, type ServerSentEvent } from './event-stream'

function parse(...chunks: string[]) {
  const events: ServerSentEvent[] = []
  const feed = createEventStreamParser((event) => events.push(event))
  chunks.forEach(feed)
  return events
}

describe('event stream parser', () => {
  it('reads named events and ends each at a blank line', () => {
    expect(parse('event: conversation\ndata: {"a":1}\n\nevent: conversation\ndata: {"a":2}\n\n')).toEqual([
      { event: 'conversation', data: '{"a":1}' },
      { event: 'conversation', data: '{"a":2}' },
    ])
  })

  it('joins data lines with newlines', () => {
    expect(parse('data: first\ndata: second\ndata:\n\n')).toEqual([
      { event: 'message', data: 'first\nsecond\n' },
    ])
  })

  it('skips comments and events without data', () => {
    expect(parse(': ping\n\nevent: conversation\n\n: ping\ndata: x\n\n')).toEqual([
      { event: 'message', data: 'x' },
    ])
  })

  it('strips one space after the colon and takes a line without colon as a field', () => {
    expect(parse('event:conversation\ndata:  two spaces\n\ndata\n\n')).toEqual([
      { event: 'conversation', data: ' two spaces' },
      { event: 'message', data: '' },
    ])
  })

  it('waits for events split across chunks, also between CR and LF', () => {
    const events = parse('ev', 'ent: conversation\r', '\ndata: {"conv', 'ersationId":"c1"}\r\n', '\r\n')
    expect(events).toEqual([{ event: 'conversation', data: '{"conversationId":"c1"}' }])
  })

  it('accepts CR alone as a line end and ignores a leading byte order mark', () => {
    expect(parse('﻿data: a\r\rdata: b\n\n')).toEqual([
      { event: 'message', data: 'a' },
      { event: 'message', data: 'b' },
    ])
  })

  it('drops an event the stream ended in the middle of', () => {
    expect(parse('data: complete\n\ndata: cut off\n')).toEqual([{ event: 'message', data: 'complete' }])
  })
})

describe('reading an event stream', () => {
  it('decodes characters split across chunks until the stream ends', async () => {
    const bytes = new TextEncoder().encode('data: Grüße\n\n')
    const split = bytes.indexOf(0xc3) + 1
    const body = new ReadableStream<Uint8Array>({
      start(controller) {
        controller.enqueue(bytes.slice(0, split))
        controller.enqueue(bytes.slice(split))
        controller.close()
      },
    })
    const events: ServerSentEvent[] = []

    await readEventStream(body, (event) => events.push(event), new AbortController().signal)

    expect(events).toEqual([{ event: 'message', data: 'Grüße' }])
  })

  it('stops when the signal aborts', async () => {
    const controller = new AbortController()
    const body = new ReadableStream<Uint8Array>({
      start(stream) {
        stream.enqueue(new TextEncoder().encode(': ping\n'))
      },
    })

    const reading = readEventStream(body, () => undefined, controller.signal)
    controller.abort()

    await expect(reading).resolves.toBeUndefined()
  })
})
