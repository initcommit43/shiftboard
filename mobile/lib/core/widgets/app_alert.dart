import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// An inline error message, announced to screen readers when it appears.
class AppAlert extends StatelessWidget {
  const AppAlert({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Semantics(
      container: true,
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          border: Border.all(color: scheme.error),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s4,
            vertical: AppSpacing.s3,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: AppSpacing.s5,
                color: scheme.error,
              ),
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.error,
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
