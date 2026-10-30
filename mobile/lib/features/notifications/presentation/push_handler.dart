import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/push/push_messaging.dart';
import '../../../core/push/push_registration.dart';
import '../../../core/routing/app_router.dart';
import '../../auth/data/session.dart';
import '../../messages/data/messages_provider.dart';
import '../../shifts/data/worker_shifts_provider.dart';

/// Connects push notifications to the app: registers the device once a
/// worker is signed in, loads what changed when a push arrives, and opens
/// what a tapped push is about.
class PushHandler extends ConsumerStatefulWidget {
  const PushHandler({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PushHandler> createState() => _PushHandlerState();
}

class _PushHandlerState extends ConsumerState<PushHandler> {
  final _subscriptions = <StreamSubscription<Object?>>[];

  @override
  void initState() {
    super.initState();
    final push = ref.read(pushMessagingProvider);
    _subscriptions
      ..add(push.received.listen(_refresh))
      ..add(push.opened.listen(_open))
      ..add(
        push.tokenRefresh.listen((token) {
          if (_signedIn) {
            ref.read(pushRegistrationProvider).registerToken(token).ignore();
          }
        }),
      );
    // A session restored on start is signed in before anything listens.
    if (_signedIn) _register();
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel().ignore();
    }
    super.dispose();
  }

  bool get _signedIn => ref.read(sessionProvider).value is SignedIn;

  void _register() {
    ref.read(pushRegistrationProvider).register().catchError((Object _) {
      // Without a registered device the app still works; the next start
      // tries again.
    });
  }

  void _refresh(PushData data) {
    // The messages reload only where a chat on screen holds them, so a push
    // on another tab leaves them unread and the badge counts it.
    ref
      ..invalidate(workerShiftsProvider)
      ..invalidate(myShiftsProvider)
      ..invalidate(myMessagesProvider)
      ..invalidate(unreadMessagesProvider);
    if (data['shiftId'] case final shiftId?) {
      ref.invalidate(workerShiftProvider(shiftId));
    }
  }

  void _open(PushData data) {
    _refresh(data);
    final router = ref.read(routerProvider);
    final location = switch ((data['type'], data['shiftId'])) {
      ('MESSAGE' || 'BROADCAST', _) => AppRoutes.chat,
      (_, final shiftId?) => AppRoutes.shift(shiftId),
      _ => null,
    };
    if (location != null) router.push(location);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionProvider, (previous, next) {
      if (next.value is SignedIn && previous?.value is! SignedIn) _register();
    });
    return widget.child;
  }
}
