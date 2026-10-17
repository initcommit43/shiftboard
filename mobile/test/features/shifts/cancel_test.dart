import 'package:flutter_test/flutter_test.dart';
import 'package:shiftboard/core/platform/clock.dart';
import 'package:shiftboard/core/platform/url_opener.dart';
import 'package:shiftboard/core/widgets/app_button.dart';
import 'package:shiftboard/features/shifts/presentation/shift_card.dart';

import '../../support/fake_backend.dart';

const shiftId = '0199c0de-0000-7000-8000-0000000000c1';
const detailRoute = 'GET /worker/shifts/$shiftId';
const cancelRoute = 'POST /worker/shifts/$shiftId/cancel';

/// The fixture shift starts on Saturday, 17 October at 18:00.
final deadline = DateTime(2026, 10, 16, 18);

Finder button(String label) => find.widgetWithText(AppButton, label);

void main() {
  late FakeBackend backend;
  late DateTime now;
  final opened = <Uri>[];

  final claimed = workerShift(
    takenSlots: 3,
    assignmentStatus: 'CONFIRMED',
    cancellableUntil: deadline,
  );

  setUp(() {
    backend = FakeBackend();
    now = DateTime(2026, 10, 15, 10);
    opened.clear();
    fakeTokenStorage(suffix: '1');
    backend.on('GET /me', (_) => json(currentUser('ACTIVE')));
    backend.on('GET /worker/shifts', (_) => json(page([claimed])));
    backend.on(detailRoute, (_) => json(claimed));
  });

  Future<void> openDetail(WidgetTester tester) async {
    await pumpApp(
      tester,
      backend,
      overrides: [
        clockProvider.overrideWithValue(() => now),
        urlOpenerProvider.overrideWithValue((uri) async {
          opened.add(uri);
          return true;
        }),
      ],
    );
    await tester.tap(find.byType(ShiftCard));
    await tester.pumpAndSettle();
  }

  testWidgets('shows until when the worker can drop out', (tester) async {
    await openDetail(tester);

    expect(
      find.text('Absagen in der App bis Fr., 16. Okt., 18:00'),
      findsOneWidget,
    );
    expect(button('Schicht absagen'), findsOneWidget);
    expect(button('Schicht anfragen'), findsNothing);
  });

  testWidgets('drops out after the worker confirms it', (tester) async {
    await openDetail(tester);
    await tester.tap(button('Schicht absagen'));
    await tester.pumpAndSettle();

    expect(find.text('Schicht absagen?'), findsOneWidget);
    expect(backend.sent(cancelRoute), isEmpty);

    final cancelled = workerShift(
      takenSlots: 2,
      assignmentStatus: 'CANCELLED',
      cancelledBy: 'WORKER',
    );
    backend.on(cancelRoute, (_) => json(cancelled));
    backend.on(detailRoute, (_) => json(cancelled));
    await tester.tap(button('Absagen'));
    await tester.pumpAndSettle();

    expect(backend.sent(cancelRoute), hasLength(1));
    expect(find.text('Schicht absagen?'), findsNothing);
    expect(find.text('Du hast die Schicht abgesagt.'), findsOneWidget);
    expect(find.text('Du hast diese Schicht abgesagt.'), findsOneWidget);
    expect(find.text('Storniert'), findsOneWidget);
    expect(button('Schicht absagen'), findsNothing);
    expect(backend.sent('GET /worker/my-shifts'), hasLength(2));
  });

  testWidgets('keeps the shift when the worker changes their mind', (
    tester,
  ) async {
    await openDetail(tester);
    await tester.tap(button('Schicht absagen'));
    await tester.pumpAndSettle();

    await tester.tap(button('Behalten'));
    await tester.pumpAndSettle();

    expect(find.text('Schicht absagen?'), findsNothing);
    expect(backend.sent(cancelRoute), isEmpty);
    expect(button('Schicht absagen'), findsOneWidget);
  });

  testWidgets('explains a deadline that passed while the sheet was open', (
    tester,
  ) async {
    await openDetail(tester);
    await tester.tap(button('Schicht absagen'));
    await tester.pumpAndSettle();

    backend.on(
      cancelRoute,
      (_) => problem(409, 'cancellation_deadline_passed'),
    );
    await tester.tap(button('Absagen'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Die Absagefrist ist gerade abgelaufen. Sag der Agentur Bescheid.',
      ),
      findsOneWidget,
    );
    expect(find.text('Schicht absagen?'), findsOneWidget);
  });

  testWidgets('after the deadline points to the contact instead', (
    tester,
  ) async {
    now = deadline.add(const Duration(minutes: 1));
    await openDetail(tester);

    final disabled = tester.widget<AppButton>(button('Absagefrist vorbei'));
    expect(disabled.onPressed, isNull);
    expect(button('Schicht absagen'), findsNothing);
    expect(find.textContaining('Absagen in der App bis'), findsNothing);
    expect(
      find.text('Wenn du nicht kommen kannst, sag Anna Berger Bescheid.'),
      findsOneWidget,
    );

    await tester.tap(button('Anrufen').last);
    await tester.pumpAndSettle();

    expect(opened, [Uri(scheme: 'tel', path: '+436605550100')]);
  });

  testWidgets('offers nothing to drop out of once the shift has started', (
    tester,
  ) async {
    now = DateTime(2026, 10, 17, 18, 30);
    await openDetail(tester);

    expect(button('Absagefrist vorbei'), findsNothing);
    expect(button('Schicht absagen'), findsNothing);
  });

  testWidgets('says who cancelled when the agency did', (tester) async {
    final removed = workerShift(
      assignmentStatus: 'CANCELLED',
      cancelledBy: 'AGENCY',
    );
    backend.on('GET /worker/shifts', (_) => json(page([removed])));
    backend.on(detailRoute, (_) => json(removed));
    await openDetail(tester);

    expect(
      find.text('Donau Personal hat dich aus dieser Schicht genommen.'),
      findsOneWidget,
    );
  });

  testWidgets('says when the agency called off the whole shift', (
    tester,
  ) async {
    final calledOff = workerShift(
      status: 'CANCELLED',
      assignmentStatus: 'CANCELLED',
      cancelledBy: 'AGENCY',
    );
    backend.on('GET /worker/shifts', (_) => json(page([calledOff])));
    backend.on(detailRoute, (_) => json(calledOff));
    await openDetail(tester);

    expect(
      find.text('Donau Personal hat diese Schicht abgesagt.'),
      findsOneWidget,
    );
  });
}
