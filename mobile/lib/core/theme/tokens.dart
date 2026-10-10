// Generated from design-tokens/tokens. Do not edit; run `npm run build` in design-tokens/.
import 'dart:ui';

/// Semantic colors of one theme.
class AppColors {
  const AppColors({
    required this.background,
    required this.foreground,
    required this.card,
    required this.cardForeground,
    required this.popover,
    required this.popoverForeground,
    required this.primary,
    required this.primaryForeground,
    required this.secondary,
    required this.secondaryForeground,
    required this.muted,
    required this.mutedForeground,
    required this.accent,
    required this.accentForeground,
    required this.destructive,
    required this.destructiveForeground,
    required this.success,
    required this.successForeground,
    required this.warning,
    required this.warningForeground,
    required this.border,
    required this.input,
    required this.ring,
  });

  final Color background;
  final Color foreground;
  final Color card;
  final Color cardForeground;
  final Color popover;
  final Color popoverForeground;
  final Color primary;
  final Color primaryForeground;
  final Color secondary;
  final Color secondaryForeground;
  final Color muted;
  final Color mutedForeground;
  final Color accent;
  final Color accentForeground;
  final Color destructive;
  final Color destructiveForeground;
  final Color success;
  final Color successForeground;
  final Color warning;
  final Color warningForeground;
  final Color border;
  final Color input;
  final Color ring;

  static const light = AppColors(
    background: Color(0xFFF7F8FA),
    foreground: Color(0xFF151922),
    card: Color(0xFFFFFFFF),
    cardForeground: Color(0xFF151922),
    popover: Color(0xFFFFFFFF),
    popoverForeground: Color(0xFF151922),
    primary: Color(0xFF2450CC),
    primaryForeground: Color(0xFFFFFFFF),
    secondary: Color(0xFFEEF0F4),
    secondaryForeground: Color(0xFF222733),
    muted: Color(0xFFEEF0F4),
    mutedForeground: Color(0xFF4D5668),
    accent: Color(0xFFEEF4FF),
    accentForeground: Color(0xFF1B367F),
    destructive: Color(0xFFB82C22),
    destructiveForeground: Color(0xFFFFFFFF),
    success: Color(0xFF17804A),
    successForeground: Color(0xFFFFFFFF),
    warning: Color(0xFFD98A00),
    warningForeground: Color(0xFF0D1017),
    border: Color(0xFFDFE3EA),
    input: Color(0xFFC5CBD6),
    ring: Color(0xFF3566E8),
  );

  static const dark = AppColors(
    background: Color(0xFF0D1017),
    foreground: Color(0xFFF7F8FA),
    card: Color(0xFF151922),
    cardForeground: Color(0xFFF7F8FA),
    popover: Color(0xFF151922),
    popoverForeground: Color(0xFFF7F8FA),
    primary: Color(0xFF5A87F7),
    primaryForeground: Color(0xFF0D1017),
    secondary: Color(0xFF222733),
    secondaryForeground: Color(0xFFEEF0F4),
    muted: Color(0xFF222733),
    mutedForeground: Color(0xFF98A1B2),
    accent: Color(0xFF1A2F63),
    accentForeground: Color(0xFFD9E6FF),
    destructive: Color(0xFFF0655B),
    destructiveForeground: Color(0xFF0D1017),
    success: Color(0xFF4CC585),
    successForeground: Color(0xFF0D1017),
    warning: Color(0xFFF2AE30),
    warningForeground: Color(0xFF0D1017),
    border: Color(0xFF222733),
    input: Color(0xFF363D4C),
    ring: Color(0xFF5A87F7),
  );
}

abstract final class AppSpacing {
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s10 = 40;
  static const double s12 = 48;
}

abstract final class AppRadius {
  static const double sm = 6;
  static const double md = 10;
  static const double lg = 14;
  static const double xl = 20;
}

abstract final class AppFontSize {
  static const double xs = 12;
  static const double sm = 14;
  static const double md = 16;
  static const double lg = 18;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 30;
}

abstract final class AppBrand {
  static const String name = 'shiftboard';
  static const String fontFamily = 'Inter';
}
