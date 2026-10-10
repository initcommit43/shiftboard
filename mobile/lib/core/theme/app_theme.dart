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

    // The button and input themes take their styles from here, so the
    // font family has to be part of them.
    final text = _textTheme.apply(fontFamily: AppBrand.fontFamily);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      fontFamily: AppBrand.fontFamily,
      textTheme: text,
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
          minimumSize: _buttonSize,
          padding: _buttonPadding,
          shape: _controlShape,
          textStyle: text.titleSmall,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: _buttonSize,
          padding: _buttonPadding,
          shape: _controlShape,
          textStyle: text.titleSmall,
          backgroundColor: colors.card,
          foregroundColor: colors.foreground,
          side: BorderSide(color: colors.input),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: _buttonSize,
          padding: _buttonPadding,
          shape: _controlShape,
          textStyle: text.titleSmall,
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: colors.card,
        isDense: true,
        // 14 above and below the 24 high text line: 52 in total. The outlined
        // decorator adds 4 at each side, which makes the 16 of the design.
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s3,
          vertical: 14,
        ),
        hintStyle: TextStyle(color: colors.mutedForeground),
        suffixIconColor: colors.mutedForeground,
        errorStyle: text.labelMedium?.copyWith(color: colors.destructive),
        errorMaxLines: 3,
        border: _inputBorder(colors.input),
        enabledBorder: _inputBorder(colors.input),
        disabledBorder: _inputBorder(colors.border),
        focusedBorder: _inputBorder(colors.ring, width: 2),
        errorBorder: _inputBorder(colors.destructive, width: 2),
        focusedErrorBorder: _inputBorder(colors.destructive, width: 2),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: colors.card,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colors.accent,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? colors.primary
                : colors.mutedForeground,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? text.labelMedium?.copyWith(color: colors.foreground)
              : text.bodySmall?.copyWith(color: colors.mutedForeground),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.popover,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static const _buttonSize = Size(AppSpacing.s12, 52);
  static const _buttonPadding = EdgeInsets.symmetric(horizontal: AppSpacing.s6);
  static final _controlShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadius.lg),
  );

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  // Sizes, weights and line heights of the design's text styles; ThemeData
  // merges these onto the Material 3 defaults and takes the colors from the
  // color scheme.
  static const _textTheme = TextTheme(
    displaySmall: TextStyle(
      fontSize: AppFontSize.xxxl,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: 0,
    ),
    // Title
    headlineSmall: TextStyle(
      fontSize: AppFontSize.xxl,
      fontWeight: FontWeight.w600,
      height: 32 / 24,
      letterSpacing: -0.3,
    ),
    // Heading
    titleLarge: TextStyle(
      fontSize: AppFontSize.xl,
      fontWeight: FontWeight.w600,
      height: 28 / 20,
      letterSpacing: -0.2,
    ),
    titleMedium: TextStyle(
      fontSize: AppFontSize.lg,
      fontWeight: FontWeight.w600,
      height: 1.35,
      letterSpacing: 0,
    ),
    // Body / Semi Bold
    titleSmall: TextStyle(
      fontSize: AppFontSize.md,
      fontWeight: FontWeight.w600,
      height: 24 / 16,
      letterSpacing: 0,
    ),
    // Body / Regular
    bodyLarge: TextStyle(
      fontSize: AppFontSize.md,
      height: 24 / 16,
      letterSpacing: 0,
    ),
    // Small / Regular
    bodyMedium: TextStyle(
      fontSize: AppFontSize.sm,
      height: 20 / 14,
      letterSpacing: 0,
    ),
    // Caption / Regular
    bodySmall: TextStyle(
      fontSize: AppFontSize.xs,
      height: 16 / 12,
      letterSpacing: 0,
    ),
    // Small / Medium
    labelLarge: TextStyle(
      fontSize: AppFontSize.sm,
      fontWeight: FontWeight.w500,
      height: 20 / 14,
      letterSpacing: 0,
    ),
    // Caption / Medium
    labelMedium: TextStyle(
      fontSize: AppFontSize.xs,
      fontWeight: FontWeight.w500,
      height: 16 / 12,
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
