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
import '../../../core/widgets/form_page.dart';
import '../../auth/data/session.dart';
import '../data/worker_shifts_provider.dart';
import '../domain/shift_facts.dart';
import 'shift_card.dart';
import 'shift_format.dart';

/// When check-in opens, for example "Einchecken ab 06:30" on the same day
/// and with the date on a later one.
String checkInOpensLabel(
  WorkerShift shift,
  DateTime now,
  AppLocalizations l10n,
  ShiftFormat format,
) {
  final from = shift.assignment!.checkInFrom!.toLocal();
  final today = now.toLocal();
  final sameDay =
      from.year == today.year &&
      from.month == today.month &&
      from.day == today.day;
  return sameDay
      ? l10n.checkInOpensAt(format.time(from))
      : l10n.checkInOpensOn(format.date(from), format.time(from));
}

/// The pinned bar while the worker can check in or out: checking in is one
/// tap, checking out asks first, since it happens once. Before the window
/// opens, a disabled button says when it does.
class CheckInBar extends ConsumerStatefulWidget {
  const CheckInBar({super.key, required this.shift, required this.now});

  final WorkerShift shift;
  final DateTime now;

  @override
  ConsumerState<CheckInBar> createState() => _CheckInBarState();
}

class _CheckInBarState extends ConsumerState<CheckInBar> {
  bool _submitting = false;

  Future<void> _checkIn() async {
    if (_submitting) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final shiftId = widget.shift.id;
    setState(() => _submitting = true);
    try {
      final response = await ref
          .read(apiProvider)
          .getHoursApi()
          .checkIn(shiftId: shiftId);
      showReturnedShift(ref, response.data!);
      messenger.showSnackBar(SnackBar(content: Text(l10n.checkInDone)));
    } catch (error) {
      final apiError = ApiError.from(error);
      if (!apiError.isOffline) reloadShift(ref, shiftId);
      messenger.showSnackBar(
        SnackBar(content: Text(checkInErrorMessage(ref, l10n, apiError))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final margin = screenMargin(context);
    final shift = widget.shift;

    final Widget button = switch (shift.checkInAt(widget.now)) {
      CheckIn.open => AppButton(
        label: _submitting ? l10n.checkInSubmitting : l10n.checkInAction,
        loading: _submitting,
        onPressed: _checkIn,
      ),
      CheckIn.checkedIn => AppButton(
        label: l10n.checkOutAction,
        onPressed: () async {
          final checkedOut = await showCheckOutSheet(context, shift);
          if (!checkedOut || !context.mounted) return;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.checkOutDone)));
        },
      ),
      _ => AppButton(
        label: checkInOpensLabel(
          shift,
          widget.now,
          l10n,
          ShiftFormat.of(context),
        ),
        onPressed: null,
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.colors.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            margin,
            AppSpacing.md,
            margin,
            AppSpacing.sm,
          ),
          child: button,
        ),
      ),
    );
  }
}

/// Shows [shift] as the check-in or check-out returned it and lets the list
/// of the worker's shifts catch up.
void showReturnedShift(WidgetRef ref, WorkerShift shift) {
  ref.read(workerShiftProvider(shift.id).notifier).show(shift);
  ref.invalidate(myShiftsProvider);
}

/// After a rejected check-in or check-out: the shift changed under the
/// worker, so show what is true now.
void reloadShift(WidgetRef ref, String shiftId) {
  ref
    ..invalidate(workerShiftProvider(shiftId))
    ..invalidate(myShiftsProvider);
}

/// Why checking in or out did not work, worded for the worker.
String checkInErrorMessage(
  WidgetRef ref,
  AppLocalizations l10n,
  ApiError error,
) {
  final agency = ref.read(currentUserProvider)?.agency.name ?? '';
  return switch (error.code) {
    ApiErrorCode.checkInDisabled => l10n.checkInErrorDisabled,
    ApiErrorCode.assignmentNotConfirmed => l10n.checkInErrorNotConfirmed,
    ApiErrorCode.checkInNotOpen => l10n.checkInErrorNotOpen,
    ApiErrorCode.alreadyCheckedIn => l10n.checkInErrorAlreadyIn,
    ApiErrorCode.notCheckedIn => l10n.checkInErrorNotIn,
    ApiErrorCode.alreadyCheckedOut => l10n.checkInErrorAlreadyOut,
    ApiErrorCode.hoursApproved => l10n.checkInErrorHoursApproved(agency),
    ApiErrorCode.assignmentNotFound => l10n.checkInErrorNoSpot,
    ApiErrorCode.shiftNotFound => l10n.checkInErrorShiftGone,
    _ => error.message(l10n),
  };
}

