// Generated from design-tokens/tokens. Do not edit; run `npm run build` in design-tokens/.
import 'package:flutter/painting.dart';

/// Semantic colors of one theme.
class AppColors {
  const AppColors({
    required this.canvas,
    required this.surfaceSoft,
    required this.surfaceCard,
    required this.surfaceGlass,
    required this.scrim,
    required this.hairline,
    required this.hairlineStrong,
    required this.ink,
    required this.inkSecondary,
    required this.inkTertiary,
    required this.inkPlaceholder,
    required this.inkDisabled,
    required this.action,
    required this.actionPressed,
    required this.onAction,
    required this.primary,
    required this.primaryPressed,
    required this.onPrimary,
    required this.primaryText,
    required this.link,
    required this.focusRing,
    required this.danger,
    required this.onDanger,
    required this.dangerText,
    required this.statusConfirmedFg,
    required this.statusConfirmedBg,
    required this.statusPendingFg,
    required this.statusPendingBg,
    required this.statusOpenFg,
    required this.statusOpenBg,
    required this.statusCancelledFg,
    required this.statusCancelledBg,
  });

  final Color canvas;
  final Color surfaceSoft;
  final Color surfaceCard;
  final Color surfaceGlass;
  final Color scrim;
  final Color hairline;
  final Color hairlineStrong;
  final Color ink;
  final Color inkSecondary;
  final Color inkTertiary;
  final Color inkPlaceholder;
  final Color inkDisabled;
  final Color action;
  final Color actionPressed;
  final Color onAction;
  final Color primary;
  final Color primaryPressed;
  final Color onPrimary;
  final Color primaryText;
  final Color link;
  final Color focusRing;
  final Color danger;
  final Color onDanger;
  final Color dangerText;
  final Color statusConfirmedFg;
  final Color statusConfirmedBg;
  final Color statusPendingFg;
  final Color statusPendingBg;
  final Color statusOpenFg;
  final Color statusOpenBg;
  final Color statusCancelledFg;
  final Color statusCancelledBg;

  static const light = AppColors(
    canvas: Color(0xFFFFFFFF),
    surfaceSoft: Color(0xFFF4F4F4),
    surfaceCard: Color(0xFFFFFFFF),
    surfaceGlass: Color(0xCCFFFFFF),
    scrim: Color(0x66000000),
    hairline: Color(0xFFE2E2E7),
    hairlineStrong: Color(0xFF191C1F),
    ink: Color(0xFF191C1F),
    inkSecondary: Color(0xFF505A63),
    inkTertiary: Color(0xFF5C5E60),
    inkPlaceholder: Color(0xFF6E7378),
    inkDisabled: Color(0xFFC9C9CD),
    action: Color(0xFF000000),
    actionPressed: Color(0xFF3A3D40),
    onAction: Color(0xFFFFFFFF),
    primary: Color(0xFF494FDF),
    primaryPressed: Color(0xFF3A40C4),
    onPrimary: Color(0xFFFFFFFF),
    primaryText: Color(0xFF494FDF),
    link: Color(0xFF376CD5),
    focusRing: Color(0xFF494FDF),
    danger: Color(0xFFE23B4A),
    onDanger: Color(0xFFFFFFFF),
    dangerText: Color(0xFF8B0000),
    statusConfirmedFg: Color(0xFF006400),
    statusConfirmedBg: Color(0xFFE7F3E1),
    statusPendingFg: Color(0xFF9A5300),
    statusPendingBg: Color(0xFFFDF0DF),
    statusOpenFg: Color(0xFF3A40C4),
    statusOpenBg: Color(0xFFECEEFC),
    statusCancelledFg: Color(0xFF8B0000),
    statusCancelledBg: Color(0xFFFDEAEC),
  );

