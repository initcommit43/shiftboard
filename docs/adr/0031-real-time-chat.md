# 0031: Chat updates reach open apps through server-sent events

Status: accepted (2026-10-27)

## Context

Slice 3 started messaging the simple way: the dashboard asks for new messages every 15 seconds, and the worker app reloads on pull to refresh or when a push arrives. Messages show up late, and a dispatcher may answer a worker another dispatcher already answered. Slice 7 makes the chat live. Open questions were the transport, what an update carries, how the stream is authenticated, and what happens with several server instances.

## Decision

- **Server-sent events, not WebSockets.** Updates only flow from the server to the apps; sending a message stays a normal `POST`. SSE runs over plain HTTP, fits Spring MVC (`SseEmitter`) and needs no extra protocol.
- **An update is a notice, not the data.** The stream says that a conversation changed (a new message, or messages were read). The apps then reload through the existing REST endpoints. The notice's schema is in the OpenAPI spec, so the apps parse it with the generated model; only the transport is written by hand.
- **Live are new messages, unread counts and read state.** No typing indicators.
- **Workers get notices for their own conversation, staff for every conversation of their agency.** The stream is scoped like the REST endpoints, by tenant and role.
- **The access token goes in the `Authorization` header** of a fetch-based stream. The browser's built-in `EventSource` can't send headers, and tokens in URLs end up in logs. When the token expires, the app refreshes it and reconnects.
- **One server instance for now.** Open streams are held in memory. Once there is more than one instance, notices go through PostgreSQL `LISTEN/NOTIFY`; hosting is still open (backlog #12).
- **Nothing gets worse when the stream drops.** The dashboard falls back to polling while it reconnects; a closed app still gets a push.
- **No feature flag.** It improves the chat module, which already has its own flag.

## Consequences

- Messages show up within a second while a chat or the inbox is open.
- Each open dashboard tab and foreground app holds one connection; proxies on the future host must allow long-lived responses without buffering.
- A notice costs one extra REST call, which keeps a single source for message data.
- Scaling out needs the `LISTEN/NOTIFY` step before the second instance goes live.
