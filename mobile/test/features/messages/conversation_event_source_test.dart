import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftboard/core/api/live_connection.dart';
import 'package:shiftboard/features/messages/data/live_chat.dart';
import 'package:shiftboard_api/shiftboard_api.dart';

import '../../support/fake_backend.dart';

const eventsRoute = 'GET /worker/conversation/events';

String notice(String change) =>
    'event: conversation\n'
    'data: {"conversationId":"0199c0de-0000-7000-8000-000000000301",'
    '"change":"$change"}\n\n';

void main() {
  late FakeBackend backend;
  late ConversationEventSource source;

  setUp(() {
    backend = FakeBackend();
    final api = ShiftboardApi(
      basePathOverride: 'http://api.test',
      interceptors: [],
    )..dio.httpClientAdapter = backend;
    source = ConversationEventSource(api);
  });

  test('reads conversation notices and skips the rest', () async {
    final stream = await source.open(CancelToken());
    final received = stream.toList();

    backend
      ..sendEvent(': connected\n\n')
      ..sendEvent(notice('MESSAGE'))
      ..sendEvent('event: other\ndata: {}\n\n')
      ..sendEvent('event: conversation\ndata: not json\n\n')
      ..sendEvent(notice('READ'))
      ..sendEvent(notice('REACTION'))
      ..dropEventStreams();

    expect((await received).map((event) => event.change), [
      ConversationChange.MESSAGE,
      ConversationChange.READ,
      ConversationChange.unknownDefaultOpenApi,
    ]);
  });

  test('fails after a minute without anything, heartbeats included', () {
    fakeAsync((async) {
      Object? failure;
      final events = <ConversationEvent>[];
      source
          .open(CancelToken())
          .then(
            (stream) => stream.listen(
              events.add,
              onError: (Object error) {
                failure = error;
              },
            ),
          );
      async.elapse(Duration.zero);
      expect(backend.openEventStreams, 1);

      async.elapse(const Duration(seconds: 59));
      backend.sendEvent(': ping\n\n');
      async.elapse(const Duration(seconds: 59));
      backend.sendEvent(notice('MESSAGE'));
      async.elapse(const Duration(seconds: 59));
      expect(failure, isNull);
      expect(events, hasLength(1));

      async.elapse(const Duration(seconds: 1));
      expect(
        failure,
        isA<DioException>().having(
          (error) => error.type,
          'type',
          DioExceptionType.receiveTimeout,
        ),
      );
    });
  });

  test('a silent connection is dropped and opened again', () {
    fakeAsync((async) {
      final connection = LiveConnection<ConversationEvent>(
        open: source.open,
        onEvent: (_) {},
      )..start();
      async.elapse(Duration.zero);
      expect(backend.sent(eventsRoute), hasLength(1));

      async.elapse(const Duration(seconds: 60));
      expect(backend.openEventStreams, 0);

      async.elapse(const Duration(seconds: 1));
      expect(backend.sent(eventsRoute), hasLength(2));
      expect(backend.openEventStreams, 1);

      connection.close();
      async.elapse(Duration.zero);
      expect(backend.openEventStreams, 0);
    });
  });
}