  static const dark = AppColors(
    canvas: Color(0xFF000000),
    surfaceSoft: Color(0xFF16181A),
    surfaceCard: Color(0xFF16181A),
    surfaceGlass: Color(0xCC16181A),
    scrim: Color(0x99000000),
    hairline: Color(0x1FFFFFFF),
    hairlineStrong: Color(0xB8FFFFFF),
    ink: Color(0xFFFFFFFF),
    inkSecondary: Color(0xB8FFFFFF),
    inkTertiary: Color(0xFF8D969E),
    inkPlaceholder: Color(0xFF8D969E),
    inkDisabled: Color(0x4DFFFFFF),
    action: Color(0xFFFFFFFF),
    actionPressed: Color(0xFFC9C9CD),
    onAction: Color(0xFF000000),
    primary: Color(0xFF494FDF),
    primaryPressed: Color(0xFF3A40C4),
    onPrimary: Color(0xFFFFFFFF),
    primaryText: Color(0xFF8A8FFF),
    link: Color(0xFF7B9CFF),
    focusRing: Color(0xFF8A8FFF),
    danger: Color(0xFFE23B4A),
    onDanger: Color(0xFFFFFFFF),
    dangerText: Color(0xFFFF8A80),
    statusConfirmedFg: Color(0xFF5CC98A),
    statusConfirmedBg: Color(0xFF0F2619),
    statusPendingFg: Color(0xFFFFB340),
    statusPendingBg: Color(0xFF2B1D08),
    statusOpenFg: Color(0xFFA6AAFF),
    statusOpenBg: Color(0xFF1B1D40),
    statusCancelledFg: Color(0xFFFF8A80),
    statusCancelledBg: Color(0xFF2E1214),
  );
}

abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 14;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double marginScreen = 16;
  static const double marginScreenWide = 20;
  static const double paddingCard = 20;
}

abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 20;
  static const double xl = 28;
  static const double full = 9999;
}

abstract final class AppSize {
  static const double touchTarget = 44;
  static const double touchTargetMin = 28;
  static const double buttonLg = 52;
  static const double buttonMd = 44;
  static const double buttonSm = 32;
  static const double input = 52;
  static const double row = 52;
  static const double navBar = 44;
  static const double tabBar = 64;
  static const double badge = 26;
  static const double iconMd = 24;
  static const double iconSm = 16;
  static const double screenWide = 428;
}

abstract final class AppTypography {
  static const TextStyle display = TextStyle(
    fontFamily: 'Inter Tight',
    fontSize: 40,
    fontWeight: FontWeight.w500,
    height: 44 / 40,
    letterSpacing: -0.8,
  );
  static const TextStyle largeTitle = TextStyle(
    fontFamily: 'Inter Tight',
    fontSize: 34,
    fontWeight: FontWeight.w500,
    height: 41 / 34,
    letterSpacing: -0.34,
  );
  static const TextStyle title1 = TextStyle(
    fontFamily: 'Inter Tight',
    fontSize: 28,
    fontWeight: FontWeight.w500,
    height: 34 / 28,
    letterSpacing: -0.28,
  );
  static const TextStyle title2 = TextStyle(
    fontFamily: 'Inter Tight',
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 28 / 22,
    letterSpacing: 0,
  );
  static const TextStyle title3 = TextStyle(
    fontFamily: 'Inter Tight',
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 25 / 20,
    letterSpacing: 0,
  );
  static const TextStyle headline = TextStyle(
    fontFamily: 'Inter',
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 22 / 17,
    letterSpacing: 0.16,
  );
  static const TextStyle body = TextStyle(
    fontFamily: 'Inter',
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 22 / 17,
    letterSpacing: 0,
  );
  static const TextStyle callout = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 21 / 16,
    letterSpacing: 0,
  );
  static const TextStyle subhead = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 20 / 15,
    letterSpacing: 0,
  );
  static const TextStyle footnote = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 18 / 13,
    letterSpacing: 0,
  );
  static const TextStyle caption1 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    letterSpacing: 0,
  );
  static const TextStyle caption2 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 13 / 11,
    letterSpacing: 0.06,
  );
  static const TextStyle buttonLg = TextStyle(
    fontFamily: 'Inter',
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 22 / 17,
    letterSpacing: 0.24,
  );
  static const TextStyle buttonSm = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 20 / 15,
    letterSpacing: 0.16,
  );
  static const TextStyle badge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 18 / 13,
    letterSpacing: 0.16,
  );
}

abstract final class AppBrand {
  static const String name = 'shiftboard';
  static const String fontFamily = 'Inter';
  static const String displayFontFamily = 'Inter Tight';
}
