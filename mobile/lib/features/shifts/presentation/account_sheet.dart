import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../auth/data/session.dart';

/// Opens the sheet behind the avatar: who is signed in, and logging out.
Future<void> showAccountSheet(BuildContext context, {required String name}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _AccountSheet(name: name),
  );
}

class _AccountSheet extends ConsumerWidget {
  const _AccountSheet({required this.name});

  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final user = ref.watch(currentUserProvider);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s6,
          0,
          AppSpacing.s6,
          AppSpacing.s4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                InitialsAvatar(name: name, size: AppSpacing.s12),
                const SizedBox(width: AppSpacing.s4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: theme.textTheme.titleSmall),
                      if (user != null) Text(user.agency.name, style: muted),
                    ],
                  ),
                ),
              ],
            ),
            if (user != null) ...[
              const SizedBox(height: AppSpacing.s5),
              Text(l10n.accountSignedInAsLabel, style: muted),
              const SizedBox(height: AppSpacing.s1),
              Text(user.email, style: theme.textTheme.labelLarge),
            ],
            const SizedBox(height: AppSpacing.s6),
            AppButton(
              label: l10n.actionLogout,
              variant: AppButtonVariant.outline,
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(sessionProvider.notifier).logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
