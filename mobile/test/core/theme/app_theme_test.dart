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
        expect(scheme.surface, colors.canvas);
        expect(scheme.onSurface, colors.ink);
        expect(scheme.onSurfaceVariant, colors.inkSecondary);
        expect(scheme.error, colors.danger);
        expect(scheme.onError, colors.onDanger);
        expect(scheme.outlineVariant, colors.hairline);
        expect(theme.scaffoldBackgroundColor, colors.canvas);
      });

      test('makes the action color the primary and cobalt the secondary', () {
        final scheme = theme.colorScheme;

        expect(scheme.primary, colors.action);
        expect(scheme.onPrimary, colors.onAction);
        expect(scheme.secondary, colors.primary);
        expect(scheme.onSecondary, colors.onPrimary);
      });

      test('exposes every token color as a theme extension', () {
        expect(theme.extension<AppPalette>()!.colors, same(colors));
      });

      test('uses the brand fonts and the text styles of the tokens', () {
        final text = theme.textTheme;

        expect(text.bodyMedium!.fontFamily, AppBrand.fontFamily);
        expect(text.bodyMedium!.fontSize, AppTypography.body.fontSize);
        expect(text.headlineLarge!.fontFamily, AppBrand.displayFontFamily);
        expect(text.headlineLarge!.fontSize, AppTypography.largeTitle.fontSize);
        expect(text.bodyMedium!.color, colors.ink);
      });
    });
  }

  test('the palette switches with the theme instead of blending', () {
    final light = AppTheme.light.extension<AppPalette>()!;
    final dark = AppTheme.dark.extension<AppPalette>()!;

    expect(light.lerp(dark, 0).colors, same(AppColors.light));
    expect(light.lerp(dark, 1).colors, same(AppColors.dark));
  });
}
