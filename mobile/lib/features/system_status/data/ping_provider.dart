import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftboard_api/shiftboard_api.dart';

import '../../../core/api/api_provider.dart';

final pingProvider = FutureProvider.autoDispose<Ping>(
  (ref) async {
    final response = await ref.watch(apiProvider).getSystemApi().ping();
    return response.data!;
  },
  // The screen offers a manual retry, so no automatic one in the background.
  retry: (retryCount, error) => null,
);
