import 'package:flutter/cupertino.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// The states a status badge can show. Each has its own word, icon and color
/// pair, so a status never rests on color alone.
enum AppStatus {
  confirmed,
  pending,
  open,
  cancelled,

  /// A shift without free spots; neutral, since nothing went wrong.
  full,

  /// A place on a shift's waitlist; neutral too, since it holds no spot.
  waiting,
}

/// A status as a pill with an icon and a word. Not tappable.
class AppBadge extends StatelessWidget {
  const AppBadge({super.key, required this.status, required this.label});

  final AppStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (icon, foreground, background) = switch (status) {
      AppStatus.confirmed => (
        CupertinoIcons.checkmark,
        colors.statusConfirmedFg,
        colors.statusConfirmedBg,
      ),
      AppStatus.pending => (
        CupertinoIcons.clock,
        colors.statusPendingFg,
        colors.statusPendingBg,
      ),
      AppStatus.open => (
        CupertinoIcons.plus,
        colors.statusOpenFg,
        colors.statusOpenBg,
      ),
      AppStatus.cancelled => (
        CupertinoIcons.xmark,
        colors.statusCancelledFg,
        colors.statusCancelledBg,
      ),
      AppStatus.full => (
        CupertinoIcons.minus_circle,
        colors.ink,
        colors.surfaceSoft,
      ),
      AppStatus.waiting => (
        CupertinoIcons.hourglass,
        colors.ink,
        colors.surfaceSoft,
      ),
    };

    return Container(
      constraints: const BoxConstraints(minHeight: AppSize.badge),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: ShapeDecoration(
        color: background,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSize.iconSm, color: foreground),
          const SizedBox(width: AppSpacing.xxs),
          Flexible(
            child: Text(
              label,
              style: AppTypography.badge.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
