import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftboard/core/api/live_connection.dart';

/// A server whose connections the test opens, fails and ends by hand.
class FakeServer {
  final attempts = <Completer<Stream<String>>>[];
  final streams = <StreamController<String>>[];
  final cancelTokens = <CancelToken>[];

  Future<Stream<String>> open(CancelToken cancelToken) {
    cancelTokens.add(cancelToken);
    final attempt = Completer<Stream<String>>();
    attempts.add(attempt);
    return attempt.future;
  }

  /// Accepts the latest attempt and returns its stream.
  StreamController<String> accept() {
    final controller = StreamController<String>();
    streams.add(controller);
    attempts.last.complete(controller.stream);
    return controller;
  }

  void reject(Object error) => attempts.last.completeError(error);
}

/// Waits the test controls: records each delay and goes on when released.
class FakeWaits {
  final delays = <Duration>[];
  Completer<void>? _pending;

  Future<void> call(Duration delay) {
    delays.add(delay);
    return (_pending = Completer<void>()).future;
  }

  void release() => _pending!.complete();
}

DioException status(int code) => DioException.badResponse(
  statusCode: code,
  requestOptions: RequestOptions(path: '/events'),
  response: Response(
    requestOptions: RequestOptions(path: '/events'),
    statusCode: code,
  ),
);

/// Lets the connection's futures run.
Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  group('Backoff', () {
    test('doubles from one second up to thirty', () {
      final backoff = Backoff();

      expect(
        [for (var i = 0; i < 7; i++) backoff.next().inSeconds],
        [1, 2, 4, 8, 16, 30, 30],
      );
    });

    test('starts over after a reset', () {
      final backoff = Backoff()
        ..next()
        ..next()
        ..reset();

      expect(backoff.next(), const Duration(seconds: 1));
    });
  });

  group('LiveConnection', () {
    late FakeServer server;
    late FakeWaits waits;
    late List<String> events;
    late List<int> connected;
    late LiveConnection<String> connection;

    setUp(() {
      server = FakeServer();
      waits = FakeWaits();
      events = [];
      connected = [];
      connection = LiveConnection<String>(
        open: server.open,
        onEvent: events.add,
        onConnected: connected.add,
        isFatal: (error) =>
            error is DioException && error.response?.statusCode == 403,
        wait: waits.call,
      );
    });

    tearDown(() => connection.close());

    test('passes on the events of an open stream', () async {
      connection.start();
      final stream = server.accept();
      stream
        ..add('a')
        ..add('b');
      await settle();

      expect(events, ['a', 'b']);
      expect(connected, [1]);
    });

    test('reconnects with growing waits while the server fails', () async {
      connection.start();
      server.reject(
        DioException.connectionError(
          requestOptions: RequestOptions(path: '/events'),
          reason: 'offline',
        ),
      );
      await settle();
      waits.release();
      await settle();
      server.reject(status(503));
      await settle();
      waits.release();
      await settle();
      server.reject(status(401));
      await settle();

      expect(server.attempts, hasLength(3));
      expect(waits.delays, [
        const Duration(seconds: 1),
        const Duration(seconds: 2),
        const Duration(seconds: 4),
      ]);
      expect(connected, isEmpty);
    });

    test('reconnects after a dropped stream, waiting less again', () async {
      connection.start();
      server.reject(status(503));
      await settle();
      waits.release();
      await settle();
      final stream = server.accept();
      await settle();
      await stream.close();
      await settle();

      expect(waits.delays, [
        const Duration(seconds: 1),
        const Duration(seconds: 1),
      ]);
      waits.release();
      await settle();
      server.accept().add('after');
      await settle();

      expect(connected, [1, 2]);
      expect(events, ['after']);
    });

    test('reconnects after the stream fails', () async {
      connection.start();
      server.accept().addError(status(500));
      await settle();
      waits.release();
      await settle();

      expect(server.attempts, hasLength(2));
    });

    test('stops for good on a fatal error', () async {
      connection.start();
      server.reject(status(403));
      await connection.done;

      expect(connection.isClosed, isTrue);
      expect(waits.delays, isEmpty);
      expect(server.attempts, hasLength(1));
    });

    test('close ends the stream and cancels the request', () async {
      connection.start();
      final stream = server.accept();
      await settle();

      await connection.close();
      await connection.done;

      expect(stream.hasListener, isFalse);
      expect(server.cancelTokens.single.isCancelled, isTrue);
    });

    test('close during a wait stops reconnecting', () async {
      connection.start();
      server.reject(status(503));
      await settle();

      await connection.close();
      await connection.done;
      waits.release();
      await settle();

      expect(server.attempts, hasLength(1));
    });
  });
}
