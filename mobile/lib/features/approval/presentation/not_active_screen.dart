import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/status_message.dart';
import '../../auth/data/session.dart';

/// What a rejected or deactivated worker sees instead of the shifts.
class NotActiveScreen extends ConsumerWidget {
  const NotActiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final agency = ref.watch(currentUserProvider)?.agency.name;
    // Logged out; the router is about to leave this screen.
    if (agency == null) return const Scaffold();

    return StatusPage(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusMessage(
            icon: Icons.pause_circle_outline_rounded,
            title: l10n.inactiveTitle,
            message: l10n.inactiveMessage(agency),
          ),
          const SizedBox(height: AppSpacing.s8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.inactiveContactTitle,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s1),
                  Text(
                    l10n.inactiveContactMessage(agency),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        AppButton(
          label: l10n.actionLogout,
          variant: AppButtonVariant.outline,
          onPressed: () => ref.read(sessionProvider.notifier).logout(),
        ),
      ],
    );
  }
}
