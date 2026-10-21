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

/// Every shift the worker has claimed, with their assignment, earliest first.
final myShiftsProvider = FutureProvider.autoDispose<List<WorkerShift>>(
  (ref) async {
    final response = await ref
        .watch(apiProvider)
        .getWorkerShiftsApi()
        .listMyShifts(size: _listSize);
    return response.data!.content.toList();
  },
  // The list offers a manual retry and pull to refresh.
  retry: (retryCount, error) => null,
);

/// One shift of the agency with everything the worker sees of it. The
/// screen offers a manual retry, so failed loads are not retried.
final workerShiftProvider = AsyncNotifierProvider.autoDispose
    .family<WorkerShiftNotifier, WorkerShift, String>(
      WorkerShiftNotifier.new,
      retry: (retryCount, error) => null,
    );

class WorkerShiftNotifier extends AsyncNotifier<WorkerShift> {
  WorkerShiftNotifier(this.shiftId);

  final String shiftId;

  @override
  Future<WorkerShift> build() async {
    final response = await ref
        .watch(apiProvider)
        .getWorkerShiftsApi()
        .getWorkerShift(shiftId: shiftId);
    return response.data!;
  }

  /// Shows [shift] as an action returned it, without loading it again.
  void show(WorkerShift shift) => state = AsyncData(shift);
}
