import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftboard/core/platform/url_opener.dart';
import 'package:shiftboard/features/shifts/presentation/shift_card.dart';

import '../../support/fake_backend.dart';

const shiftId = '0199c0de-0000-7000-8000-0000000000c1';
const detailRoute = 'GET /worker/shifts/$shiftId';

void main() {
  late FakeBackend backend;
  late List<Uri> opened;
  late bool openSucceeds;

  setUp(() {
    backend = FakeBackend();
    fakeTokenStorage(suffix: '1');
    opened = [];
    openSucceeds = true;
    backend.on('GET /me', (_) => json(currentUser('ACTIVE')));
    backend.on('GET /worker/shifts', (_) => json(page([workerShift()])));
    backend.on(
      detailRoute,
      (_) => json(
        workerShift(
          description: 'Sicherheitsschuhe mitbringen. Treffpunkt Tor 3.',
          qualifications: ['Staplerschein'],
        ),
      ),
    );
  });

  Future<void> openDetail(WidgetTester tester) async {
    await pumpApp(
      tester,
      backend,
      overrides: [
        urlOpenerProvider.overrideWithValue((uri) async {
          opened.add(uri);
          return openSucceeds;
        }),
      ],
    );
    await tester.tap(find.byType(ShiftCard));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the card facts plus description, requirements and '
      'contact', (tester) async {
    await openDetail(tester);

    expect(backend.sent(detailRoute), hasLength(1));
    expect(find.byType(ShiftCard), findsNothing);
    expect(find.text('Lagerunterstützung'), findsOneWidget);
    expect(find.text('Nordlicht Logistik'), findsOneWidget);
    expect(find.text('Sa., 17. Okt. · 18:00 – 23:30'), findsOneWidget);
    expect(
      find.text('Zentrallager Linz\nIndustriezeile 40, 4020 Linz'),
      findsOneWidget,
    );
    expect(find.text('79,75 €'), findsOneWidget);
    expect(find.text('3 von 5 Plätzen frei'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Anrufen'), 200);
    expect(
      find.text('Sicherheitsschuhe mitbringen. Treffpunkt Tor 3.'),
      findsOneWidget,
    );
    expect(find.text('Staplerschein'), findsOneWidget);
    expect(find.text('Anna Berger'), findsOneWidget);
    expect(find.text('+43 660 5550100'), findsOneWidget);
  });

  testWidgets('says when a shift asks for nothing and has no phone', (
    tester,
  ) async {
    backend.on(detailRoute, (_) => json(workerShift(contactPhone: null)));

    await openDetail(tester);
    await tester.scrollUntilVisible(find.text('Anna Berger'), 200);

    expect(find.text('Keine besonderen Anforderungen'), findsOneWidget);
    expect(find.text('Beschreibung'), findsNothing);
    expect(find.text('Anrufen'), findsNothing);
  });

  testWidgets('opens the address in a maps app', (tester) async {
    await openDetail(tester);

    await tester.tap(find.text('In Karten öffnen'));
    await tester.pumpAndSettle();

    final uri = opened.single;
    expect(uri.host, 'www.google.com');
    expect(uri.queryParameters['query'], 'Industriezeile 40, 4020 Linz');
  });

  testWidgets(
    'opens Apple Maps on iOS',
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    (tester) async {
      await openDetail(tester);
      await tester.tap(find.text('In Karten öffnen'));
      await tester.pumpAndSettle();

      expect(opened.single.host, 'maps.apple.com');
      expect(
        opened.single.queryParameters['q'],
        'Industriezeile 40, 4020 Linz',
      );
    },
  );

  testWidgets('calls the contact', (tester) async {
    await openDetail(tester);

    await tester.scrollUntilVisible(find.text('Anrufen'), 200);
    await scrollToAndTap(tester, find.text('Anrufen'));
    await tester.pumpAndSettle();

    expect(opened.single.toString(), 'tel:+436605550100');
  });

  testWidgets('says so when no app opens the link', (tester) async {
    openSucceeds = false;
    await openDetail(tester);

    await tester.tap(find.text('In Karten öffnen'));
    await tester.pumpAndSettle();

    expect(
      find.text('Die Karten-App konnte nicht geöffnet werden.'),
      findsOneWidget,
    );
  });

  testWidgets('shows progress, then an error with retry', (tester) async {
    final answer = Completer<ResponseBody>();
    backend.on(detailRoute, (_) => answer.future);
    await pumpApp(tester, backend);

    await tester.tap(find.byType(ShiftCard));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    answer.completeError(
      DioException.connectionError(
        requestOptions: RequestOptions(),
        reason: 'connection refused',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Schicht konnte nicht geladen werden'), findsOneWidget);

    backend.on(detailRoute, (_) => json(workerShift()));
    await tester.tap(find.text('Erneut versuchen'));
    await tester.pumpAndSettle();

    expect(find.text('In Karten öffnen'), findsOneWidget);
  });

  testWidgets('says when the shift no longer exists', (tester) async {
    backend.on(detailRoute, (_) => problem(404, 'shift_not_found'));

    await openDetail(tester);

    expect(find.text('Diese Schicht gibt es nicht mehr'), findsOneWidget);
    expect(find.text('Erneut versuchen'), findsNothing);
  });

  testWidgets('the back button returns to the list', (tester) async {
    await openDetail(tester);

    await tester.tap(find.byTooltip('Zurück'));
    await tester.pumpAndSettle();

    expect(find.byType(ShiftCard), findsOneWidget);
  });
}
