import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftboard_api/shiftboard_api.dart';

import '../api/api_provider.dart';
import 'push_messaging.dart';

/// Tells the backend which device to push to for the signed-in worker.
class PushRegistration {
  PushRegistration(this._ref);

  final Ref _ref;

  NotificationsApi get _api => _ref.read(apiProvider).getNotificationsApi();

  PushMessaging get _push => _ref.read(pushMessagingProvider);

  /// Asks for permission and registers the device; does nothing when push is
  /// not available or the worker declined.
  Future<void> register() async {
    if (!await _push.requestPermission()) return;
    final token = await _push.token();
    if (token != null) await registerToken(token);
  }

  Future<void> registerToken(String token) => _api.registerPushToken(
    pushTokenRequest: PushTokenRequest(
      (b) => b
        ..token = token
        ..platform = defaultTargetPlatform == TargetPlatform.iOS
            ? PushPlatform.IOS
            : PushPlatform.ANDROID,
    ),
  );

  /// For logging out, while the session is still valid. Best effort: a token
  /// the backend keeps only reaches a device nobody is signed in on.
  Future<void> unregister() async {
    try {
      final token = await _push.token();
      if (token == null) return;
      await _api.unregisterPushToken(token: token);
      await _push.deleteToken();
    } catch (_) {
      // Logging out goes on either way.
    }
  }
}

final pushRegistrationProvider = Provider<PushRegistration>(
  PushRegistration.new,
);
