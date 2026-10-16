import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftboard/features/shifts/presentation/my_shifts_view.dart';
import 'package:shiftboard/features/shifts/presentation/shift_card.dart';

import '../../support/fake_backend.dart';

void main() {
  late FakeBackend backend;

  setUp(() {
    backend = FakeBackend();
    fakeTokenStorage(suffix: '1');
    backend.on('GET /me', (_) => json(currentUser('ACTIVE')));
  });

  Future<void> openMyShifts(WidgetTester tester) async {
    await pumpApp(tester, backend);
    await tester.tap(find.text('Meine'));
    await tester.pumpAndSettle();
  }

  testWidgets('lists the claimed shifts in start order with their status', (
    tester,
  ) async {
    // Tall enough for all three cards.
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    backend.on(
      'GET /worker/my-shifts',
      (_) => json(
        page([
          workerShift(assignmentStatus: 'CONFIRMED'),
          workerShift(
            id: '0199c0de-0000-7000-8000-0000000000c2',
            title: 'Kommissionierung',
            start: DateTime(2026, 10, 18, 6),
            end: DateTime(2026, 10, 18, 14),
            assignmentStatus: 'PENDING',
          ),
          workerShift(
            id: '0199c0de-0000-7000-8000-0000000000c3',
            title: 'Inventur',
            start: DateTime(2026, 10, 20, 8),
            end: DateTime(2026, 10, 20, 16),
            assignmentStatus: 'REJECTED',
          ),
        ]),
      ),
    );

    await openMyShifts(tester);

    final cards = find.descendant(
      of: find.byType(MyShiftsView),
      matching: find.byType(ShiftCard),
    );
    expect(cards, findsNWidgets(3));
    final expected = [
      ('Lagerunterstützung', 'Bestätigt'),
      ('Kommissionierung', 'Angefragt'),
      ('Inventur', 'Abgelehnt'),
    ];
    for (final (index, (title, status)) in expected.indexed) {
      final card = cards.at(index);
      expect(
        find.descendant(of: card, matching: find.text(title)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card, matching: find.text(status)),
        findsOneWidget,
      );
    }
    expect(backend.sent('GET /worker/my-shifts').single.queryParameters, {
      'page': 0,
      'size': 100,
    });
  });

  testWidgets('tapping a claimed shift opens its detail', (tester) async {
    final shift = workerShift(assignmentStatus: 'PENDING');
    backend.on('GET /worker/my-shifts', (_) => json(page([shift])));
    backend.on(
      'GET /worker/shifts/0199c0de-0000-7000-8000-0000000000c1',
      (_) => json(shift),
    );
    await openMyShifts(tester);

    await tester.tap(find.byType(ShiftCard).hitTestable());
    await tester.pumpAndSettle();

    expect(find.text('Ansprechperson'), findsOneWidget);
    expect(
      backend.sent('GET /worker/shifts/0199c0de-0000-7000-8000-0000000000c1'),
      hasLength(1),
    );
  });

  testWidgets('without claims it shows an empty state that leads to the '
      'open shifts', (tester) async {
    await openMyShifts(tester);

    expect(
      find.text('Noch keine Schichten angefragt').hitTestable(),
      findsOneWidget,
    );

    await tester.tap(find.text('Offene Schichten ansehen'));
    await tester.pumpAndSettle();

    expect(
      find.text('Aktuell keine offenen Schichten').hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('a failed load offers a retry', (tester) async {
    backend.on('GET /worker/my-shifts', offline);
    await openMyShifts(tester);

    expect(
      find.text('Schichten konnten nicht geladen werden').hitTestable(),
      findsOneWidget,
    );

    backend.on(
      'GET /worker/my-shifts',
      (_) => json(page([workerShift(assignmentStatus: 'PENDING')])),
    );
    await tester.tap(find.text('Erneut versuchen').hitTestable());
    await tester.pumpAndSettle();

    expect(find.byType(ShiftCard).hitTestable(), findsOneWidget);
  });
}
