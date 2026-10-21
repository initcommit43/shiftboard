import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What a push carries for the app: its type and, if it is about one, the
/// shift. The app loads the current state from the API either way.
typedef PushData = Map<String, String>;

/// The device's push channel. Without a Firebase project it does nothing.
abstract interface class PushMessaging {
  /// Asks the worker for permission where the platform needs it; false when
  /// they declined or push is not available.
  Future<bool> requestPermission();

  Future<String?> token();

  Stream<String> get tokenRefresh;

  Future<void> deleteToken();

  /// Pushes that arrive while the app is open.
  Stream<PushData> get received;

  /// Pushes the worker tapped to open the app, including the one that
  /// started it.
  Stream<PushData> get opened;
}

/// Set by `main` once Firebase is set up for this build.
final pushMessagingProvider = Provider<PushMessaging>(
  (ref) => const DisabledPushMessaging(),
);

class DisabledPushMessaging implements PushMessaging {
  const DisabledPushMessaging();

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<String?> token() async => null;

  @override
  Stream<String> get tokenRefresh => const Stream.empty();

  @override
  Future<void> deleteToken() async {}

  @override
  Stream<PushData> get received => const Stream.empty();

  @override
  Stream<PushData> get opened => const Stream.empty();
}

/// Uses the FCM registration token, which the backend sends to through the
/// HTTP v1 API (ADR 0024). firebase_messaging 17 deprecates it in favor of
/// installation ids for direct send; moving there is a change on both sides.
class FirebasePushMessaging implements PushMessaging {
  FirebasePushMessaging() : _messaging = FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  @override
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  @override
  // ignore: deprecated_member_use, see the class comment
  Future<String?> token() => _messaging.getToken();

  @override
  // ignore: deprecated_member_use, see the class comment
  Stream<String> get tokenRefresh => _messaging.onTokenRefresh;

  @override
  // ignore: deprecated_member_use, see the class comment
  Future<void> deleteToken() => _messaging.deleteToken();

  @override
  Stream<PushData> get received =>
      FirebaseMessaging.onMessage.map((message) => _data(message));

  @override
  Stream<PushData> get opened {
    final controller = StreamController<PushData>();
    _messaging.getInitialMessage().then((message) {
      if (message != null) controller.add(_data(message));
    });
    controller.addStream(
      FirebaseMessaging.onMessageOpenedApp.map((message) => _data(message)),
    );
    return controller.stream;
  }

  static PushData _data(RemoteMessage message) => {
    for (final MapEntry(:key, :value) in message.data.entries) key: '$value',
  };
}
