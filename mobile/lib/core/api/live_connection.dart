import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

/// Waiting times between reconnects: doubling from [initial] up to [max].
class Backoff {
  Backoff({
    this.initial = const Duration(seconds: 1),
    this.max = const Duration(seconds: 30),
  });

  final Duration initial;
  final Duration max;

  int _attempt = 0;

  /// The time to wait before the next attempt.
  Duration next() {
    final factor = pow(2, min(_attempt, 20)).toInt();
    _attempt++;
    final delay = initial * factor;
    return delay > max ? max : delay;
  }

  /// Starts over after a connection succeeded.
  void reset() => _attempt = 0;
}

/// Opens one connection: completes once the server accepted it, with the
/// events that follow. Cancelling [cancelToken] aborts it.
typedef OpenStream<T> = Future<Stream<T>> Function(CancelToken cancelToken);

/// Keeps a long-lived stream open: connects, hands every event to [onEvent]
/// and, when the connection fails or ends, connects again after a [Backoff]
/// wait. Stops for good on [close] or an error [isFatal] accepts.
class LiveConnection<T> {
  LiveConnection({
    required this._open,
    required this._onEvent,
    this._onConnected,
    bool Function(Object error)? isFatal,
    Backoff? backoff,
    this._wait,
  }) : _isFatal = isFatal ?? _never,
       _backoff = backoff ?? Backoff();

  final OpenStream<T> _open;
  final void Function(T event) _onEvent;
  final void Function(int connection)? _onConnected;
  final bool Function(Object error) _isFatal;
  final Backoff _backoff;
  final Future<void> Function(Duration delay)? _wait;

  final _closing = Completer<void>();
  CancelToken? _cancelToken;
  StreamSubscription<T>? _subscription;
  Completer<void>? _ended;
  Timer? _timer;
  Future<void>? _done;

  bool get isClosed => _closing.isCompleted;

  /// Completes when the connection was closed or gave up.
  Future<void> get done => _done ?? Future.value();

  /// Connects. Called once.
  void start() {
    assert(_done == null, 'started twice');
    _done ??= _run();
  }

  /// Ends the connection and any pending reconnect.
  Future<void> close() async {
    if (isClosed) return;
    _closing.complete();
    _timer?.cancel();
    _cancelToken?.cancel();
    if (_ended case final ended? when !ended.isCompleted) ended.complete();
    await _subscription?.cancel();
  }

  Future<void> _run() async {
    var connections = 0;
    while (!isClosed) {
      final cancelToken = _cancelToken = CancelToken();
      try {
        final events = await _open(cancelToken);
        if (isClosed) {
          await events.listen(null).cancel();
          break;
        }
        _backoff.reset();
        _onConnected?.call(++connections);

        final ended = _ended = Completer<void>();
        _subscription = events.listen(
          _onEvent,
          onError: (Object error, StackTrace stackTrace) {
            if (!ended.isCompleted) ended.completeError(error, stackTrace);
          },
          onDone: () {
            if (!ended.isCompleted) ended.complete();
          },
          cancelOnError: true,
        );
        await ended.future;
      } catch (error) {
        if (!isClosed && _isFatal(error)) {
          await close();
        }
      }
      // Ended or failed: make sure the old request is gone.
      if (!cancelToken.isCancelled) cancelToken.cancel();
      if (isClosed) break;
      // Try again after a while.
      await Future.any([_sleep(_backoff.next()), _closing.future]);
    }
  }

  Future<void> _sleep(Duration delay) {
    if (_wait case final wait?) return wait(delay);
    final slept = Completer<void>();
    _timer = Timer(delay, slept.complete);
    return slept.future;
  }

  static bool _never(Object error) => false;
}
