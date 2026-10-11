import 'package:flutter/material.dart';

import 'tokens.dart';

/// Material themes built from the generated design tokens.
///
/// The design system's primary call to action is [AppColors.action], a black
/// pill in light and a white one in dark, so that is what Material's
/// `primary` maps to. The cobalt brand color is Material's `secondary`: it is
/// a stamp that appears at most once per screen, not the color of controls.
abstract final class AppTheme {
  static final light = _build(AppColors.light, Brightness.light);
  static final dark = _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors colors, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: colors.action,
      onPrimary: colors.onAction,
      secondary: colors.primary,
      onSecondary: colors.onPrimary,
      error: colors.danger,
      onError: colors.onDanger,
      surface: colors.canvas,
      onSurface: colors.ink,
      onSurfaceVariant: colors.inkSecondary,
      surfaceContainerLowest: colors.surfaceCard,
      surfaceContainerLow: colors.surfaceCard,
      surfaceContainer: colors.surfaceCard,
      surfaceContainerHigh: colors.surfaceCard,
      surfaceContainerHighest: colors.surfaceSoft,
      outline: colors.hairlineStrong,
      outlineVariant: colors.hairline,
      scrim: colors.scrim,
      inverseSurface: colors.action,
      onInverseSurface: colors.onAction,
    );

    final text = _textTheme.apply(
      bodyColor: colors.ink,
      displayColor: colors.ink,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.canvas,
      fontFamily: AppBrand.fontFamily,
      textTheme: text,
      extensions: [AppPalette(colors)],
      // No ripples and no shadows: pressed states are a color step.
      splashFactory: NoSplash.splashFactory,
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: colors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: colors.hairline),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.hairline,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(color: colors.ink, size: AppSize.iconMd),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.ink),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: colors.surfaceCard,
        isDense: true,
        // 15 above and below the 22 high text line: 52 in total. The outlined
        // decorator adds 4 at each side, which makes the 16 of the design.
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg - 4,
          vertical: (AppSize.input - 22) / 2,
        ),
        hintStyle: AppTypography.body.copyWith(color: colors.inkPlaceholder),
        suffixIconColor: colors.inkSecondary,
        errorStyle: AppTypography.footnote.copyWith(color: colors.dangerText),
        errorMaxLines: 3,
        border: _inputBorder(colors.hairline),
        enabledBorder: _inputBorder(colors.hairline),
        disabledBorder: _inputBorder(colors.hairline),
        focusedBorder: _inputBorder(colors.hairlineStrong, width: 1.5),
        errorBorder: _inputBorder(colors.dangerText, width: 1.5),
        focusedErrorBorder: _inputBorder(colors.dangerText, width: 1.5),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.ink,
        selectionColor: colors.statusOpenBg,
        selectionHandleColor: colors.primary,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surfaceCard,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: colors.scrim,
        elevation: 0,
        modalElevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: colors.action,
        contentTextStyle: AppTypography.subhead.copyWith(
          color: colors.onAction,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  // The design's text styles on the Material slots that widgets fall back
  // to. Screens name the style they mean through [AppTypography].
  static const _textTheme = TextTheme(
    displaySmall: AppTypography.display,
    headlineLarge: AppTypography.largeTitle,
    headlineMedium: AppTypography.title1,
    headlineSmall: AppTypography.title2,
    titleLarge: AppTypography.title3,
    titleMedium: AppTypography.headline,
    titleSmall: AppTypography.headline,
    bodyLarge: AppTypography.body,
    bodyMedium: AppTypography.body,
    bodySmall: AppTypography.footnote,
    labelLarge: AppTypography.buttonLg,
    labelMedium: AppTypography.buttonSm,
    labelSmall: AppTypography.caption2,
  );
}

/// The token colors of the current theme, for everything that has no slot in
/// the Material [ColorScheme].
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette(this.colors);

  final AppColors colors;

  @override
  AppPalette copyWith({AppColors? colors}) => AppPalette(colors ?? this.colors);

  // The themes switch with the system appearance; there is nothing to blend.
  @override
  AppPalette lerp(AppPalette? other, double t) =>
      other == null || t < 0.5 ? this : other;
}

extension AppThemeContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppPalette>()!.colors;
}
