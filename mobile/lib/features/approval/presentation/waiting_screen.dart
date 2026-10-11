import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftboard_api/shiftboard_api.dart';

import '../../../core/api/api_error.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/status_message.dart';
import '../../auth/data/session.dart';

/// What a worker sees instead of the shifts until the agency has approved the
/// signup.
class WaitingScreen extends ConsumerStatefulWidget {
  const WaitingScreen({super.key});

  @override
  ConsumerState<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends ConsumerState<WaitingScreen> {
  bool _refreshing = false;

  Future<void> _refresh() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _refreshing = true);

    String? message;
    try {
      await ref.read(sessionProvider.notifier).refresh();
      // Once approved, the router replaces this screen with the shifts.
      final status = ref.read(currentUserProvider)?.worker?.status;
      if (status == WorkerStatus.PENDING) message = l10n.waitingStillPending;
    } on DioException catch (error) {
      message = ApiError.from(error).message(l10n);
    }

    if (mounted) setState(() => _refreshing = false);
    if (message != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = ref.watch(currentUserProvider);
    // Logged out; the router is about to leave this screen.
    if (user == null) return const Scaffold();

    // Inset to the text of the rows, as in a grouped list.
    const divider = Divider(indent: AppSpacing.lg);

    return StatusPage(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusMessage(
            icon: CupertinoIcons.clock,
            tone: StatusTone.pending,
            title: l10n.waitingTitle,
            message: l10n.waitingMessage(user.agency.name),
          ),
          const SizedBox(height: AppSpacing.xxl),
          DecoratedBox(
            decoration: BoxDecoration(
              color: context.colors.surfaceCard,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: context.colors.hairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Row(
                  label: l10n.waitingStatusLabel,
                  value: AppBadge(
                    status: AppStatus.pending,
                    label: l10n.waitingStatusPending,
                  ),
                ),
                divider,
                _Row(
                  label: l10n.accountAgencyLabel,
                  value: _Value(user.agency.name),
                ),
                divider,
                _Row(
                  label: l10n.accountSignedInAsLabel,
                  value: _Value(user.email),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        AppButton(
          label: l10n.waitingRefresh,
          loading: _refreshing,
          onPressed: _refresh,
        ),
        AppButton(
          label: l10n.actionLogout,
          variant: AppButtonVariant.text,
          onPressed: _refreshing
              ? null
              : () => ref.read(sessionProvider.notifier).logout(),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSize.row),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          // The value moves below the label when both do not fit in a line.
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.xxs,
            children: [
              Text(
                label,
                style: AppTypography.body.copyWith(color: context.colors.ink),
              ),
              value,
            ],
          ),
        ),
      ),
    );
  }
}

class _Value extends StatelessWidget {
  const _Value(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.body.copyWith(color: context.colors.inkSecondary),
    );
  }
}
