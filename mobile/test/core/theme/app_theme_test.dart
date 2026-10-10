import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftboard/core/theme/app_theme.dart';
import 'package:shiftboard/core/theme/tokens.dart';

void main() {
  final cases = {
    'light': (AppTheme.light, AppColors.light, Brightness.light),
    'dark': (AppTheme.dark, AppColors.dark, Brightness.dark),
  };

  for (final MapEntry(key: name, value: (theme, colors, brightness))
      in cases.entries) {
    group('$name theme', () {
      test('maps the token colors to the color scheme', () {
        final scheme = theme.colorScheme;

        expect(theme.useMaterial3, isTrue);
        expect(scheme.brightness, brightness);
        expect(scheme.primary, colors.primary);
        expect(scheme.onPrimary, colors.primaryForeground);
        expect(scheme.surface, colors.background);
        expect(scheme.onSurface, colors.foreground);
        expect(scheme.onSurfaceVariant, colors.mutedForeground);
        expect(scheme.error, colors.destructive);
        expect(scheme.onError, colors.destructiveForeground);
        expect(scheme.outlineVariant, colors.border);
        expect(theme.scaffoldBackgroundColor, colors.background);
      });

      test('exposes success and warning as a theme extension', () {
        final semantic = theme.extension<AppSemanticColors>()!;

        expect(semantic.success, colors.success);
        expect(semantic.onSuccess, colors.successForeground);
        expect(semantic.warning, colors.warning);
        expect(semantic.onWarning, colors.warningForeground);
      });

      test('uses the brand font and token font sizes', () {
        final text = theme.textTheme;

        expect(text.bodyLarge!.fontFamily, AppBrand.fontFamily);
        expect(text.bodyLarge!.fontSize, AppFontSize.md);
        expect(text.bodyMedium!.fontSize, AppFontSize.sm);
        expect(text.displaySmall!.fontSize, AppFontSize.xxxl);
        expect(text.bodyLarge!.color, colors.foreground);
      });
    });
  }

  test('semantic colors interpolate between themes', () {
    final light = AppTheme.light.extension<AppSemanticColors>()!;
    final dark = AppTheme.dark.extension<AppSemanticColors>()!;

    expect(light.lerp(dark, 0).success, AppColors.light.success);
    expect(light.lerp(dark, 1).success, AppColors.dark.success);
  });
}
