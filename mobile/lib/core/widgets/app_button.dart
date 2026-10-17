import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

enum AppButtonVariant {
  /// The one loud call to action of a screen: 52 high, black in light and
  /// white in dark.
  action,

  /// The alternative next to an action.
  outline,

  /// A tertiary action.
  soft,

  /// A quiet action without a surface, such as "Abmelden" below a button.
  text,

  /// A destructive action, such as "Schicht absagen". Never the loud call to
  /// action of a screen that offers something else.
  danger,
}

/// The app's pill button.
///
/// While [loading] it shows a spinner, keeps its colors and ignores taps.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.action,
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
    final colors = context.colors;
    final (background, pressed, foreground) = switch (variant) {
      AppButtonVariant.action => (
        colors.action,
        colors.actionPressed,
        colors.onAction,
      ),
      AppButtonVariant.outline => (
        Colors.transparent,
        colors.surfaceSoft,
        colors.ink,
      ),
      AppButtonVariant.soft => (
        colors.surfaceSoft,
        colors.hairline,
        colors.ink,
      ),
      AppButtonVariant.text => (
        Colors.transparent,
        colors.surfaceSoft,
        colors.ink,
      ),
      AppButtonVariant.danger => (
        colors.danger,
        colors.dangerText,
        colors.onDanger,
      ),
    };
    final filled =
        variant == AppButtonVariant.action ||
        variant == AppButtonVariant.soft ||
        variant == AppButtonVariant.danger;
    final enabled = onPressed != null || loading;

    final style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(
        Size(
          AppSize.touchTarget,
          variant == AppButtonVariant.action
              ? AppSize.buttonLg
              : AppSize.buttonMd,
        ),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      ),
      shape: const WidgetStatePropertyAll(StadiumBorder()),
      textStyle: const WidgetStatePropertyAll(AppTypography.buttonLg),
      elevation: const WidgetStatePropertyAll(0),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      foregroundColor: WidgetStatePropertyAll(
        enabled ? foreground : colors.inkDisabled,
      ),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (!enabled) return filled ? colors.surfaceSoft : Colors.transparent;
        return states.contains(WidgetState.pressed) ? pressed : background;
      }),
      side: variant == AppButtonVariant.outline
          ? WidgetStatePropertyAll(
              BorderSide(
                color: enabled ? colors.hairlineStrong : colors.hairline,
              ),
            )
          : null,
    );

    final button = FilledButton(
      onPressed: loading ? null : onPressed,
      style: style,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loading) ...[
            SizedBox.square(
              dimension: AppSize.iconSm,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: foreground,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(child: Text(label, textAlign: TextAlign.center)),
        ],
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
