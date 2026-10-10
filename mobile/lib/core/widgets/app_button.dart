import 'package:flutter/material.dart';

import '../theme/tokens.dart';

enum AppButtonVariant { primary, outline, ghost }

/// The app's action button; sizes and colors come from the button themes.
///
/// While [loading] it shows a spinner, keeps its colors and ignores taps.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool loading;

  /// Whether the button fills the available width.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = switch (variant) {
      AppButtonVariant.primary => scheme.onPrimary,
      AppButtonVariant.outline => scheme.onSurface,
      AppButtonVariant.ghost => scheme.primary,
    };
    final onPressed = loading ? null : this.onPressed;
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (loading) ...[
          SizedBox.square(
            dimension: AppSpacing.s5,
            child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
          ),
          const SizedBox(width: AppSpacing.s2),
        ],
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    );

    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: onPressed,
        style: loading
            ? FilledButton.styleFrom(
                disabledBackgroundColor: scheme.primary,
                disabledForegroundColor: foreground,
              )
            : null,
        child: child,
      ),
      AppButtonVariant.outline => OutlinedButton(
        onPressed: onPressed,
        style: loading
            ? OutlinedButton.styleFrom(disabledForegroundColor: foreground)
            : null,
        child: child,
      ),
      AppButtonVariant.ghost => TextButton(
        onPressed: onPressed,
        style: loading
            ? TextButton.styleFrom(disabledForegroundColor: foreground)
            : null,
        child: child,
      ),
    };

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
