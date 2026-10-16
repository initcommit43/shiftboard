import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftboard/core/widgets/app_button.dart';
import 'package:shiftboard/features/shifts/presentation/shift_card.dart';

import '../../support/fake_backend.dart';

const shiftId = '0199c0de-0000-7000-8000-0000000000c1';
const detailRoute = 'GET /worker/shifts/$shiftId';
const claimRoute = 'POST /worker/shifts/$shiftId/claim';

Finder button(String label) => find.widgetWithText(AppButton, label);

void main() {
  late FakeBackend backend;

  setUp(() {
    backend = FakeBackend();
    fakeTokenStorage(suffix: '1');
    backend.on('GET /me', (_) => json(currentUser('ACTIVE')));
    backend.on('GET /worker/shifts', (_) => json(page([workerShift()])));
    backend.on(detailRoute, (_) => json(workerShift()));
  });

  Future<void> openSheet(WidgetTester tester) async {
    await pumpApp(tester, backend);
    await tester.tap(find.byType(ShiftCard));
    await tester.pumpAndSettle();
    await tester.tap(button('Schicht anfragen'));
    await tester.pumpAndSettle();
  }

  testWidgets('claims a spot after the worker confirms it', (tester) async {
    await openSheet(tester);

    expect(find.text('Schicht anfragen?'), findsOneWidget);
    expect(
      find.text(
        'Dein Platz ist reserviert, sobald du anfragst. '
        'Donau Personal bestätigt die Schicht danach.',
      ),
      findsOneWidget,
    );
    expect(backend.sent(claimRoute), isEmpty);

    final claimed = workerShift(takenSlots: 3, assignmentStatus: 'PENDING');
    backend.on(claimRoute, (_) => json(claimed, 201));
    backend.on(detailRoute, (_) => json(claimed));
    await tester.tap(button('Anfrage senden'));
    await tester.pumpAndSettle();

    expect(backend.sent(claimRoute), hasLength(1));
    expect(find.text('Schicht anfragen?'), findsNothing);
    expect(
      find.text(
        'Anfrage gesendet. Du hörst von Donau Personal, '
        'sobald sie bestätigt ist.',
      ),
      findsOneWidget,
    );
    expect(find.text('Angefragt'), findsOneWidget);
    expect(find.text('2 von 5 Plätzen frei'), findsOneWidget);
    expect(
      button('Schicht anfragen'),
      findsNothing,
    ); // My shifts loads again, so that it lists the new claim.
    expect(backend.sent('GET /worker/my-shifts'), hasLength(2));
  });

  testWidgets('shows progress while the claim is sent', (tester) async {
    final answer = Completer<ResponseBody>();
    backend.on(claimRoute, (_) => answer.future);
    await openSheet(tester);

    await tester.tap(button('Anfrage senden'));
    await tester.pump();

    expect(button('Wird gesendet …'), findsOneWidget);
    await tester.tap(button('Wird gesendet …'));
    await tester.pump();

    answer.complete(json(workerShift(assignmentStatus: 'PENDING'), 201));
    await tester.pumpAndSettle();
    expect(backend.sent(claimRoute), hasLength(1));
  });

  testWidgets('cancelling closes the sheet without claiming', (tester) async {
    await openSheet(tester);

    await tester.tap(button('Abbrechen'));
    await tester.pumpAndSettle();

    expect(find.text('Schicht anfragen?'), findsNothing);
    expect(backend.sent(claimRoute), isEmpty);
    expect(button('Schicht anfragen'), findsOneWidget);
  });

  testWidgets('says when the last spot was just taken and shows the shift '
      'as full', (tester) async {
    backend.on(claimRoute, (_) => problem(409, 'shift_full'));
    await openSheet(tester);
    backend.on(detailRoute, (_) => json(workerShift(takenSlots: 5)));

    await tester.tap(button('Anfrage senden'));
    await tester.pumpAndSettle();

    expect(
      find.text('Diese Schicht ist gerade voll geworden.'),
      findsOneWidget,
    );
    expect(backend.sent(detailRoute), hasLength(2));

    await tester.tap(button('Abbrechen'));
    await tester.pumpAndSettle();
    final claim = tester.widget<AppButton>(button('Keine Plätze frei'));
    expect(claim.onPressed, isNull);
  });

  for (final (code, message) in [
    ('shift_already_claimed', 'Du hast diese Schicht schon angefragt.'),
    ('shift_started', 'Diese Schicht hat schon begonnen.'),
    ('shift_not_open', 'Diese Schicht ist nicht mehr offen.'),
    ('shift_overlap', 'Du hast zu dieser Zeit schon eine Schicht.'),
  ]) {
    testWidgets('explains a claim rejected with $code', (tester) async {
      backend.on(claimRoute, (_) => problem(409, code));
      await openSheet(tester);

      await tester.tap(button('Anfrage senden'));
      await tester.pumpAndSettle();

      expect(find.text(message), findsOneWidget);
      expect(find.text('Schicht anfragen?'), findsOneWidget);
    });
  }

  testWidgets('says when the server is out of reach and lets the worker '
      'try again', (tester) async {
    backend.on(claimRoute, offline);
    await openSheet(tester);

    await tester.tap(button('Anfrage senden'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Keine Verbindung zum Server. Prüfe deine Internetverbindung und '
        'versuche es noch einmal.',
      ),
      findsOneWidget,
    );

    backend.on(
      claimRoute,
      (_) => json(workerShift(assignmentStatus: 'PENDING'), 201),
    );
    await tester.tap(button('Anfrage senden'));
    await tester.pumpAndSettle();

    expect(find.text('Schicht anfragen?'), findsNothing);
  });

  testWidgets('a full shift offers no claim', (tester) async {
    backend.on(detailRoute, (_) => json(workerShift(takenSlots: 5)));
    await pumpApp(tester, backend);
    await tester.tap(find.byType(ShiftCard));
    await tester.pumpAndSettle();

    await tester.tap(button('Keine Plätze frei'));
    await tester.pumpAndSettle();

    expect(find.text('Schicht anfragen?'), findsNothing);
  });

  testWidgets('a claimed shift offers no second claim', (tester) async {
    backend.on(
      detailRoute,
      (_) => json(workerShift(assignmentStatus: 'CONFIRMED')),
    );
    await pumpApp(tester, backend);
    await tester.tap(find.byType(ShiftCard));
    await tester.pumpAndSettle();

    expect(find.text('Bestätigt'), findsOneWidget);
    expect(button('Schicht anfragen'), findsNothing);
  });
}
