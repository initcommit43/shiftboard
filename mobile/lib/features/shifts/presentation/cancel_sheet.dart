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
import '../data/worker_shifts_provider.dart';
import 'shift_card.dart';
import 'shift_format.dart';

/// Asks the worker to confirm dropping out of [shift] and sends it. Completes
/// with true once the cancellation went through.
Future<bool> showCancelSheet(BuildContext context, WorkerShift shift) async {
  final cancelled = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _CancelSheet(shift: shift),
  );
  return cancelled ?? false;
}

class _CancelSheet extends ConsumerStatefulWidget {
  const _CancelSheet({required this.shift});

  final WorkerShift shift;

  @override
  ConsumerState<_CancelSheet> createState() => _CancelSheetState();
}

class _CancelSheetState extends ConsumerState<_CancelSheet> {
  bool _submitting = false;
  String? _error;

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref
          .read(apiProvider)
          .getWorkerShiftsApi()
          .cancelClaim(shiftId: widget.shift.id);
      _refreshShifts();
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      final apiError = ApiError.from(error);
      // The claim changed under the worker; show what is true now.
      if (apiError.code == ApiErrorCode.cancellationDeadlinePassed ||
          apiError.code == ApiErrorCode.assignmentNotActive) {
        _refreshShifts();
      }
      setState(() {
        _submitting = false;
        _error = _message(apiError);
      });
    }
  }

  void _refreshShifts() {
    ref
      ..invalidate(workerShiftsProvider)
      ..invalidate(myShiftsProvider)
      ..invalidate(workerShiftProvider(widget.shift.id));
  }

  String _message(ApiError error) {
    final l10n = context.l10n;
    return switch (error.code) {
      ApiErrorCode.cancellationDeadlinePassed => l10n.cancelErrorDeadline,
      ApiErrorCode.assignmentNotActive ||
      ApiErrorCode.assignmentNotFound => l10n.cancelErrorNotActive,
      _ => error.message(l10n),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final format = ShiftFormat.of(context);
    final shift = widget.shift;

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
                l10n.cancelSheetTitle,
                style: AppTypography.title2.copyWith(color: colors.ink),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.cancelSheetMessage,
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
              label: _submitting ? l10n.cancelSubmitting : l10n.cancelSubmit,
              variant: AppButtonVariant.danger,
              loading: _submitting,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.xs),
            AppButton(
              label: l10n.cancelKeep,
              variant: AppButtonVariant.text,
              onPressed: _submitting
                  ? null
                  : () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}
