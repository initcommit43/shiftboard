import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftboard/features/shifts/presentation/shift_card.dart';

import '../../support/fake_backend.dart';

void main() {
  late FakeBackend backend;

  setUp(() {
    backend = FakeBackend();
    fakeTokenStorage(suffix: '1');
    backend.on('GET /me', (_) => json(currentUser('ACTIVE')));
  });

  testWidgets('a card shows what the worker needs to decide', (tester) async {
    backend.on(
      'GET /worker/shifts',
      (_) => json(
        page([
          workerShift(
            start: DateTime(2026, 10, 17, 18),
            end: DateTime(2026, 10, 17, 23, 30),
            hourlyRateCents: 1450,
            slots: 5,
            takenSlots: 2,
          ),
        ]),
      ),
    );

    await pumpApp(tester, backend);

    expect(find.byType(ShiftCard), findsOneWidget);
    expect(find.text('Lagerunterstützung'), findsOneWidget);
    expect(find.text('Nordlicht Logistik'), findsOneWidget);
    expect(find.text('Sa., 17. Okt. · 18:00 – 23:30'), findsOneWidget);
    expect(find.text('Zentrallager Linz'), findsOneWidget);
    expect(find.text('79,75\u00a0€'), findsOneWidget);
    expect(
      find.text('Brutto für die Schicht · 14,50\u00a0€ pro Stunde'),
      findsOneWidget,
    );
    expect(find.text('3 von 5 Plätzen frei'), findsOneWidget);
    expect(backend.sent('GET /worker/shifts').single.queryParameters, {
      'page': 0,
      'size': 100,
    });
  });

  testWidgets('an estimated end shows "ca." at the time and the pay', (
    tester,
  ) async {
    backend.on(
      'GET /worker/shifts',
      (_) => json(page([workerShift(endIsEstimate: true)])),
    );

    await pumpApp(tester, backend);

    expect(find.text('Sa., 17. Okt. · 18:00 – ca. 23:30'), findsOneWidget);
    expect(find.text('ca. 79,75\u00a0€'), findsOneWidget);
  });

  testWidgets('a full shift stays in the list, marked full', (tester) async {
    backend.on(
      'GET /worker/shifts',
      (_) => json(
        page([
          workerShift(title: 'Messeaufbau', slots: 3, takenSlots: 3),
          workerShift(
            id: '0199c0de-0000-7000-8000-0000000000c2',
            title: 'Kommissionierung',
            start: DateTime(2026, 10, 18, 6),
            end: DateTime(2026, 10, 18, 14),
          ),
        ]),
      ),
    );

    await pumpApp(tester, backend);

    final cards = find.byType(ShiftCard);
    expect(cards, findsNWidgets(2));
    final full = cards.first;
    expect(
      find.descendant(of: full, matching: find.text('Messeaufbau')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: full, matching: find.text('Ausgebucht')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: full, matching: find.text('Keine Plätze frei')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: cards.last, matching: find.text('Ausgebucht')),
      findsNothing,
    );
  });

  testWidgets('a claimed shift shows the state of the claim', (tester) async {
    backend.on(
      'GET /worker/shifts',
      (_) => json(page([workerShift(assignmentStatus: 'PENDING')])),
    );

    await pumpApp(tester, backend);

    expect(find.text('Angefragt'), findsOneWidget);
  });

  testWidgets('pull to refresh loads the list again', (tester) async {
    backend.on('GET /worker/shifts', (_) => json(page([workerShift()])));
    await pumpApp(tester, backend);
    backend.on(
      'GET /worker/shifts',
      (_) => json(page([workerShift(title: 'Inventur')])),
    );

    await tester.fling(find.byType(ShiftCard), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(find.text('Inventur'), findsOneWidget);
    expect(find.text('Lagerunterstützung'), findsNothing);
  });

  testWidgets('a failed refresh keeps the list and says so', (tester) async {
    backend.on('GET /worker/shifts', (_) => json(page([workerShift()])));
    await pumpApp(tester, backend);
    backend.on('GET /worker/shifts', offline);

    await tester.fling(find.byType(ShiftCard), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(find.text('Lagerunterstützung'), findsOneWidget);
    expect(
      find.text('Die Schichten konnten nicht aktualisiert werden.'),
      findsOneWidget,
    );
  });

  testWidgets('a failed first load offers a retry', (tester) async {
    backend.on('GET /worker/shifts', offline);
    await pumpApp(tester, backend);

    expect(find.text('Schichten konnten nicht geladen werden'), findsOneWidget);

    backend.on('GET /worker/shifts', (_) => json(page([workerShift()])));
    await tester.tap(find.text('Erneut versuchen'));
    await tester.pumpAndSettle();

    expect(find.byType(ShiftCard), findsOneWidget);
  });

  testWidgets('cards stack their content with large text', (tester) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    backend.on(
      'GET /worker/shifts',
      (_) => json(page([workerShift(slots: 1, takenSlots: 1)])),
    );

    await pumpApp(tester, backend);

    expect(tester.takeException(), isNull);
    final badge = tester.getTopLeft(find.text('Ausgebucht'));
    final title = tester.getTopLeft(find.text('Lagerunterstützung'));
    expect(badge.dy, lessThan(title.dy));
  });
}
