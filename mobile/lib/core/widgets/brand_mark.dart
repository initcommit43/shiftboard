import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// The logo with the product name next to it.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSpacing.s10,
          height: AppSpacing.s10,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(
            Icons.event_available_outlined,
            size: 22,
            color: scheme.onPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.s3),
        Flexible(child: Text(AppBrand.name, style: theme.textTheme.titleLarge)),
      ],
    );
  }
}
