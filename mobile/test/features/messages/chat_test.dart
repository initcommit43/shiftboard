import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftboard/core/widgets/app_button.dart';
import 'package:shiftboard/features/shifts/presentation/shift_card.dart';
import 'package:shiftboard/features/shifts/presentation/shift_detail_screen.dart';

import '../../support/fake_backend.dart';

const shiftId = '0199c0de-0000-7000-8000-0000000000c1';
const messagesRoute = 'GET /worker/conversation/messages';
const sendRoute = 'POST /worker/conversation/messages';

Map<String, Object?> message(
  int number,
  String body, {
  String type = 'TEXT',
  bool fromWorker = false,
  String? event,
  String? senderName,
  bool aboutShift = false,
}) => {
  'id': '0199c0de-0000-7000-8000-00000000020$number',
  'type': type,
  'event': ?event,
  'body': body,
  'fromWorker': fromWorker,
  'senderName': ?senderName,
  if (aboutShift)
    'shift': {
      'id': shiftId,
      'title': 'Lagerunterstützung',
      'startsAt': DateTime(2026, 10, 17, 18).toUtc().toIso8601String(),
    },
  'createdAt': DateTime(2026, 10, 15, 9, number).toUtc().toIso8601String(),
};

Finder button(String label) => find.widgetWithText(AppButton, label);

void main() {
  late FakeBackend backend;

  setUp(() {
    backend = FakeBackend();
    fakeTokenStorage(suffix: '1');
    backend.on('GET /me', (_) => json(currentUser('ACTIVE')));
  });

  Future<void> openMessagesTab(WidgetTester tester) async {
    await pumpApp(tester, backend);
    await tester.tap(find.text('Nachrichten'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the conversation with system messages and broadcasts', (
    tester,
  ) async {
    backend.on(
      messagesRoute,
      (_) => json(
        page([
          message(
            4,
            'Bitte Sicherheitsschuhe mitbringen.',
            type: 'BROADCAST',
            senderName: 'Anna Berger',
            aboutShift: true,
          ),
          message(
            3,
            'Deine Schicht „Lagerunterstützung“ ist bestätigt.',
            type: 'SYSTEM',
            event: 'CLAIM_CONFIRMED',
            aboutShift: true,
          ),
          message(2, 'Gibt es Parkplätze?', fromWorker: true),
        ]),
      ),
    );
    await openMessagesTab(tester);

    expect(find.text('Gibt es Parkplätze?'), findsOneWidget);
    // Worded by the app from the event, not the German fallback.
    expect(find.text('Deine Anfrage ist bestätigt.'), findsOneWidget);
    expect(find.text('An alle Bestätigten'), findsOneWidget);
    expect(find.textContaining('Anna Berger'), findsOneWidget);
    expect(find.text('Lagerunterstützung · Sa., 17. Okt.'), findsNWidgets(2));
  });

  testWidgets('shows the body of an event newer than the app', (tester) async {
    backend.on(
      messagesRoute,
      (_) => json(
        page([
          message(
            3,
            'Die Agentur hat deine Schicht getauscht.',
            type: 'SYSTEM',
            event: 'SHIFT_SWAPPED',
            aboutShift: true,
          ),
        ]),
      ),
    );
    await openMessagesTab(tester);

    expect(
      find.text('Die Agentur hat deine Schicht getauscht.'),
      findsOneWidget,
    );
  });

  testWidgets('shows an empty state before the first message', (tester) async {
    await openMessagesTab(tester);

    expect(find.text('Noch keine Nachrichten'), findsOneWidget);
  });

  testWidgets('sends a message', (tester) async {
    final sent = <Object?>[];
    backend.on(sendRoute, (options) {
      sent.add(options.data);
      return json(
        message(5, 'Darf ich mit dem Rad kommen?', fromWorker: true),
        201,
      );
    });
    await openMessagesTab(tester);

    await tester.enterText(
      find.byType(TextField),
      '  Darf ich mit dem Rad kommen? ',
    );
    backend.on(
      messagesRoute,
      (_) => json(
        page([message(5, 'Darf ich mit dem Rad kommen?', fromWorker: true)]),
      ),
    );
    await tester.tap(find.byTooltip('Senden'));
    await tester.pumpAndSettle();

    expect(jsonDecode(jsonEncode(sent.single)), {
      'body': 'Darf ich mit dem Rad kommen?',
    });
    expect(find.text('Darf ich mit dem Rad kommen?'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });

  testWidgets('a message from a shift carries the shift', (tester) async {
    final sent = <Object?>[];
    backend.on('GET /worker/shifts', (_) => json(page([workerShift()])));
    backend.on('GET /worker/shifts/$shiftId', (_) => json(workerShift()));
    backend.on(sendRoute, (options) {
      sent.add(options.data);
      return json(message(6, 'Wo ist Tor 3?', fromWorker: true), 201);
    });
    await pumpApp(tester, backend);
    await tester.tap(find.byType(ShiftCard));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      button('Nachricht schreiben'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ShiftDetailScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(button('Nachricht schreiben'));
    await tester.pumpAndSettle();

    expect(find.text('Lagerunterstützung · Sa., 17. Okt.'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'Wo ist Tor 3?');
    await tester.tap(find.byTooltip('Senden').last);
    await tester.pumpAndSettle();

    expect(jsonDecode(jsonEncode(sent.single)), {
      'body': 'Wo ist Tor 3?',
      'shiftId': shiftId,
    });
    // Sent: the next message is about nothing in particular again.
    expect(find.byType(InputChip), findsNothing);
  });

  testWidgets('the tab shows unread messages', (tester) async {
    backend.on('GET /worker/conversation', (_) => json({'unreadCount': 2}));
    await pumpApp(tester, backend);

    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('says when sending failed', (tester) async {
    backend.on(sendRoute, offline);
    await openMessagesTab(tester);

    await tester.enterText(find.byType(TextField), 'Hallo');
    await tester.tap(find.byTooltip('Senden'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Verbindung'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Hallo',
    );
  });
}
