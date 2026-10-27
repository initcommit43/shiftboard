import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_backend.dart';
import 'chat_test.dart' show message, messagesRoute;

const eventsRoute = 'GET /worker/conversation/events';
const unreadRoute = 'GET /worker/conversation';

/// A `conversation` event as the server sends it, after a heartbeat.
String notice(String change) =>
    ': ping\n\n'
    'event: conversation\n'
    'data: {"conversationId":"0199c0de-0000-7000-8000-000000000301",'
    '"change":"$change"}\n\n';

void main() {
  late FakeBackend backend;
  late List<Map<String, Object?>> messages;
  late int unread;

  setUp(() {
    backend = FakeBackend();
    fakeTokenStorage(suffix: '1');
    messages = [message(1, 'Willkommen bei Donau Personal.')];
    unread = 0;
    backend
      ..on('GET /me', (_) => json(currentUser('ACTIVE')))
      ..on(messagesRoute, (_) => json(page([...messages])))
      ..on(unreadRoute, (_) => json({'unreadCount': unread}))
      ..on('POST /auth/logout', (_) => noContent());
  });

  /// The agency writes; the server stores it and sends a notice.
  Future<void> agencyWrites(WidgetTester tester, String body) async {
    messages.insert(0, message(messages.length + 1, body));
    unread++;
    backend.sendEvent(notice('MESSAGE'));
    await tester.pumpAndSettle();
  }

  Future<void> lifecycle(
    WidgetTester tester,
    List<AppLifecycleState> states,
  ) async {
    for (final state in states) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pumpAndSettle();
  }

  testWidgets('a new message shows up in the open chat', (tester) async {
    await pumpApp(tester, backend);
    await tester.tap(find.text('Nachrichten'));
    await tester.pumpAndSettle();
    expect(backend.openEventStreams, 1);

    await agencyWrites(tester, 'Kannst du morgen eine Stunde früher?');

    expect(find.text('Kannst du morgen eine Stunde früher?'), findsOneWidget);
  });

  testWidgets('the chat tab counts a message that arrives', (tester) async {
    await pumpApp(tester, backend);
    expect(find.text('1'), findsNothing);

    await agencyWrites(tester, 'Bitte Sicherheitsschuhe mitbringen.');

    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('a read notice updates the count without reloading the chat', (
    tester,
  ) async {
    unread = 2;
    await pumpApp(tester, backend);
    expect(find.text('2'), findsOneWidget);
    final loads = backend.sent(messagesRoute).length;

    unread = 0;
    backend.sendEvent(notice('READ'));
    await tester.pumpAndSettle();

    expect(find.text('2'), findsNothing);
    expect(backend.sent(messagesRoute), hasLength(loads));
  });

  testWidgets('a change newer than the app reloads like a message', (
    tester,
  ) async {
    await pumpApp(tester, backend);
    final loads = backend.sent(messagesRoute).length;

    unread = 1;
    backend.sendEvent(notice('REACTION'));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
    expect(backend.sent(messagesRoute), hasLength(loads + 1));
  });

  testWidgets('sends the token and asks for an event stream', (tester) async {
    await pumpApp(tester, backend);

    final request = backend.sent(eventsRoute).single;
    expect(request.headers['Authorization'], 'Bearer access-1');
    expect(request.headers['Accept'], 'text/event-stream');
  });

  testWidgets('closes in the background and catches up when back', (
    tester,
  ) async {
    await pumpApp(tester, backend);

    await lifecycle(tester, [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]);
    expect(backend.openEventStreams, 0);

    // A push would bring this while the app is away.
    messages.insert(0, message(2, 'Die Schicht beginnt um 7 Uhr.'));
    unread = 1;
    await lifecycle(tester, [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]);

    expect(backend.openEventStreams, 1);
    expect(backend.sent(eventsRoute), hasLength(2));
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('a short interruption keeps the stream', (tester) async {
    await pumpApp(tester, backend);

    await lifecycle(tester, [
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]);

    expect(backend.sent(eventsRoute), hasLength(1));
    expect(backend.openEventStreams, 1);
  });

  testWidgets('reconnects after the stream drops and catches up', (
    tester,
  ) async {
    await pumpApp(tester, backend);

    backend.dropEventStreams();
    await tester.pumpAndSettle();
    expect(backend.openEventStreams, 0);

    unread = 1;
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(backend.openEventStreams, 1);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('waits longer each time the server is unreachable', (
    tester,
  ) async {
    backend.on(eventsRoute, offline);
    await pumpApp(tester, backend);
    expect(backend.sent(eventsRoute), hasLength(1));

    await tester.pump(const Duration(seconds: 1));
    expect(backend.sent(eventsRoute), hasLength(2));
    await tester.pump(const Duration(seconds: 1));
    expect(backend.sent(eventsRoute), hasLength(2));
    await tester.pump(const Duration(seconds: 1));
    expect(backend.sent(eventsRoute), hasLength(3));

    backend.on(eventsRoute, (_) => backend.eventStream());
    await tester.pump(const Duration(seconds: 4));
    expect(backend.openEventStreams, 1);
  });

  testWidgets('renews an expired token and connects', (tester) async {
    backend
      ..on('POST /auth/refresh', (_) => json(tokenPair('2')))
      ..on(
        eventsRoute,
        (options) => options.headers['Authorization'] == 'Bearer access-1'
            ? problem(401, 'unauthorized')
            : backend.eventStream(),
      );
    await pumpApp(tester, backend);

    expect(backend.sent('POST /auth/refresh'), hasLength(1));
    expect(backend.openEventStreams, 1);
  });

  testWidgets('stops when the worker may not chat', (tester) async {
    backend.on(eventsRoute, (_) => problem(403, 'worker_not_active'));
    await pumpApp(tester, backend);

    await tester.pump(const Duration(minutes: 1));

    expect(backend.sent(eventsRoute), hasLength(1));
  });

  testWidgets('opens no stream before the agency approved', (tester) async {
    backend.on('GET /me', (_) => json(currentUser('PENDING')));
    await pumpApp(tester, backend);

    expect(backend.sent(eventsRoute), isEmpty);
  });

  testWidgets('closes the stream on logout', (tester) async {
    await pumpApp(tester, backend);
    expect(backend.openEventStreams, 1);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await scrollToAndTap(tester, find.text('Abmelden'));
    await tester.pumpAndSettle();

    expect(backend.openEventStreams, 0);
  });
}
