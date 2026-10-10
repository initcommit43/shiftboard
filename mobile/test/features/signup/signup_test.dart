import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_backend.dart';

const _link = 'shiftboard://join/DONAU24';

void main() {
  late FakeBackend backend;
  late Map<String, String> stored;

  setUp(() {
    backend = FakeBackend();
    stored = fakeTokenStorage();
    backend.on(
      'GET /signup/DONAU24',
      (_) => json({'agencyName': 'Donau Personal'}),
    );
  });

  /// Types [date] into the date picker, as it is faster than the calendar.
  Future<void> pickDateOfBirth(WidgetTester tester, String date) async {
    await scrollToAndTap(tester, field('Geburtsdatum'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(DatePickerDialog),
        matching: find.byType(TextField),
      ),
      date,
    );
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  }

  Future<void> fillIn(
    WidgetTester tester, {
    String email = 'lena.hofer@example.com',
    String phone = '+43 660 5550101',
    String password = 'sonnenblume24',
  }) async {
    await tester.enterText(field('Vorname'), 'Lena');
    await tester.enterText(field('Nachname'), ' Hofer ');
    await pickDateOfBirth(tester, '14.03.1996');
    await tester.enterText(field('E-Mail'), email);
    await tester.enterText(field('Telefon'), phone);
    await tester.enterText(field('Passwort'), password);
  }

  Future<void> submit(WidgetTester tester) async {
    await scrollToAndTap(tester, find.text('Registrieren'));
    await tester.pumpAndSettle();
  }

  group('getting to the form', () {
    testWidgets('opens it from the invitation link that started the app', (
      tester,
    ) async {
      await pumpApp(tester, backend, link: _link);

      expect(find.text('Bei Donau Personal registrieren'), findsOneWidget);
      expect(find.text('DP'), findsOneWidget);
    });

    testWidgets('opens it from an invitation link while the app is running', (
      tester,
    ) async {
      await pumpApp(tester, backend);
      expect(find.text('Willkommen zurück'), findsOneWidget);

      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/navigation',
        const JSONMethodCodec().encodeMethodCall(
          const MethodCall('pushRouteInformation', {'location': _link}),
        ),
        (_) {},
      );
      await tester.pumpAndSettle();

      expect(find.text('Bei Donau Personal registrieren'), findsOneWidget);
    });

    testWidgets('opens it from a pasted link on the way from the login', (
      tester,
    ) async {
      await pumpApp(tester, backend);

      await tester.tap(find.textContaining('Registrieren'));
      await tester.pumpAndSettle();
      expect(find.text('Einladung einlösen'), findsOneWidget);

      await tester.enterText(field('Einladungslink oder Code'), ' $_link ');
      await tester.tap(find.text('Weiter'));
      await tester.pumpAndSettle();

      expect(find.text('Bei Donau Personal registrieren'), findsOneWidget);
    });

    testWidgets('rejects pasted text without a code', (tester) async {
      await pumpApp(tester, backend);
      await tester.tap(find.textContaining('Registrieren'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Weiter'));
      await tester.pumpAndSettle();
      expect(find.text('Bitte fülle dieses Feld aus.'), findsOneWidget);

      await tester.enterText(
        field('Einladungslink oder Code'),
        'https://example.com/hallo',
      );
      await tester.tap(find.text('Weiter'));
      await tester.pumpAndSettle();

      expect(
        find.text('Das ist kein gültiger Einladungslink oder Code.'),
        findsOneWidget,
      );
      expect(backend.requests, isEmpty);
    });

    testWidgets('says that an unknown invitation is not valid', (tester) async {
      backend.on('GET /signup/ALT', (_) => problem(404, 'signup_code_unknown'));

      await pumpApp(tester, backend, link: 'shiftboard://join/ALT');

      expect(
        find.text('Dieser Einladungslink ist nicht gültig'),
        findsOneWidget,
      );
      expect(find.text('Vorname'), findsNothing);

      await tester.tap(find.text('Zur Anmeldung'));
      await tester.pumpAndSettle();
      expect(find.text('Willkommen zurück'), findsOneWidget);
    });

    testWidgets('offers a retry when the invitation cannot be loaded', (
      tester,
    ) async {
      final lookup = backend.sent('GET /signup/DONAU24');
      backend.on('GET /signup/NEU', offline);
      await pumpApp(tester, backend, link: 'shiftboard://join/NEU');

      expect(
        find.text('Einladung konnte nicht geladen werden'),
        findsOneWidget,
      );
      expect(find.text('Dieser Einladungslink ist nicht gültig'), findsNothing);
      expect(lookup, isEmpty);

      backend.on(
        'GET /signup/NEU',
        (_) => json({'agencyName': 'Donau Personal'}),
      );
      await tester.tap(find.text('Erneut versuchen'));
      await tester.pumpAndSettle();

      expect(find.text('Bei Donau Personal registrieren'), findsOneWidget);
    });
  });

  group('the form', () {
    testWidgets('marks every empty field and sends nothing', (tester) async {
      await pumpApp(tester, backend, link: _link);

      await submit(tester);

      expect(find.text('Bitte fülle dieses Feld aus.'), findsNWidgets(6));
      expect(backend.sent('POST /signup/DONAU24'), isEmpty);
    });

    testWidgets('picks the date of birth in the date picker', (tester) async {
      await pumpApp(tester, backend, link: _link);
      expect(
        find.descendant(
          of: field('Geburtsdatum'),
          matching: find.text('TT.MM.JJJJ'),
        ),
        findsOneWidget,
      );

      await scrollToAndTap(tester, field('Geburtsdatum'));
      await tester.pumpAndSettle();

      // Opens on the years, with no day after yesterday to choose.
      final picker = tester.widget<DatePickerDialog>(
        find.byType(DatePickerDialog),
      );
      expect(picker.initialCalendarMode, DatePickerMode.year);
      expect(
        picker.lastDate.isBefore(DateUtils.dateOnly(DateTime.now())),
        isTrue,
      );
      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(
              find.descendant(
                of: field('Geburtsdatum'),
                matching: find.byType(TextField),
              ),
            )
            .controller!
            .text,
        isEmpty,
      );

      await pickDateOfBirth(tester, '14.03.1996');

      expect(
        find.descendant(
          of: field('Geburtsdatum'),
          matching: find.text('14.03.1996'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('checks email, phone and password length', (tester) async {
      await pumpApp(tester, backend, link: _link);
      await fillIn(
        tester,
        email: 'lena.hofer',
        phone: '0660 555',
        password: 'kurz',
      );

      await submit(tester);

      expect(
        find.text('Bitte gib eine gültige E-Mail-Adresse ein.'),
        findsOneWidget,
      );
      expect(
        find.text('Bitte gib eine gültige Telefonnummer ein.'),
        findsOneWidget,
      );
      expect(
        find.text('Das Passwort muss mindestens 8 Zeichen lang sein.'),
        findsOneWidget,
      );
      expect(backend.sent('POST /signup/DONAU24'), isEmpty);
    });

    testWidgets('shows an already registered email at the email field', (
      tester,
    ) async {
      backend.on(
        'POST /signup/DONAU24',
        (_) => problem(409, 'email_already_registered'),
      );
      await pumpApp(tester, backend, link: _link);
      await fillIn(tester);

      await submit(tester);

      expect(
        find.descendant(
          of: field('E-Mail'),
          matching: find.text('Diese E-Mail ist bereits registriert.'),
        ),
        findsOneWidget,
      );
      expect(find.text('Bei Donau Personal registrieren'), findsOneWidget);
      expect(stored, isEmpty);

      // Typing a different address clears the error.
      await tester.enterText(field('E-Mail'), 'l.hofer@example.com');
      await tester.pumpAndSettle();
      expect(find.text('Diese E-Mail ist bereits registriert.'), findsNothing);
    });

    testWidgets('shows fields rejected by the server at those fields', (
      tester,
    ) async {
      backend.on(
        'POST /signup/DONAU24',
        (_) => problem(
          400,
          'validation_failed',
          fieldErrors: {
            'phone': 'invalid_format',
            'email': 'invalid_format',
            'dateOfBirth': 'out_of_range',
          },
        ),
      );
      await pumpApp(tester, backend, link: _link);
      await fillIn(tester);

      await submit(tester);

      expect(
        find.descendant(
          of: field('Telefon'),
          matching: find.text('Bitte gib eine gültige Telefonnummer ein.'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: field('E-Mail'),
          matching: find.text('Bitte gib eine gültige E-Mail-Adresse ein.'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: field('Geburtsdatum'),
          matching: find.text('Bitte gib ein gültiges Geburtsdatum ein.'),
        ),
        findsOneWidget,
      );

      // Picking a different date clears the error.
      await pickDateOfBirth(tester, '15.03.1996');
      expect(
        find.text('Bitte gib ein gültiges Geburtsdatum ein.'),
        findsNothing,
      );
    });

    testWidgets('gives rejected fields a message for the reason', (
      tester,
    ) async {
      backend.on(
        'POST /signup/DONAU24',
        (_) => problem(
          400,
          'validation_failed',
          fieldErrors: {
            'firstName': 'required',
            'lastName': 'something_new',
            'password': 'invalid_length',
          },
        ),
      );
      await pumpApp(tester, backend, link: _link);
      await fillIn(tester);

      await submit(tester);

      Finder at(String label, String message) =>
          find.descendant(of: field(label), matching: find.text(message));
      expect(at('Vorname', 'Bitte fülle dieses Feld aus.'), findsOneWidget);
      expect(at('Nachname', 'Bitte prüfe diese Angabe.'), findsOneWidget);
      expect(
        at('Passwort', 'Das Passwort muss mindestens 8 Zeichen lang sein.'),
        findsOneWidget,
      );
      expect(find.text('Bitte prüfe deine Angaben.'), findsNothing);
    });

    testWidgets('shows a rejection without fields above the form', (
      tester,
    ) async {
      backend.on(
        'POST /signup/DONAU24',
        (_) => problem(400, 'validation_failed'),
      );
      await pumpApp(tester, backend, link: _link);
      await fillIn(tester);

      await submit(tester);

      expect(find.text('Bitte prüfe deine Angaben.'), findsOneWidget);
    });

    testWidgets('shows other failures above the form', (tester) async {
      backend.on('POST /signup/DONAU24', offline);
      await pumpApp(tester, backend, link: _link);
      await fillIn(tester);

      await submit(tester);

      expect(
        find.textContaining('Keine Verbindung zum Server'),
        findsOneWidget,
      );
      expect(find.text('Bei Donau Personal registrieren'), findsOneWidget);
    });

    testWidgets('switches to the invalid screen when the code was withdrawn', (
      tester,
    ) async {
      backend.on(
        'POST /signup/DONAU24',
        (_) => problem(404, 'signup_code_unknown'),
      );
      await pumpApp(tester, backend, link: _link);
      await fillIn(tester);
      backend.on(
        'GET /signup/DONAU24',
        (_) => problem(404, 'signup_code_unknown'),
      );

      await submit(tester);

      expect(
        find.text('Dieser Einladungslink ist nicht gültig'),
        findsOneWidget,
      );
    });

    testWidgets('creates the account and waits for approval', (tester) async {
      backend.on('POST /signup/DONAU24', (_) => json(tokenPair(), 201));
      backend.on('GET /me', (_) => json(currentUser('PENDING')));
      await pumpApp(tester, backend, link: _link);
      await fillIn(tester);

      await submit(tester);

      expect(find.text('Deine Registrierung wird geprüft'), findsOneWidget);
      expect(find.text('Wartet auf Freigabe'), findsOneWidget);
      expect(find.text('Aktuell keine offenen Schichten'), findsNothing);
      expect(backend.sent('POST /signup/DONAU24').single.data, {
        'firstName': 'Lena',
        'lastName': 'Hofer',
        'dateOfBirth': '1996-03-14',
        'email': 'lena.hofer@example.com',
        'phone': '+43 660 5550101',
        'password': 'sonnenblume24',
      });
      expect(stored, {
        'access_token': 'access-1',
        'refresh_token': 'refresh-1',
      });
    });

    testWidgets('fits a small screen with large text', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpApp(tester, backend, link: _link);
      await submit(tester);

      expect(find.text('Bitte fülle dieses Feld aus.'), findsNWidgets(6));
      expect(tester.takeException(), isNull);
    });

    testWidgets('leads back to the login', (tester) async {
      await pumpApp(tester, backend, link: _link);

      await scrollToAndTap(tester, find.textContaining('Schon registriert?'));
      await tester.pumpAndSettle();

      expect(find.text('Willkommen zurück'), findsOneWidget);
    });
  });
}
