import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_provider.dart';

/// Whether the worker has paused notifications about new shifts.
final newShiftsPausedProvider = FutureProvider.autoDispose<bool>(
  (ref) async {
    final response = await ref
        .watch(apiProvider)
        .getNotificationsApi()
        .getNotificationSettings();
    return response.data!.newShiftsPaused;
  },
  // The profile offers a manual retry.
  retry: (retryCount, error) => null,
);
