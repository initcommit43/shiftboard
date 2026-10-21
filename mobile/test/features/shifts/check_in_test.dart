import 'package:flutter_test/flutter_test.dart';
import 'package:shiftboard/core/platform/clock.dart';
import 'package:shiftboard/core/widgets/app_button.dart';
import 'package:shiftboard/features/shifts/presentation/my_shifts_view.dart';
import 'package:shiftboard/features/shifts/presentation/shift_card.dart';

import '../../support/fake_backend.dart';

const shiftId = '0199c0de-0000-7000-8000-0000000000c1';
const detailRoute = 'GET /worker/shifts/$shiftId';
const checkInRoute = 'POST /worker/shifts/$shiftId/check-in';
const checkOutRoute = 'POST /worker/shifts/$shiftId/check-out';

/// The shift runs on Saturday, 17 October, from 07:00 to 16:00; check-in
/// opens half an hour before.
final start = DateTime(2026, 10, 17, 7);
final end = DateTime(2026, 10, 17, 16);
final checkInFrom = DateTime(2026, 10, 17, 6, 30);
final deadline = DateTime(2026, 10, 16, 7);
final arrived = DateTime(2026, 10, 17, 6, 58);
final left = DateTime(2026, 10, 17, 16, 4);

Finder button(String label) => find.widgetWithText(AppButton, label);

/// The fixture shift with a confirmed spot at an agency that uses check-in.
Map<String, Object?> confirmed({
  String assignmentStatus = 'CONFIRMED',
  bool withCheckIn = true,
  DateTime? checkedInAt,
  DateTime? checkedOutAt,
  bool? hoursApproved,
}) => workerShift(
  start: start,
  end: end,
  takenSlots: 3,
  assignmentStatus: assignmentStatus,
  cancellableUntil: deadline,
  checkInFrom: withCheckIn ? checkInFrom : null,
  checkedInAt: checkedInAt,
  checkedOutAt: checkedOutAt,
  hoursApproved: hoursApproved,
);

