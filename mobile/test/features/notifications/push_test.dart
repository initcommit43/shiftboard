import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftboard/core/platform/url_opener.dart';
import 'package:shiftboard/core/push/push_messaging.dart';
import 'package:shiftboard/core/widgets/app_button.dart';
import 'package:shiftboard/features/shifts/presentation/shift_card.dart';
import 'package:shiftboard/features/shifts/presentation/shift_detail_screen.dart';

import '../../support/fake_backend.dart';

const shiftId = '0199c0de-0000-7000-8000-0000000000c1';

class FakePush implements PushMessaging {
  bool permitted = true;
  final receivedController = StreamController<PushData>.broadcast();
  final openedController = StreamController<PushData>.broadcast();
  final refreshController = StreamController<String>.broadcast();
  int deleted = 0;

  @override
  Future<bool> requestPermission() async => permitted;

  @override
  Future<String?> token() async => 'device-token-1';

  @override
  Stream<String> get tokenRefresh => refreshController.stream;

  @override
  Future<void> deleteToken() async => deleted++;

  @override
  Stream<PushData> get received => receivedController.stream;

  @override
  Stream<PushData> get opened => openedController.stream;
}

Finder button(String label) => find.widgetWithText(AppButton, label);

void main() {
  late FakeBackend backend;
  late FakePush push;

  setUp(() {
    backend = FakeBackend();
    push = FakePush();
    fakeTokenStorage(suffix: '1');
    backend.on('GET /me', (_) => json(currentUser('ACTIVE')));
    backend.on('POST /worker/push-tokens', (_) => noContent());
    backend.on('DELETE /worker/push-tokens/device-token-1', (_) => noContent());
    backend.on('POST /auth/logout', (_) => noContent());
    backend.on(
      'GET /worker/notification-settings',
      (_) => json({'newShiftsPaused': false}),
    );
  });

  Future<void> start(WidgetTester tester) => pumpApp(
    tester,
    backend,
    overrides: [pushMessagingProvider.overrideWithValue(push)],
  );

  testWidgets('registers the device once signed in and removes it on logout', (
    tester,
  ) async {
    await start(tester);

    final registered = backend.sent('POST /worker/push-tokens');
    expect(registered, hasLength(1));
    expect(registered.single.data, {
      'token': 'device-token-1',
      'platform': 'ANDROID',
    });

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await scrollToAndTap(tester, button('Abmelden'));
    await tester.pumpAndSettle();

    expect(
      backend.sent('DELETE /worker/push-tokens/device-token-1'),
      hasLength(1),
    );
    expect(push.deleted, 1);
  });

  testWidgets('registers nothing when the worker declines', (tester) async {
    push.permitted = false;
    await start(tester);

    expect(backend.sent('POST /worker/push-tokens'), isEmpty);
  });

  testWidgets('a new token is registered too', (tester) async {
    await start(tester);

    push.refreshController.add('device-token-2');
    await tester.pumpAndSettle();

    expect(
      backend.sent('POST /worker/push-tokens').last.data,
      containsPair('token', 'device-token-2'),
    );
  });

  testWidgets('an arriving push loads what changed', (tester) async {
    await start(tester);
    final before = backend.sent('GET /worker/shifts').length;

    push.receivedController.add({
      'type': 'SHIFT_PUBLISHED',
      'shiftId': shiftId,
    });
    await tester.pumpAndSettle();

    expect(backend.sent('GET /worker/shifts').length, before + 1);
  });

  testWidgets('a tapped push opens its shift or the chat', (tester) async {
    backend.on('GET /worker/shifts/$shiftId', (_) => json(workerShift()));
    await start(tester);

    push.openedController.add({'type': 'CLAIM_CONFIRMED', 'shiftId': shiftId});
    await tester.pumpAndSettle();
    expect(
      find.text('Industriezeile 40, 4020 Linz', findRichText: true),
      findsNothing,
    );
    expect(find.textContaining('Industriezeile 40'), findsOneWidget);

    push.openedController.add({'type': 'MESSAGE'});
    await tester.pumpAndSettle();
    expect(find.text('Noch keine Nachrichten'), findsWidgets);
  });

  testWidgets('pausing new shifts is saved', (tester) async {
    backend.on(
      'PUT /worker/notification-settings',
      (options) => json(options.data),
    );
    await start(tester);
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Lena Hofer'), findsOneWidget);
    expect(find.text('Neue Schichten pausieren'), findsOneWidget);
    backend.on(
      'GET /worker/notification-settings',
      (_) => json({'newShiftsPaused': true}),
    );
    await tester.tap(find.text('Neue Schichten pausieren'));
    await tester.pumpAndSettle();

    expect(backend.sent('PUT /worker/notification-settings').single.data, {
      'newShiftsPaused': true,
    });
  });

  testWidgets('says when this build has no push', (tester) async {
    await pumpApp(tester, backend);
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Push-Benachrichtigungen sind in dieser Version der App noch nicht '
        'eingerichtet.',
      ),
      findsOneWidget,
    );
  });

  group('WhatsApp contact', () {
    final opened = <Uri>[];

    Future<void> openDetail(WidgetTester tester) async {
      backend.on('GET /worker/shifts', (_) => json(page([workerShift()])));
      backend.on('GET /worker/shifts/$shiftId', (_) => json(workerShift()));
      await pumpApp(
        tester,
        backend,
        overrides: [
          urlOpenerProvider.overrideWithValue((uri) async {
            opened.add(uri);
            return true;
          }),
        ],
      );
      await tester.tap(find.byType(ShiftCard));
      await tester.pumpAndSettle();
    }

    setUp(opened.clear);

    testWidgets('opens WhatsApp when the agency switched it on', (
      tester,
    ) async {
      backend.on(
        'GET /me',
        (_) => json(currentUser('ACTIVE', contactButton: true)),
      );
      await openDetail(tester);

      await tester.scrollUntilVisible(
        button('WhatsApp'),
        200,
        scrollable: find
            .descendant(
              of: find.byType(ShiftDetailScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      // Clear of the claim bar pinned at the bottom.
      await tester.drag(
        find
            .descendant(
              of: find.byType(ShiftDetailScreen),
              matching: find.byType(Scrollable),
            )
            .first,
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      await tester.tap(button('WhatsApp'));
      await tester.pumpAndSettle();

      expect(opened, [Uri.https('wa.me', '/436605550100')]);
    });

    testWidgets('is hidden otherwise', (tester) async {
      await openDetail(tester);

      expect(button('WhatsApp'), findsNothing);
    });
  });
}
