import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftboard_api/shiftboard_api.dart';

import '../../../core/api/api_provider.dart';
import '../../../core/api/live_connection.dart';
import '../../../core/api/server_sent_events.dart';
import '../../../core/platform/app_lifecycle.dart';
import '../../auth/data/session.dart';
import 'messages_provider.dart';

/// Opens the worker's stream of conversation notices
/// (`GET /worker/conversation/events`, ADR 0031).
///
/// The generated `streamMyConversationEvents` reads the whole body as one
/// string, which never ends for a stream, so only this transport is written
/// by hand. It goes through the app's Dio, so the auth interceptor adds the
/// token and renews it on a 401 as for every other call. The notices are
/// read with the generated serializers.
///
/// The server sends `:connected` at once and a heartbeat every 25 seconds.
/// When no bytes at all arrive for [silenceLimit], the connection is taken as
/// dead (for example after the phone switched networks): Dio's receive
/// timeout, which it applies between chunks of a streamed body, closes the
/// response and fails the stream, and the caller reconnects.
class ConversationEventSource {
  ConversationEventSource(
    this._api, {
    this.silenceLimit = const Duration(seconds: 60),
  });

  static const path = '/worker/conversation/events';

  /// The name of the events that carry a `ConversationEvent`.
  static const eventName = 'conversation';

  final ShiftboardApi _api;
  final Duration silenceLimit;

  Future<Stream<ConversationEvent>> open(CancelToken cancelToken) async {
    final response = await _api.dio.get<ResponseBody>(
      path,
      cancelToken: cancelToken,
      options: Options(
        responseType: ResponseType.stream,
        headers: {HttpHeaders.acceptHeader: 'text/event-stream'},
        // The watchdog: the longest wait for the next bytes, comments
        // included.
        receiveTimeout: silenceLimit,
        // As the generated client marks it, so that the token goes along.
        extra: {
          'secure': [
            {'type': 'http', 'scheme': 'bearer', 'name': 'bearerAuth'},
          ],
        },
      ),
    );
    return utf8.decoder
        .bind(response.data!.stream)
        .transform(const LineSplitter())
        .transform(const ServerSentEventDecoder())
        .where((event) => event.event == eventName)
        .expand((event) => [?_decode(event.data)]);
  }

  ConversationEvent? _decode(String data) {
    try {
      return _api.serializers.deserializeWith(
        ConversationEvent.serializer,
        jsonDecode(data),
      );
    } catch (_) {
      // Not a notice this app can read; the next one or a pull will do.
      return null;
    }
  }
}

final conversationEventSourceProvider = Provider<ConversationEventSource>(
  (ref) => ConversationEventSource(ref.watch(apiProvider)),
);

/// Whether the live chat should be open: the app is in the foreground and an
/// active worker is signed in.
final _liveChatWantedProvider = Provider<bool>((ref) {
  final activeWorker = ref.watch(
    currentUserProvider.select(
      (user) => user?.worker?.status == WorkerStatus.ACTIVE,
    ),
  );
  return activeWorker && ref.watch(appInForegroundProvider);
});

/// Remembers across foreground changes whether this session had the stream
/// open before, so that a return to the app loads what came in meanwhile.
class _LiveChatHistory {
  bool connectedBefore = false;
}

final _liveChatHistoryProvider = Provider<_LiveChatHistory>(
  (ref) => _LiveChatHistory(),
);

/// Holds the stream of conversation notices open while it is wanted and
/// reloads the chat and its unread count on each notice (ADR 0031).
///
/// Reconnects with a backoff when the stream drops; a 401 is renewed by the
/// auth interceptor before it gets here. Stops on a 403: the worker may no
/// longer chat, and pull to refresh and push still work.
final liveChatProvider = Provider<void>((ref) {
  final history = ref.read(_liveChatHistoryProvider);
  final signedOut = ref.watch(
    currentUserProvider.select((user) => user == null),
  );
  if (signedOut) history.connectedBefore = false;
  if (!ref.watch(_liveChatWantedProvider)) return;

  final source = ref.watch(conversationEventSourceProvider);
  final connection = LiveConnection<ConversationEvent>(
    open: source.open,
    onConnected: (_) {
      // Missed while the app was away or the stream was down.
      if (history.connectedBefore) _reload(ref, ConversationChange.MESSAGE);
      history.connectedBefore = true;
    },
    onEvent: (event) => _reload(ref, event.change),
    isFatal: (error) =>
        error is DioException &&
        error.response?.statusCode == HttpStatus.forbidden,
  )..start();
  ref.onDispose(connection.close);
});

void _reload(Ref ref, ConversationChange change) {
  // READ only changes the count. The chat shows no read state, and reloading
  // it would mark messages as read again.
  if (change != ConversationChange.READ) ref.invalidate(myMessagesProvider);
  ref.invalidate(unreadMessagesProvider);
}
