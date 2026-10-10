import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_backend.dart';

void main() {
  late FakeBackend backend;
  late Map<String, String> stored;

  setUp(() {
    backend = FakeBackend();
    stored = fakeTokenStorage(suffix: '1');
    backend.on('POST /auth/logout', (_) => noContent());
  });

  group('waiting for approval', () {
    setUp(() => backend.on('GET /me', (_) => json(currentUser('PENDING'))));

    testWidgets('shows the status, the agency and the account', (tester) async {
      await pumpApp(tester, backend);

      expect(find.text('Deine Registrierung wird geprüft'), findsOneWidget);
      expect(find.textContaining('Donau Personal prüft'), findsOneWidget);
      expect(find.text('Wartet auf Freigabe'), findsOneWidget);
      expect(find.text('Donau Personal'), findsOneWidget);
      expect(find.text('lena.hofer@example.com'), findsOneWidget);
      expect(find.text('Schichten'), findsNothing);
    });

    testWidgets('opens the shifts once the agency has approved', (
      tester,
    ) async {
      await pumpApp(tester, backend);
      backend.on('GET /me', (_) => json(currentUser('ACTIVE')));

      await tester.tap(find.text('Status aktualisieren'));
      await tester.pumpAndSettle();

      expect(find.text('Aktuell keine offenen Schichten'), findsOneWidget);
      expect(find.text('Deine Registrierung wird geprüft'), findsNothing);
      expect(
        find.text('Dein Konto wartet noch auf die Freigabe.'),
        findsNothing,
      );
    });

    testWidgets('says so when nothing has changed yet', (tester) async {
      await pumpApp(tester, backend);

      await tester.tap(find.text('Status aktualisieren'));
      await tester.pumpAndSettle();

      expect(
        find.text('Dein Konto wartet noch auf die Freigabe.'),
        findsOneWidget,
      );
      expect(find.text('Deine Registrierung wird geprüft'), findsOneWidget);
      expect(backend.sent('GET /me'), hasLength(2));
    });

    testWidgets('moves on to "not active" after a rejection', (tester) async {
      await pumpApp(tester, backend);
      backend.on('GET /me', (_) => json(currentUser('INACTIVE')));

      await tester.tap(find.text('Status aktualisieren'));
      await tester.pumpAndSettle();

      expect(find.text('Dein Konto ist nicht aktiv'), findsOneWidget);
    });

    testWidgets('stays put when the status cannot be loaded', (tester) async {
      await pumpApp(tester, backend);
      backend.on('GET /me', offline);

      await tester.tap(find.text('Status aktualisieren'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Keine Verbindung zum Server'),
        findsOneWidget,
      );
      expect(find.text('Deine Registrierung wird geprüft'), findsOneWidget);
      expect(stored, isNotEmpty);
    });

    testWidgets('logs out', (tester) async {
      await pumpApp(tester, backend);

      await tester.tap(find.text('Abmelden'));
      await tester.pumpAndSettle();

      expect(find.text('Willkommen zurück'), findsOneWidget);
      expect(stored, isEmpty);
      expect(backend.sent('POST /auth/logout').single.data, {
        'refreshToken': 'refresh-1',
      });
    });
  });

  group('not active', () {
    setUp(() => backend.on('GET /me', (_) => json(currentUser('INACTIVE'))));

    testWidgets('explains it and names the agency, never the shifts', (
      tester,
    ) async {
      await pumpApp(tester, backend);

      expect(find.text('Dein Konto ist nicht aktiv'), findsOneWidget);
      expect(
        find.text('Wende dich bitte direkt an Donau Personal.'),
        findsOneWidget,
      );
      expect(find.text('Schichten'), findsNothing);
      expect(find.text('Aktuell keine offenen Schichten'), findsNothing);
    });

    testWidgets('logs out', (tester) async {
      await pumpApp(tester, backend);

      await tester.tap(find.text('Abmelden'));
      await tester.pumpAndSettle();

      expect(find.text('Willkommen zurück'), findsOneWidget);
      expect(stored, isEmpty);
    });
  });
}
