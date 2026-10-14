import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftboard_api/shiftboard_api.dart';

import '../../../core/api/api_provider.dart';

/// The most shifts the list loads; the largest page the API serves. An
/// agency rarely has more upcoming shifts than that at once.
const _listSize = 100;

/// The agency's upcoming published shifts, earliest first.
final workerShiftsProvider = FutureProvider.autoDispose<List<WorkerShift>>(
  (ref) async {
    final response = await ref
        .watch(apiProvider)
        .getWorkerShiftsApi()
        .listWorkerShifts(size: _listSize);
    return response.data!.content.toList();
  },
  // The list offers a manual retry and pull to refresh.
  retry: (retryCount, error) => null,
);

/// One shift of the agency with everything the worker sees of it.
final workerShiftProvider = FutureProvider.autoDispose
    .family<WorkerShift, String>(
      (ref, shiftId) async {
        final response = await ref
            .watch(apiProvider)
            .getWorkerShiftsApi()
            .getWorkerShift(shiftId: shiftId);
        return response.data!;
      },
      // The screen offers a manual retry.
      retry: (retryCount, error) => null,
    );
