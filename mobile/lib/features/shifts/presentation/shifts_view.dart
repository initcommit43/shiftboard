import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../data/worker_shifts_provider.dart';
import 'shift_list_view.dart';

/// The tab with the agency's upcoming shifts.
class ShiftsView extends StatelessWidget {
  const ShiftsView({super.key, required this.agencyName});

  final String agencyName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ShiftListView(
      shifts: workerShiftsProvider,
      emptyIcon: CupertinoIcons.calendar,
      emptyTitle: l10n.shiftsEmptyTitle,
      emptyMessage: l10n.shiftsEmptyMessage(agencyName),
    );
  }
}
