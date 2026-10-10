import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_backend.dart';

void main() {
  late FakeBackend backend;
  late Map<String, String> stored;

  setUp(() {
    backend = FakeBackend();
    stored = fakeTokenStorage();
  });

  Future<void> logIn(WidgetTester tester) async {
    await tester.enterText(field('E-Mail'), ' lena.hofer@example.com ');
    await tester.enterText(field('Passwort'), 'sonnenblume24');
    await scrollToAndTap(tester, find.text('Anmelden'));
    // Lets the request reach the backend.
    await tester.pump(const Duration(milliseconds: 10));
  }

  const screens = {
    'ACTIVE': 'Aktuell keine offenen Schichten',
    'PENDING': 'Deine Registrierung wird geprüft',
    'INACTIVE': 'Dein Konto ist nicht aktiv',
  };

  for (final MapEntry(key: status, value: title) in screens.entries) {
    testWidgets('logs in and opens the screen of a worker who is $status', (
      tester,
    ) async {
      backend.on('POST /auth/login', (_) => json(tokenPair()));
      backend.on('GET /me', (_) => json(currentUser(status)));
      await pumpApp(tester, backend);
      expect(find.text('Willkommen zurück'), findsOneWidget);

      await logIn(tester);
      await tester.pumpAndSettle();

      expect(find.text(title), findsOneWidget);
      expect(find.text('Willkommen zurück'), findsNothing);
      expect(backend.sent('POST /auth/login').single.data, {
        'email': 'lena.hofer@example.com',
        'password': 'sonnenblume24',
        'client': 'WORKER_APP',
      });
      expect(
        backend.sent('GET /me').single.headers['Authorization'],
        'Bearer access-1',
      );
      expect(stored, {
        'access_token': 'access-1',
        'refresh_token': 'refresh-1',
      });
    });
  }

  for (final code in ['invalid_credentials', 'wrong_client']) {
    testWidgets('shows the same generic error for $code', (tester) async {
      backend.on(
        'POST /auth/login',
        (_) => problem(code == 'wrong_client' ? 403 : 401, code),
      );
      await pumpApp(tester, backend);

      await logIn(tester);
      await tester.pumpAndSettle();

      expect(find.text('E-Mail oder Passwort ist falsch.'), findsOneWidget);
      expect(find.text('Anmelden'), findsOneWidget);
      expect(stored, isEmpty);
      // The form keeps what was typed.
      expect(find.text(' lena.hofer@example.com '), findsOneWidget);
    });
  }

  testWidgets('says so when there were too many attempts', (tester) async {
    backend.on('POST /auth/login', (_) => problem(429, 'too_many_attempts'));
    await pumpApp(tester, backend);

    await logIn(tester);
    await tester.pumpAndSettle();

    expect(find.textContaining('Zu viele Anmeldeversuche'), findsOneWidget);
    expect(find.text('E-Mail oder Passwort ist falsch.'), findsNothing);
  });

  testWidgets('says so when the server cannot be reached', (tester) async {
    backend.on('POST /auth/login', offline);
    await pumpApp(tester, backend);

    await logIn(tester);
    await tester.pumpAndSettle();

    expect(find.textContaining('Keine Verbindung zum Server'), findsOneWidget);
  });

  testWidgets('falls back to a generic message for unknown errors', (
    tester,
  ) async {
    backend.on('POST /auth/login', (_) => problem(500, 'something_new'));
    await pumpApp(tester, backend);

    await logIn(tester);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Das hat leider nicht geklappt'),
      findsOneWidget,
    );
  });

  testWidgets('shows progress and blocks the form while logging in', (
    tester,
  ) async {
    final answer = Completer<ResponseBody>();
    backend.on('POST /auth/login', (_) => answer.future);
    backend.on('GET /me', (_) => json(currentUser('ACTIVE')));
    await pumpApp(tester, backend);

    await logIn(tester);

    expect(find.text('Wird angemeldet …'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.text('Wird angemeldet …'));
    await tester.pump();
    expect(backend.sent('POST /auth/login'), hasLength(1));

    answer.complete(json(tokenPair()));
    await tester.pumpAndSettle();
    expect(find.text('Aktuell keine offenen Schichten'), findsOneWidget);
  });

  testWidgets('asks for both fields before sending anything', (tester) async {
    await pumpApp(tester, backend);

    await tester.tap(find.text('Anmelden'));
    await tester.pumpAndSettle();

    expect(find.text('Bitte fülle dieses Feld aus.'), findsNWidgets(2));
    expect(backend.requests, isEmpty);
  });

  testWidgets('can show the password', (tester) async {
    await pumpApp(tester, backend);
    await tester.enterText(field('Passwort'), 'sonnenblume24');
    EditableText password() => tester.widget(
      find.descendant(
        of: field('Passwort'),
        matching: find.byType(EditableText),
      ),
    );
    expect(password().obscureText, isTrue);

    await tester.tap(find.byTooltip('Passwort anzeigen'));
    await tester.pump();

    expect(password().obscureText, isFalse);
    expect(find.byTooltip('Passwort verbergen'), findsOneWidget);
  });

  testWidgets('fits a small screen with large text', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    backend.on('POST /auth/login', (_) => problem(401, 'invalid_credentials'));
    await pumpApp(tester, backend);

    await logIn(tester);
    await tester.pumpAndSettle();

    expect(find.text('E-Mail oder Passwort ist falsch.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('follows the device language for supported locales', (
    tester,
  ) async {
    await pumpApp(tester, backend, locale: const Locale('en', 'US'));

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });

  testWidgets('falls back to German for unsupported locales', (tester) async {
    await pumpApp(tester, backend, locale: const Locale('fr', 'FR'));

    expect(find.text('Willkommen zurück'), findsOneWidget);
  });
}
