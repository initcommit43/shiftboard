import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
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
    final colors = context.colors;
    final l10n = context.l10n;
    final user = ref.watch(currentUserProvider);
    final muted = AppTypography.subhead.copyWith(color: colors.inkSecondary);

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
            Row(
              children: [
                InitialsAvatar(name: name, size: AppSpacing.xxxl),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTypography.title2.copyWith(color: colors.ink),
                      ),
                      if (user != null) Text(user.agency.name, style: muted),
                    ],
                  ),
                ),
              ],
            ),
            if (user != null) ...[
              const SizedBox(height: AppSpacing.xl),
              Text(l10n.accountSignedInAsLabel, style: muted),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                user.email,
                style: AppTypography.body.copyWith(color: colors.ink),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
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