/// Asks the worker to confirm checking out of [shift] and sends it.
/// Completes with true once the check-out went through.
Future<bool> showCheckOutSheet(BuildContext context, WorkerShift shift) async {
  final checkedOut = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _CheckOutSheet(shift: shift),
  );
  return checkedOut ?? false;
}

class _CheckOutSheet extends ConsumerStatefulWidget {
  const _CheckOutSheet({required this.shift});

  final WorkerShift shift;

  @override
  ConsumerState<_CheckOutSheet> createState() => _CheckOutSheetState();
}

class _CheckOutSheetState extends ConsumerState<_CheckOutSheet> {
  bool _submitting = false;
  String? _error;

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final response = await ref
          .read(apiProvider)
          .getHoursApi()
          .checkOut(shiftId: widget.shift.id);
      showReturnedShift(ref, response.data!);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      final apiError = ApiError.from(error);
      if (!apiError.isOffline) reloadShift(ref, widget.shift.id);
      setState(() {
        _submitting = false;
        _error = checkInErrorMessage(ref, context.l10n, apiError);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final format = ShiftFormat.of(context);
    final shift = widget.shift;
    final checkedInAt = shift.assignment?.checkedInAt;

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
                l10n.checkOutSheetTitle,
                style: AppTypography.title2.copyWith(color: colors.ink),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.checkOutSheetMessage,
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
            if (checkedInAt != null) ...[
              const SizedBox(height: AppSpacing.xs),
              ShiftFactLine(
                icon: CupertinoIcons.clock,
                text: l10n.checkedInAt(format.time(checkedInAt)),
              ),
            ],
            if (_error case final error?) ...[
              const SizedBox(height: AppSpacing.lg),
              AppAlert(text: error),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: _submitting
                  ? l10n.checkOutSubmitting
                  : l10n.checkOutSubmit,
              loading: _submitting,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.xs),
            AppButton(
              label: l10n.checkOutKeep,
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

/// The worker's recorded times on the shift detail, once they checked in.
/// They can't be changed in the app; the agency corrects them.
class AttendanceCard extends ConsumerWidget {
  const AttendanceCard({super.key, required this.shift});

  final WorkerShift shift;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = context.l10n;
    final format = ShiftFormat.of(context);
    final agency = ref.watch(currentUserProvider)?.agency.name ?? '';
    final assignment = shift.assignment!;
    final checkedInAt = assignment.checkedInAt!;
    final checkedOutAt = assignment.checkedOutAt;
    final approved = assignment.hoursApproved ?? false;
    final secondary = AppTypography.footnote.copyWith(
      color: colors.inkSecondary,
    );

    final String note;
    if (approved) {
      note = l10n.hoursApproved(agency);
    } else if (checkedOutAt == null) {
      note = l10n.checkOutHint;
    } else {
      note = l10n.attendanceFixed(agency);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.paddingCard),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (checkedOutAt == null)
              Text(
                l10n.checkedInAt(format.time(checkedInAt)),
                style: AppTypography.title2.copyWith(
                  color: colors.ink,
                  fontFeatures: tabularFigures,
                ),
              )
            else ...[
              Text(l10n.attendanceTitle, style: secondary),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                l10n.shiftTimeRange(
                  format.time(checkedInAt),
                  format.time(checkedOutAt),
                ),
                style: AppTypography.title2.copyWith(
                  color: colors.ink,
                  fontFeatures: tabularFigures,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (approved) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: ExcludeSemantics(
                      child: Icon(
                        CupertinoIcons.checkmark_seal,
                        size: AppSize.iconSm,
                        color: colors.inkSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Expanded(child: Text(note, style: secondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
