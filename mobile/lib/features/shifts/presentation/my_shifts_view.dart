import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/widgets/app_button.dart';
import '../data/worker_shifts_provider.dart';
import 'shift_list_view.dart';

/// The tab with the shifts the worker has claimed and where each claim
/// stands, and the shifts they wait for with their place in line. [onBrowseShifts] switches to the open shifts.
class MyShiftsView extends StatelessWidget {
  const MyShiftsView({super.key, required this.onBrowseShifts});

  final VoidCallback onBrowseShifts;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ShiftListView(
      shifts: myShiftsProvider,
      emptyIcon: CupertinoIcons.checkmark_circle,
      emptyTitle: l10n.myShiftsEmptyTitle,
      emptyMessage: l10n.myShiftsEmptyMessage,
      emptyAction: AppButton(
        label: l10n.myShiftsBrowse,
        variant: AppButtonVariant.soft,
        expand: false,
        onPressed: onBrowseShifts,
      ),
    );
  }
}
