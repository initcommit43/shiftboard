import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftboard/core/theme/tokens.dart';

import '../../support/fake_backend.dart';

void main() {
  late FakeBackend backend;

  setUp(() => backend = FakeBackend());

  testWidgets('opens the login without a stored session', (tester) async {
    fakeTokenStorage();

    await pumpApp(tester, backend);

    expect(find.text('Willkommen zurück'), findsOneWidget);
    expect(backend.requests, isEmpty);
  });

  const screens = {
    'ACTIVE': 'Aktuell keine offenen Schichten',
    'PENDING': 'Deine Registrierung wird geprüft',
    'INACTIVE': 'Dein Konto ist nicht aktiv',
  };

  for (final MapEntry(key: status, value: title) in screens.entries) {
    testWidgets('restores the session of a worker who is $status', (
      tester,
    ) async {
      fakeTokenStorage(suffix: '1');
      backend.on('GET /me', (_) => json(currentUser(status)));

      await pumpApp(tester, backend);

      expect(find.text(title), findsOneWidget);
      for (final other in screens.values.where((other) => other != title)) {
        expect(find.text(other), findsNothing);
      }
      expect(find.text('Willkommen zurück'), findsNothing);
    });
  }

  testWidgets('shows the brand and a spinner while the session is restored', (
    tester,
  ) async {
    fakeTokenStorage(suffix: '1');
    final answer = Completer<ResponseBody>();
    backend.on('GET /me', (_) => answer.future);

    await pumpApp(tester, backend, settle: false);
    await tester.pump();

    expect(find.text(AppBrand.name), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Willkommen zurück'), findsNothing);

    answer.complete(json(currentUser('ACTIVE')));
    await tester.pumpAndSettle();
    expect(find.text('Aktuell keine offenen Schichten'), findsOneWidget);
  });

  testWidgets('offers a retry and keeps the session when the API is down', (
    tester,
  ) async {
    final stored = fakeTokenStorage(suffix: '1');
    backend.on('GET /me', offline);

    await pumpApp(tester, backend);

    expect(find.text('Keine Verbindung zum Server'), findsOneWidget);
    expect(find.text('Willkommen zurück'), findsNothing);
    expect(stored, containsPair('refresh_token', 'refresh-1'));

    backend.on('GET /me', (_) => json(currentUser('PENDING')));
    await tester.tap(find.text('Erneut versuchen'));
    await tester.pumpAndSettle();

    expect(find.text('Deine Registrierung wird geprüft'), findsOneWidget);
  });

  testWidgets('treats a server error like an unreachable API', (tester) async {
    final stored = fakeTokenStorage(suffix: '1');
    backend.on('GET /me', (_) => problem(503, 'unavailable'));

    await pumpApp(tester, backend);

    expect(find.text('Erneut versuchen'), findsOneWidget);
    expect(stored, isNotEmpty);
  });

  testWidgets('can log out from the start error', (tester) async {
    final stored = fakeTokenStorage(suffix: '1');
    backend.on('GET /me', offline);
    backend.on('POST /auth/logout', offline);
    await pumpApp(tester, backend);

    await tester.tap(find.text('Abmelden'));
    await tester.pumpAndSettle();

    expect(find.text('Willkommen zurück'), findsOneWidget);
    expect(stored, isEmpty);
  });

  testWidgets('renews an expired access token on start', (tester) async {
    final stored = fakeTokenStorage(suffix: '1');
    backend.on(
      'GET /me',
      (request) => request.headers['Authorization'] == 'Bearer access-2'
          ? json(currentUser('ACTIVE'))
          : problem(401, 'unauthenticated'),
    );
    backend.on('POST /auth/refresh', (_) => json(tokenPair('2')));

    await pumpApp(tester, backend);

    expect(find.text('Aktuell keine offenen Schichten'), findsOneWidget);
    expect(stored, {'access_token': 'access-2', 'refresh_token': 'refresh-2'});
  });

  testWidgets('opens the login when the stored session has ended', (
    tester,
  ) async {
    final stored = fakeTokenStorage(suffix: '1');
    backend.on('GET /me', (_) => problem(401, 'unauthenticated'));
    backend.on(
      'POST /auth/refresh',
      (_) => problem(401, 'invalid_refresh_token'),
    );

    await pumpApp(tester, backend);

    expect(find.text('Willkommen zurück'), findsOneWidget);
    expect(stored, isEmpty);
  });
}
