import 'package:flutter/cupertino.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// An inline error message, announced to screen readers when it appears.
class AppAlert extends StatelessWidget {
  const AppAlert({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      container: true,
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.statusCancelledBg,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  CupertinoIcons.exclamationmark_circle,
                  size: AppSize.iconSm,
                  color: colors.statusCancelledFg,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  text,
                  style: AppTypography.subhead.copyWith(
                    color: colors.statusCancelledFg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
