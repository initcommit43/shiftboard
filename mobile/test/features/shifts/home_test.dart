import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftboard/core/widgets/app_tab_bar.dart';

import '../../support/fake_backend.dart';

void main() {
  late FakeBackend backend;
  late Map<String, String> stored;

  setUp(() {
    backend = FakeBackend();
    stored = fakeTokenStorage(suffix: '1');
    backend.on('GET /me', (_) => json(currentUser('ACTIVE')));
  });

  testWidgets('shows the empty shift list of the agency', (tester) async {
    await pumpApp(tester, backend);

    expect(find.text('Aktuell keine offenen Schichten'), findsOneWidget);
    expect(find.textContaining('Sobald Donau Personal'), findsOneWidget);
    expect(find.text('LH'), findsOneWidget);
    expect(find.byType(AppTabItem), findsNWidgets(4));
  });

  testWidgets('the tab labels fit the smallest screen with large text', (
    tester,
  ) async {
    // Widths are only real with the real font; the test font is much wider.
    final inter = FontLoader('Inter');
    for (final weight in ['Regular', 'Medium']) {
      final bytes = File('assets/fonts/inter/Inter-$weight.ttf')
          .readAsBytesSync();
      inter.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await inter.load();
    // 375 wide is the narrowest screen the design supports.
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpApp(tester, backend);

    // The paragraphs of the labels; the icons are paragraphs too.
    final labels = find.descendant(
      of: find.descendant(
        of: find.byType(AppTabItem),
        matching: find.byType(Text),
      ),
      matching: find.byType(RichText),
    );
    expect(labels, findsNWidgets(4));
    for (final label in tester.renderObjectList<RenderParagraph>(labels)) {
      expect(
        label.didExceedMaxLines,
        isFalse,
        reason: '"${label.text.toPlainText()}" is cut off',
      );
    }
  });

  testWidgets('shows placeholders while refreshing', (tester) async {
    await pumpApp(tester, backend);
    final answer = Completer<ResponseBody>();
    backend.on('GET /worker/shifts', (_) => answer.future);

    await tester.tap(find.text('Aktualisieren'));
    await tester.pump();

    expect(find.bySemanticsLabel('Schichten werden geladen …'), findsOneWidget);
    expect(find.text('Aktuell keine offenen Schichten'), findsNothing);

    answer.complete(json(page([])));
    await tester.pumpAndSettle();
    expect(find.text('Aktuell keine offenen Schichten'), findsOneWidget);
  });

  testWidgets('shows an error with retry when refreshing fails', (
    tester,
  ) async {
    await pumpApp(tester, backend);
    backend.on('GET /worker/shifts', offline);

    await tester.tap(find.text('Aktualisieren'));
    await tester.pumpAndSettle();

    expect(find.text('Schichten konnten nicht geladen werden'), findsOneWidget);
    expect(stored, isNotEmpty);

    backend.on('GET /worker/shifts', (_) => json(page([])));
    await tester.tap(find.text('Erneut versuchen'));
    await tester.pumpAndSettle();

    expect(find.text('Aktuell keine offenen Schichten'), findsOneWidget);
  });

  testWidgets('leaves the shifts when the worker was deactivated', (
    tester,
  ) async {
    await pumpApp(tester, backend);
    backend.on('GET /me', (_) => json(currentUser('INACTIVE')));
    backend.on('GET /worker/shifts', (_) => problem(403, 'worker_not_active'));

    await tester.tap(find.text('Aktualisieren'));
    await tester.pumpAndSettle();

    expect(find.text('Dein Konto ist nicht aktiv'), findsOneWidget);
    expect(find.text('Aktuell keine offenen Schichten'), findsNothing);
  });

  testWidgets('the avatar shows the account and logs out', (tester) async {
    backend.on('POST /auth/logout', (_) => noContent());
    await pumpApp(tester, backend);

    await tester.tap(find.byTooltip('Konto'));
    await tester.pumpAndSettle();

    expect(find.text('Lena Hofer'), findsOneWidget);
    expect(find.text('lena.hofer@example.com'), findsOneWidget);
    expect(find.text('Donau Personal'), findsOneWidget);

    await tester.tap(find.text('Abmelden'));
    await tester.pumpAndSettle();

    expect(find.text('Willkommen zurück'), findsOneWidget);
    expect(stored, isEmpty);
    expect(backend.sent('POST /auth/logout').single.data, {
      'refreshToken': 'refresh-1',
    });
    expect(
      backend.sent('POST /auth/logout').single.headers,
      isNot(contains('Authorization')),
    );
  });

  testWidgets('logs out on this device even without a connection', (
    tester,
  ) async {
    backend.on('POST /auth/logout', offline);
    await pumpApp(tester, backend);

    await tester.tap(find.byTooltip('Konto'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abmelden'));
    await tester.pumpAndSettle();

    expect(find.text('Willkommen zurück'), findsOneWidget);
    expect(stored, isEmpty);
  });

  testWidgets('returns to the login when the session ends on the server', (
    tester,
  ) async {
    await pumpApp(tester, backend);
    backend.on('GET /worker/shifts', (_) => problem(401, 'unauthenticated'));
    backend.on(
      'POST /auth/refresh',
      (_) => problem(401, 'invalid_refresh_token'),
    );

    await tester.tap(find.text('Aktualisieren'));
    await tester.pumpAndSettle();

    expect(find.text('Willkommen zurück'), findsOneWidget);
    expect(stored, isEmpty);
  });
}
