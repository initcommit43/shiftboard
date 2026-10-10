import 'package:flutter/material.dart';

import 'tokens.dart';

/// Material themes built from the generated design tokens.
abstract final class AppTheme {
  static final light = _build(AppColors.light, Brightness.light);
  static final dark = _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors colors, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.primaryForeground,
      primaryContainer: colors.accent,
      onPrimaryContainer: colors.accentForeground,
      secondary: colors.secondary,
      onSecondary: colors.secondaryForeground,
      secondaryContainer: colors.secondary,
      onSecondaryContainer: colors.secondaryForeground,
      error: colors.destructive,
      onError: colors.destructiveForeground,
      surface: colors.background,
      onSurface: colors.foreground,
      onSurfaceVariant: colors.mutedForeground,
      surfaceContainerLowest: colors.card,
      surfaceContainerLow: colors.card,
      surfaceContainer: colors.popover,
      surfaceContainerHigh: colors.popover,
      surfaceContainerHighest: colors.muted,
      outline: colors.input,
      outlineVariant: colors.border,
      inverseSurface: colors.foreground,
      onInverseSurface: colors.background,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      fontFamily: AppBrand.fontFamily,
      textTheme: _textTheme,
      extensions: [
        AppSemanticColors(
          success: colors.success,
          onSuccess: colors.successForeground,
          warning: colors.warning,
          onWarning: colors.warningForeground,
        ),
      ],
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: colors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.s12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
    );
  }

  // Sizes and weights only; ThemeData merges these onto the Material 3
  // defaults and takes the colors from the color scheme.
  static const _textTheme = TextTheme(
    displaySmall: TextStyle(
      fontSize: AppFontSize.xxxl,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: 0,
    ),
    headlineSmall: TextStyle(
      fontSize: AppFontSize.xxl,
      fontWeight: FontWeight.w600,
      height: 1.25,
      letterSpacing: 0,
    ),
    titleLarge: TextStyle(
      fontSize: AppFontSize.xl,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: 0,
    ),
    titleMedium: TextStyle(
      fontSize: AppFontSize.lg,
      fontWeight: FontWeight.w600,
      height: 1.35,
      letterSpacing: 0,
    ),
    titleSmall: TextStyle(
      fontSize: AppFontSize.md,
      fontWeight: FontWeight.w600,
      height: 1.4,
      letterSpacing: 0,
    ),
    bodyLarge: TextStyle(
      fontSize: AppFontSize.md,
      height: 1.5,
      letterSpacing: 0,
    ),
    bodyMedium: TextStyle(
      fontSize: AppFontSize.sm,
      height: 1.45,
      letterSpacing: 0,
    ),
    bodySmall: TextStyle(
      fontSize: AppFontSize.xs,
      height: 1.35,
      letterSpacing: 0,
    ),
    labelLarge: TextStyle(
      fontSize: AppFontSize.sm,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    ),
    labelMedium: TextStyle(
      fontSize: AppFontSize.xs,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    ),
  );
}

/// Semantic token colors that have no slot in the Material [ColorScheme].
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
  });

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
    );
  }

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppSemanticColors get semanticColors =>
      Theme.of(this).extension<AppSemanticColors>()!;
}
