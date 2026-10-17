import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftboard_api/shiftboard_api.dart';

import '../../../core/api/api_error.dart';
import '../../../core/api/api_provider.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/push/push_messaging.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/form_page.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../auth/data/session.dart';
import '../data/notification_settings_provider.dart';

/// Who is signed in, the notification preferences and logging out.
class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox.shrink();
    final worker = user.worker;
    final name = worker == null
        ? user.email
        : '${worker.firstName} ${worker.lastName}';
    final muted = AppTypography.subhead.copyWith(color: colors.inkSecondary);

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: screenMargin(context),
        vertical: AppSpacing.sm,
      ),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.paddingCard),
            child: Row(
              children: [
                InitialsAvatar(name: name, size: AppSpacing.xxl),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTypography.headline.copyWith(
                          color: colors.ink,
                        ),
                      ),
                      Text(user.email, style: muted),
                      Text(user.agency.name, style: muted),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.xxl,
            bottom: AppSpacing.sm,
          ),
          child: Semantics(
            header: true,
            child: Text(
              l10n.profileNotifications,
              style: AppTypography.title3.copyWith(color: colors.ink),
            ),
          ),
        ),
        const _PauseNewShifts(),
        if (ref.watch(pushMessagingProvider) is DisabledPushMessaging) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.profilePushUnavailable, style: muted),
        ],
        const SizedBox(height: AppSpacing.xxl),
        AppButton(
          label: l10n.actionLogout,
          variant: AppButtonVariant.outline,
          onPressed: () => ref.read(sessionProvider.notifier).logout(),
        ),
      ],
    );
  }
}

class _PauseNewShifts extends ConsumerStatefulWidget {
  const _PauseNewShifts();

  @override
  ConsumerState<_PauseNewShifts> createState() => _PauseNewShiftsState();
}

class _PauseNewShiftsState extends ConsumerState<_PauseNewShifts> {
  /// The value being saved, shown right away.
  bool? _saving;

  Future<void> _change(bool paused) async {
    setState(() => _saving = paused);
    try {
      await ref
          .read(apiProvider)
          .getNotificationsApi()
          .updateNotificationSettings(
            notificationSettings: NotificationSettings(
              (b) => b.newShiftsPaused = paused,
            ),
          );
      ref.invalidate(newShiftsPausedProvider);
      await ref.read(newShiftsPausedProvider.future);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiError.from(error).message(context.l10n))),
        );
      }
    }
    if (mounted) setState(() => _saving = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final paused = ref.watch(newShiftsPausedProvider);
    final value = _saving ?? paused.value;

    if (paused.hasError && _saving == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.paddingCard),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.profileNotificationsError),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: l10n.actionRetry,
                variant: AppButtonVariant.soft,
                onPressed: () => ref.invalidate(newShiftsPausedProvider),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SwitchListTile.adaptive(
        value: value ?? false,
        onChanged: value == null || _saving != null ? null : _change,
        secondary: const Icon(CupertinoIcons.bell_slash),
        title: Text(
          l10n.profilePauseNewShifts,
          style: AppTypography.body.copyWith(color: context.colors.ink),
        ),
        subtitle: Text(
          l10n.profilePauseNewShiftsHint,
          style: AppTypography.footnote.copyWith(
            color: context.colors.inkSecondary,
          ),
        ),
      ),
    );
  }
}
