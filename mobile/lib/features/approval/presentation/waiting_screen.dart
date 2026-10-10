import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftboard_api/shiftboard_api.dart';

import '../../../core/api/api_error.dart';
import '../../../core/l10n/l10n.dart';
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
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final user = ref.watch(currentUserProvider);
    // Logged out; the router is about to leave this screen.
    if (user == null) return const Scaffold();

    final divider = Divider(
      height: AppSpacing.s6,
      thickness: 1,
      color: theme.colorScheme.outlineVariant,
    );

    return StatusPage(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusMessage(
            icon: Icons.schedule_rounded,
            tone: StatusTone.accent,
            title: l10n.waitingTitle,
            message: l10n.waitingMessage(user.agency.name),
          ),
          const SizedBox(height: AppSpacing.s8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s4),
              child: Column(
                children: [
                  _Row(
                    label: l10n.waitingStatusLabel,
                    value: AppBadge.warning(label: l10n.waitingStatusPending),
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
          ),
        ],
      ),
      actions: [
        AppButton(
          label: l10n.waitingRefresh,
          variant: AppButtonVariant.outline,
          loading: _refreshing,
          onPressed: _refresh,
        ),
        AppButton(
          label: l10n.actionLogout,
          variant: AppButtonVariant.ghost,
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
    final theme = Theme.of(context);

    return MergeSemantics(
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Align(alignment: Alignment.centerRight, child: value),
          ),
        ],
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
      textAlign: TextAlign.end,
      style: Theme.of(context).textTheme.labelLarge,
    );
  }
}