void main() {
  late FakeBackend backend;
  late DateTime now;

  setUp(() {
    backend = FakeBackend();
    now = DateTime(2026, 10, 17, 6, 50);
    fakeTokenStorage(suffix: '1');
    backend.on('GET /me', (_) => json(currentUser('ACTIVE', checkIn: true)));
  });

  void serve(Map<String, Object?> shift) {
    backend.on('GET /worker/shifts', (_) => json(page([shift])));
    backend.on(detailRoute, (_) => json(shift));
  }

  Future<void> openDetail(WidgetTester tester) async {
    await pumpApp(
      tester,
      backend,
      overrides: [clockProvider.overrideWithValue(() => now)],
    );
    await tester.tap(find.byType(ShiftCard));
    await tester.pumpAndSettle();
  }

  testWidgets('offers no check-in where the agency does not use it', (
    tester,
  ) async {
    backend.on('GET /me', (_) => json(currentUser('ACTIVE')));
    serve(confirmed(withCheckIn: false));
    await openDetail(tester);

    expect(find.textContaining('Einchecken'), findsNothing);
    expect(find.textContaining('Eingecheckt'), findsNothing);
    expect(button('Auschecken'), findsNothing);
  });

  testWidgets('says when check-in opens while the worker can still drop out', (
    tester,
  ) async {
    now = DateTime(2026, 10, 15, 10);
    serve(confirmed());
    await openDetail(tester);

    expect(find.text('Einchecken ab Sa., 17. Okt., 06:30'), findsOneWidget);
    expect(button('Schicht absagen'), findsOneWidget);
    expect(button('Einchecken'), findsNothing);
  });

  testWidgets('before check-in opens, shows the time instead of the button', (
    tester,
  ) async {
    now = DateTime(2026, 10, 17, 6, 10);
    serve(confirmed());
    await openDetail(tester);

    final waiting = tester.widget<AppButton>(button('Einchecken ab 06:30'));
    expect(waiting.onPressed, isNull);
    expect(button('Absagefrist vorbei'), findsNothing);
    expect(
      find.text('Wenn du nicht kommen kannst, sag Anna Berger Bescheid.'),
      findsOneWidget,
    );
  });

  testWidgets('checks in with one tap and shows the time', (tester) async {
    serve(confirmed());
    await openDetail(tester);

    expect(button('Schicht absagen'), findsNothing);
    backend.on(checkInRoute, (_) => json(confirmed(checkedInAt: arrived)));
    await tester.tap(button('Einchecken'));
    await tester.pumpAndSettle();

    expect(backend.sent(checkInRoute), hasLength(1));
    expect(find.text('Du bist eingecheckt.'), findsOneWidget);
    expect(find.text('Eingecheckt um 06:58'), findsOneWidget);
    expect(find.text('Eingecheckt'), findsOneWidget);
    expect(button('Auschecken'), findsOneWidget);
    expect(button('Einchecken'), findsNothing);
    // The returned shift is shown as it is, without loading it again.
    expect(backend.sent(detailRoute), hasLength(1));
  });

  testWidgets('checks out after the worker confirms it', (tester) async {
    now = DateTime(2026, 10, 17, 16, 4);
    serve(confirmed(checkedInAt: arrived));
    await openDetail(tester);

    await tester.tap(button('Auschecken'));
    await tester.pumpAndSettle();
    expect(find.text('Jetzt auschecken?'), findsOneWidget);

    await tester.tap(button('Noch nicht'));
    await tester.pumpAndSettle();
    expect(find.text('Jetzt auschecken?'), findsNothing);
    expect(backend.sent(checkOutRoute), isEmpty);

    await tester.tap(button('Auschecken'));
    await tester.pumpAndSettle();
    backend.on(
      checkOutRoute,
      (_) => json(confirmed(checkedInAt: arrived, checkedOutAt: left)),
    );
    await tester.tap(button('Auschecken').last);
    await tester.pumpAndSettle();

    expect(backend.sent(checkOutRoute), hasLength(1));
    expect(find.text('Jetzt auschecken?'), findsNothing);
    expect(find.text('Du bist ausgecheckt.'), findsOneWidget);
    expect(find.text('06:58 – 16:04'), findsOneWidget);
    expect(
      find.text(
        'Ändern kannst du die Zeiten nicht. Wenn etwas nicht stimmt, '
        'korrigiert Donau Personal sie.',
      ),
      findsOneWidget,
    );
    expect(button('Auschecken'), findsNothing);
    expect(find.text('Bestätigt'), findsOneWidget);
  });

  testWidgets('says when the agency approved the hours', (tester) async {
    now = DateTime(2026, 10, 18, 9);
    serve(
      confirmed(
        assignmentStatus: 'COMPLETED',
        checkedInAt: arrived,
        checkedOutAt: left,
        hoursApproved: true,
      ),
    );
    await openDetail(tester);

    expect(find.text('06:58 – 16:04'), findsOneWidget);
    expect(
      find.text('Donau Personal hat deine Stunden bestätigt.'),
      findsOneWidget,
    );
    expect(find.textContaining('korrigiert'), findsNothing);
  });

  testWidgets('offers no check-out once the hours are approved', (
    tester,
  ) async {
    now = DateTime(2026, 10, 18, 9);
    serve(
      confirmed(
        assignmentStatus: 'COMPLETED',
        checkedInAt: arrived,
        hoursApproved: true,
      ),
    );
    await openDetail(tester);

    expect(find.text('Eingecheckt um 06:58'), findsOneWidget);
    expect(button('Auschecken'), findsNothing);
  });

  testWidgets('still lets the worker check out after the shift completed', (
    tester,
  ) async {
    now = DateTime(2026, 10, 17, 19);
    serve(confirmed(assignmentStatus: 'COMPLETED', checkedInAt: arrived));
    await openDetail(tester);

    expect(find.text('Erledigt'), findsOneWidget);
    expect(button('Auschecken'), findsOneWidget);
  });

  testWidgets('offers no check-in after the planned end', (tester) async {
    now = DateTime(2026, 10, 17, 16, 30);
    serve(confirmed());
    await openDetail(tester);

    expect(find.textContaining('Einchecken'), findsNothing);
    expect(button('Auschecken'), findsNothing);
  });

  testWidgets('explains a rejected check-in and reloads the shift', (
    tester,
  ) async {
    serve(confirmed());
    await openDetail(tester);

    backend.on(checkInRoute, (_) => problem(409, 'check_in_not_open'));
    await tester.tap(button('Einchecken'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Einchecken geht ab 30 Minuten vor Beginn bis zum Ende der Schicht.',
      ),
      findsOneWidget,
    );
    expect(backend.sent(detailRoute), hasLength(2));
  });

  testWidgets('explains a rejected check-out in the sheet', (tester) async {
    now = DateTime(2026, 10, 17, 16, 4);
    serve(confirmed(checkedInAt: arrived));
    await openDetail(tester);

    await tester.tap(button('Auschecken'));
    await tester.pumpAndSettle();
    backend.on(checkOutRoute, (_) => problem(409, 'hours_approved'));
    serve(confirmed(checkedInAt: arrived, hoursApproved: true));
    await tester.tap(button('Auschecken').last);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Donau Personal hat deine Stunden schon bestätigt. '
        'Auschecken geht nicht mehr.',
      ),
      findsOneWidget,
    );
    expect(backend.sent(detailRoute), hasLength(2));
  });

  testWidgets('marks a checked-in shift in the worker\'s shifts', (
    tester,
  ) async {
    backend.on(
      'GET /worker/my-shifts',
      (_) => json(page([confirmed(checkedInAt: arrived)])),
    );
    await pumpApp(
      tester,
      backend,
      overrides: [clockProvider.overrideWithValue(() => now)],
    );
    await tester.tap(find.text('Meine'));
    await tester.pumpAndSettle();

    final card = find.descendant(
      of: find.byType(MyShiftsView),
      matching: find.byType(ShiftCard),
    );
    expect(
      find.descendant(of: card, matching: find.text('Eingecheckt')),
      findsOneWidget,
    );
  });
}
