import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftboard/core/platform/clock.dart';
import 'package:shiftboard/core/widgets/app_button.dart';
import 'package:shiftboard/features/shifts/presentation/shift_card.dart';

import '../../support/fake_backend.dart';

const shiftId = '0199c0de-0000-7000-8000-0000000000c1';
const detailRoute = 'GET /worker/shifts/$shiftId';
const joinRoute = 'POST /worker/shifts/$shiftId/waitlist';
const leaveRoute = 'DELETE /worker/shifts/$shiftId/waitlist';
const claimRoute = 'POST /worker/shifts/$shiftId/claim';

Finder button(String label) => find.widgetWithText(AppButton, label);

void main() {
  late FakeBackend backend;
  late DateTime now;

  /// The fixture shift is full; the agency uses the waitlist.
  final full = workerShift(takenSlots: 5, waitlistEnabled: true);
  Map<String, Object?> waiting(int position, {int takenSlots = 5}) =>
      workerShift(
        takenSlots: takenSlots,
        waitlistEnabled: true,
        waitlistPosition: position,
      );

  setUp(() {
    backend = FakeBackend();
    // Before the start on Saturday, 17 October at 18:00.
    now = DateTime(2026, 10, 15, 10);
    fakeTokenStorage(suffix: '1');
    backend.on('GET /me', (_) => json(currentUser('ACTIVE')));
    backend.on('GET /worker/shifts', (_) => json(page([full])));
    backend.on(detailRoute, (_) => json(full));
  });

  Future<void> openDetail(WidgetTester tester) async {
    await pumpApp(
      tester,
      backend,
      overrides: [clockProvider.overrideWithValue(() => now)],
    );
    await tester.tap(find.byType(ShiftCard));
    await tester.pumpAndSettle();
  }

  Future<void> openJoinSheet(WidgetTester tester) async {
    await openDetail(tester);
    await tester.tap(button('Auf die Warteliste'));
    await tester.pumpAndSettle();
  }

  group('joining', () {
    testWidgets('a full shift offers the waitlist instead of the claim', (
      tester,
    ) async {
      await openDetail(tester);

      expect(button('Auf die Warteliste'), findsOneWidget);
      expect(button('Keine Plätze frei'), findsNothing);
      expect(button('Schicht anfragen'), findsNothing);
      expect(find.text('Keine Plätze frei · Warteliste offen'), findsOneWidget);
    });

    testWidgets('the list card says the waitlist is open', (tester) async {
      await pumpApp(tester, backend);

      expect(
        find.descendant(
          of: find.byType(ShiftCard),
          matching: find.text('Keine Plätze frei · Warteliste offen'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('joins after the worker confirms and shows the place', (
      tester,
    ) async {
      await openJoinSheet(tester);

      expect(find.text('Auf die Warteliste?'), findsOneWidget);
      expect(
        find.textContaining('rückst du der Reihe nach automatisch nach'),
        findsOneWidget,
      );
      expect(backend.sent(joinRoute), isEmpty);

      backend.on(joinRoute, (_) => json(waiting(2), 201));
      backend.on(detailRoute, (_) => json(waiting(2)));
      await tester.tap(button('Eintragen'));
      await tester.pumpAndSettle();

      expect(backend.sent(joinRoute), hasLength(1));
      expect(find.text('Auf die Warteliste?'), findsNothing);
      expect(
        find.text('Du stehst auf der Warteliste, Platz 2.'),
        findsOneWidget,
      );
      expect(find.text('Warteliste · Platz 2'), findsOneWidget);
      expect(find.text('Vor dir wartet noch 1 Person.'), findsOneWidget);
      expect(button('Warteliste verlassen'), findsOneWidget);
      expect(button('Auf die Warteliste'), findsNothing);
      // My shifts loads again, so that it lists the waiting shift.
      expect(backend.sent('GET /worker/my-shifts'), hasLength(2));
    });

    testWidgets('shows progress while joining', (tester) async {
      final answer = Completer<ResponseBody>();
      backend.on(joinRoute, (_) => answer.future);
      await openJoinSheet(tester);

      await tester.tap(button('Eintragen'));
      await tester.pump();

      expect(button('Wird eingetragen …'), findsOneWidget);
      await tester.tap(button('Wird eingetragen …'));
      await tester.pump();

      answer.complete(json(waiting(1), 201));
      await tester.pumpAndSettle();
      expect(backend.sent(joinRoute), hasLength(1));
    });

    testWidgets('cancelling closes the sheet without joining', (tester) async {
      await openJoinSheet(tester);

      await tester.tap(button('Abbrechen'));
      await tester.pumpAndSettle();

      expect(find.text('Auf die Warteliste?'), findsNothing);
      expect(backend.sent(joinRoute), isEmpty);
      expect(button('Auf die Warteliste'), findsOneWidget);
    });

    for (final (code, message) in [
      ('waitlist_disabled', 'Für diese Schicht gibt es keine Warteliste mehr.'),
      (
        'shift_not_full',
        'Gerade ist ein Platz frei geworden. Du kannst die Schicht jetzt '
            'anfragen.',
      ),
      ('already_on_waitlist', 'Du stehst schon auf der Warteliste.'),
      ('shift_already_claimed', 'Du hast diese Schicht schon angefragt.'),
      ('shift_started', 'Diese Schicht hat schon begonnen.'),
      ('shift_not_open', 'Diese Schicht ist nicht mehr offen.'),
      ('shift_overlap', 'Du hast zu dieser Zeit schon eine Schicht.'),
    ]) {
      testWidgets('explains a join rejected with $code', (tester) async {
        backend.on(joinRoute, (_) => problem(409, code));
        await openJoinSheet(tester);

        await tester.tap(button('Eintragen'));
        await tester.pumpAndSettle();

        expect(find.text(message), findsOneWidget);
        expect(find.text('Auf die Warteliste?'), findsOneWidget);
      });
    }

    testWidgets('a spot freed while the sheet was open leads to the claim', (
      tester,
    ) async {
      backend.on(joinRoute, (_) => problem(409, 'shift_not_full'));
      await openJoinSheet(tester);
      backend.on(
        detailRoute,
        (_) => json(workerShift(takenSlots: 4, waitlistEnabled: true)),
      );

      await tester.tap(button('Eintragen'));
      await tester.pumpAndSettle();
      expect(backend.sent(detailRoute), hasLength(2));

      await tester.tap(button('Abbrechen'));
      await tester.pumpAndSettle();
      expect(button('Schicht anfragen'), findsOneWidget);
    });

    testWidgets('says when the server is out of reach', (tester) async {
      backend.on(joinRoute, offline);
      await openJoinSheet(tester);

      await tester.tap(button('Eintragen'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Keine Verbindung zum Server. Prüfe deine Internetverbindung und '
          'versuche es noch einmal.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('without the agency setting a full shift looks as before', (
      tester,
    ) async {
      final withoutWaitlist = workerShift(takenSlots: 5);
      backend.on('GET /worker/shifts', (_) => json(page([withoutWaitlist])));
      backend.on(detailRoute, (_) => json(withoutWaitlist));
      await openDetail(tester);

      expect(button('Auf die Warteliste'), findsNothing);
      final disabled = tester.widget<AppButton>(button('Keine Plätze frei'));
      expect(disabled.onPressed, isNull);
    });

    testWidgets('a started shift offers no waitlist', (tester) async {
      now = DateTime(2026, 10, 17, 18, 30);
      await openDetail(tester);

      expect(button('Auf die Warteliste'), findsNothing);
      expect(button('Keine Plätze frei'), findsOneWidget);
    });

    testWidgets('a claimed full shift offers no waitlist', (tester) async {
      final claimed = workerShift(
        takenSlots: 5,
        waitlistEnabled: true,
        assignmentStatus: 'CANCELLED',
        cancelledBy: 'WORKER',
      );
      backend.on('GET /worker/shifts', (_) => json(page([claimed])));
      backend.on(detailRoute, (_) => json(claimed));
      await openDetail(tester);

      expect(button('Auf die Warteliste'), findsNothing);
    });
  });

  group('waiting', () {
    setUp(() {
      backend.on('GET /worker/shifts', (_) => json(page([waiting(1)])));
      backend.on(detailRoute, (_) => json(waiting(1)));
    });

    testWidgets('shows the place on the card and the detail', (tester) async {
      await pumpApp(
        tester,
        backend,
        overrides: [clockProvider.overrideWithValue(() => now)],
      );

      expect(
        find.descendant(
          of: find.byType(ShiftCard),
          matching: find.text('Warteliste · Platz 1'),
        ),
        findsOneWidget,
      );
      expect(find.text('Keine Plätze frei'), findsOneWidget);

      await tester.tap(find.byType(ShiftCard));
      await tester.pumpAndSettle();

      expect(find.text('Warteliste · Platz 1'), findsOneWidget);
      expect(
        find.text('Du rückst als Nächstes nach, wenn ein Platz frei wird.'),
        findsOneWidget,
      );
      expect(button('Warteliste verlassen'), findsOneWidget);
      expect(button('Schicht anfragen'), findsNothing);
    });

    testWidgets('leaves after the worker confirms it', (tester) async {
      await openDetail(tester);
      await tester.tap(button('Warteliste verlassen'));
      await tester.pumpAndSettle();

      expect(find.text('Warteliste verlassen?'), findsOneWidget);
      expect(backend.sent(leaveRoute), isEmpty);

      backend.on(leaveRoute, (_) => json(full));
      backend.on(detailRoute, (_) => json(full));
      await tester.tap(button('Verlassen'));
      await tester.pumpAndSettle();

      expect(backend.sent(leaveRoute), hasLength(1));
      expect(find.text('Warteliste verlassen?'), findsNothing);
      expect(
        find.text('Du stehst nicht mehr auf der Warteliste.'),
        findsOneWidget,
      );
      expect(find.text('Warteliste · Platz 1'), findsNothing);
      // Joining again puts the worker at the back of the line.
      expect(button('Auf die Warteliste'), findsOneWidget);
      expect(backend.sent('GET /worker/my-shifts'), hasLength(2));
    });

    testWidgets('keeps the place when the worker changes their mind', (
      tester,
    ) async {
      await openDetail(tester);
      await tester.tap(button('Warteliste verlassen'));
      await tester.pumpAndSettle();

      await tester.tap(button('Bleiben'));
      await tester.pumpAndSettle();

      expect(find.text('Warteliste verlassen?'), findsNothing);
      expect(backend.sent(leaveRoute), isEmpty);
      expect(button('Warteliste verlassen'), findsOneWidget);
    });

    testWidgets('a worker who moved up meanwhile sees their claim', (
      tester,
    ) async {
      await openDetail(tester);
      await tester.tap(button('Warteliste verlassen'));
      await tester.pumpAndSettle();

      backend.on(leaveRoute, (_) => problem(404, 'not_on_waitlist'));
      backend.on(
        detailRoute,
        (_) => json(workerShift(takenSlots: 5, assignmentStatus: 'PENDING')),
      );
      await tester.tap(button('Verlassen'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Du stehst nicht mehr auf der Warteliste. Vielleicht bist du '
          'gerade nachgerückt.',
        ),
        findsOneWidget,
      );

      await tester.tap(button('Bleiben'));
      await tester.pumpAndSettle();
      expect(find.text('Angefragt'), findsOneWidget);
      expect(button('Warteliste verlassen'), findsNothing);
    });

    testWidgets('explains a leave after the start', (tester) async {
      await openDetail(tester);
      await tester.tap(button('Warteliste verlassen'));
      await tester.pumpAndSettle();

      backend.on(leaveRoute, (_) => problem(409, 'shift_started'));
      await tester.tap(button('Verlassen'));
      await tester.pumpAndSettle();

      expect(find.text('Diese Schicht hat schon begonnen.'), findsOneWidget);
    });

    testWidgets('further back in line says how many are ahead', (tester) async {
      backend.on(detailRoute, (_) => json(waiting(4)));
      await openDetail(tester);

      expect(find.text('Warteliste · Platz 4'), findsOneWidget);
      expect(find.text('Vor dir warten noch 3 Personen.'), findsOneWidget);
    });

    testWidgets('leaving stays possible once the agency switched it off', (
      tester,
    ) async {
      final switchedOff = workerShift(takenSlots: 5, waitlistPosition: 2);
      backend.on(detailRoute, (_) => json(switchedOff));
      await openDetail(tester);

      expect(button('Warteliste verlassen'), findsOneWidget);
    });

    testWidgets('a free spot after the deadline can be claimed', (
      tester,
    ) async {
      final spotFree = waiting(2, takenSlots: 4);
      backend.on(detailRoute, (_) => json(spotFree));
      await openDetail(tester);

      expect(
        find.text('Ein Platz ist frei. Wer zuerst anfragt, bekommt ihn.'),
        findsOneWidget,
      );
      expect(button('Warteliste verlassen'), findsOneWidget);

      await tester.tap(button('Schicht anfragen'));
      await tester.pumpAndSettle();
      final claimed = workerShift(takenSlots: 5, assignmentStatus: 'PENDING');
      backend.on(claimRoute, (_) => json(claimed, 201));
      backend.on(detailRoute, (_) => json(claimed));
      await tester.tap(button('Anfrage senden'));
      await tester.pumpAndSettle();

      expect(backend.sent(claimRoute), hasLength(1));
      expect(find.text('Angefragt'), findsOneWidget);
      expect(find.text('Warteliste · Platz 2'), findsNothing);
      expect(button('Warteliste verlassen'), findsNothing);
    });

    testWidgets('offers nothing once the shift has started', (tester) async {
      now = DateTime(2026, 10, 17, 18, 30);
      await openDetail(tester);

      expect(button('Warteliste verlassen'), findsNothing);
      expect(button('Auf die Warteliste'), findsNothing);
      expect(button('Schicht anfragen'), findsNothing);
    });
  });
}
