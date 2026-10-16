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

/// Asks the worker to confirm a claim on [shift] and sends it. Completes with
/// true once the claim went through.
Future<bool> showClaimSheet(BuildContext context, WorkerShift shift) async {
  final claimed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _ClaimSheet(shift: shift),
  );
  return claimed ?? false;
}

class _ClaimSheet extends ConsumerStatefulWidget {
  const _ClaimSheet({required this.shift});

  final WorkerShift shift;

  @override
  ConsumerState<_ClaimSheet> createState() => _ClaimSheetState();
}

class _ClaimSheetState extends ConsumerState<_ClaimSheet> {
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
          .claimShift(shiftId: widget.shift.id);
      _refreshShifts();
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      final apiError = ApiError.from(error);
      // A full shift changed under the worker; show what is true now.
      if (apiError.code == ApiErrorCode.shiftFull) _refreshShifts();
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
      ApiErrorCode.shiftFull => l10n.claimErrorFull,
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
    final agency = ref.watch(currentUserProvider)?.agency.name ?? '';

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
                l10n.claimSheetTitle,
                style: AppTypography.title2.copyWith(color: colors.ink),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.claimSheetMessage(agency),
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
            const SizedBox(height: AppSpacing.xs),
            ShiftFactLine(
              icon: CupertinoIcons.money_euro,
              text: format.earnings(shift),
            ),
            if (_error case final error?) ...[
              const SizedBox(height: AppSpacing.lg),
              AppAlert(text: error),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: _submitting ? l10n.claimSubmitting : l10n.claimSubmit,
              loading: _submitting,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.xs),
            AppButton(
              label: l10n.actionCancel,
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
