import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A chip that toggles one option of a multiple choice.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  static const double _minHeight = 44;

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = selected ? scheme.onPrimaryContainer : scheme.onSurface;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      side: selected
          ? BorderSide(color: scheme.primary, width: 1.5)
          : BorderSide(color: scheme.outline),
    );

    return Semantics(
      button: true,
      selected: selected,
      enabled: onSelected != null,
      child: Material(
        color: selected ? scheme.primaryContainer : scheme.surfaceContainerLow,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onSelected == null ? null : () => onSelected!(!selected),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _minHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s4,
                vertical: AppSpacing.s2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    Icon(
                      Icons.check_rounded,
                      size: AppSpacing.s4,
                      color: foreground,
                    ),
                    const SizedBox(width: AppSpacing.s2),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
