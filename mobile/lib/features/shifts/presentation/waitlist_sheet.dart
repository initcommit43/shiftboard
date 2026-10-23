import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftboard_api/shiftboard_api.dart';

import '../../../core/api/api_error.dart';
import '../../../core/api/api_provider.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_alert.dart';
import '../../../core/widgets/app_button.dart';
import '../../auth/data/session.dart';
import '../data/worker_shifts_provider.dart';
import 'shift_card.dart';
import 'shift_format.dart';

/// Explains how the waitlist of the full [shift] works and puts the worker
/// on it once they confirm. Completes with the shift and the worker's place,
/// or null when they did not join.
Future<WorkerShift?> showJoinWaitlistSheet(
  BuildContext context,
  WorkerShift shift,
) => showModalBottomSheet<WorkerShift>(
  context: context,
  isScrollControlled: true,
  builder: (context) => _WaitlistSheet(shift: shift, join: true),
);

/// Asks the worker to confirm leaving the waitlist of [shift] and takes them
/// off it. Completes with true once they left.
Future<bool> showLeaveWaitlistSheet(
  BuildContext context,
  WorkerShift shift,
) async {
  final left = await showModalBottomSheet<WorkerShift>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _WaitlistSheet(shift: shift, join: false),
  );
  return left != null;
}

/// Joining and leaving share the sheet; [join] picks which one it is.
class _WaitlistSheet extends ConsumerStatefulWidget {
  const _WaitlistSheet({required this.shift, required this.join});

  final WorkerShift shift;
  final bool join;

  @override
  ConsumerState<_WaitlistSheet> createState() => _WaitlistSheetState();
}

class _WaitlistSheetState extends ConsumerState<_WaitlistSheet> {
  bool _submitting = false;
  String? _error;

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final api = ref.read(apiProvider).getWaitlistApi();
      final shiftId = widget.shift.id;
      final response = widget.join
          ? await api.joinWaitlist(shiftId: shiftId)
          : await api.leaveWaitlist(shiftId: shiftId);
      _refreshShifts();
      if (mounted) Navigator.of(context).pop(response.data ?? widget.shift);
    } catch (error) {
      if (!mounted) return;
      final apiError = ApiError.from(error);
      // The shift or the worker's place changed under them; show what is
      // true now.
      if (_isOutdated(apiError.code)) _refreshShifts();
      setState(() {
        _submitting = false;
        _error = _message(apiError);
      });
    }
  }

  bool _isOutdated(String? code) => switch (code) {
    ApiErrorCode.waitlistDisabled ||
    ApiErrorCode.shiftNotFull ||
    ApiErrorCode.alreadyOnWaitlist ||
    ApiErrorCode.notOnWaitlist ||
    ApiErrorCode.shiftAlreadyClaimed ||
    ApiErrorCode.shiftStarted ||
    ApiErrorCode.shiftNotOpen => true,
    _ => false,
  };

  void _refreshShifts() {
    ref
      ..invalidate(workerShiftsProvider)
      ..invalidate(myShiftsProvider)
      ..invalidate(workerShiftProvider(widget.shift.id));
  }

  String _message(ApiError error) {
    final l10n = context.l10n;
    return switch (error.code) {
      ApiErrorCode.waitlistDisabled => l10n.waitlistErrorDisabled,
      ApiErrorCode.shiftNotFull => l10n.waitlistErrorNotFull,
      ApiErrorCode.alreadyOnWaitlist => l10n.waitlistErrorAlreadyWaiting,
      ApiErrorCode.notOnWaitlist => l10n.waitlistErrorNotWaiting,
      ApiErrorCode.shiftAlreadyClaimed => l10n.claimErrorAlreadyClaimed,
      ApiErrorCode.shiftStarted => l10n.claimErrorStarted,
      ApiErrorCode.shiftNotOpen ||
      ApiErrorCode.shiftNotFound => l10n.claimErrorNotOpen,
      ApiErrorCode.shiftOverlap => l10n.claimErrorOverlap,
      _ => error.message(l10n),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final format = ShiftFormat.of(context);
    final shift = widget.shift;
    final join = widget.join;
    final agency = ref.watch(currentUserProvider)?.agency.name ?? '';

    final String submitLabel;
    if (join) {
      submitLabel = _submitting
          ? l10n.waitlistJoinSubmitting
          : l10n.waitlistJoinSubmit;
    } else {
      submitLabel = _submitting
          ? l10n.waitlistLeaveSubmitting
          : l10n.waitlistLeaveSubmit;
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.paddingCard,
          AppSpacing.sm,
          AppSpacing.paddingCard,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 5,
                decoration: ShapeDecoration(
                  color: colors.hairline,
                  shape: const StadiumBorder(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Semantics(
              header: true,
              child: Text(
                join
                    ? l10n.waitlistJoinSheetTitle
                    : l10n.waitlistLeaveSheetTitle,
                style: AppTypography.title2.copyWith(color: colors.ink),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              join
                  ? l10n.waitlistJoinSheetMessage(agency)
                  : l10n.waitlistLeaveSheetMessage,
              style: AppTypography.callout.copyWith(color: colors.inkSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              shift.title,
              style: AppTypography.headline.copyWith(color: colors.ink),
            ),
            const SizedBox(height: AppSpacing.sm),
            ShiftFactLine(
              icon: CupertinoIcons.calendar,
              text: format.dateAndTime(shift),
            ),
            const SizedBox(height: AppSpacing.xs),
            ShiftFactLine(
              icon: CupertinoIcons.location,
              text: shift.location.name,
            ),
            if (_error case final error?) ...[
              const SizedBox(height: AppSpacing.lg),
              AppAlert(text: error),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: submitLabel,
              variant: join ? AppButtonVariant.action : AppButtonVariant.danger,
              loading: _submitting,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.xs),
            AppButton(
              label: join ? l10n.actionCancel : l10n.waitlistLeaveKeep,
              variant: AppButtonVariant.text,
              onPressed: _submitting ? null : () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
