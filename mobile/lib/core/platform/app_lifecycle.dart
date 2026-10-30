import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the app is in the foreground, where the worker can see it.
///
/// Inactive (a call, the notification shade) keeps the last answer, so that
/// short interruptions don't close what the app holds open.
final appInForegroundProvider = NotifierProvider<AppInForeground, bool>(
  AppInForeground.new,
);

class AppInForeground extends Notifier<bool> {
  @override
  bool build() {
    final listener = AppLifecycleListener(onStateChange: _changed);
    ref.onDispose(listener.dispose);
    // Not reported yet right after the start, which happens in the foreground.
    return _inForeground(WidgetsBinding.instance.lifecycleState) ?? true;
  }

  void _changed(AppLifecycleState lifecycle) {
    if (_inForeground(lifecycle) case final inForeground?) {
      state = inForeground;
    }
  }

  static bool? _inForeground(AppLifecycleState? lifecycle) =>
      switch (lifecycle) {
        AppLifecycleState.resumed => true,
        AppLifecycleState.hidden ||
        AppLifecycleState.paused ||
        AppLifecycleState.detached => false,
        AppLifecycleState.inactive || null => null,
      };
}
