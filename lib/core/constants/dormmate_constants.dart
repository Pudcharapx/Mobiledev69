import 'package:flutter/material.dart';

class DormMateColors {
  DormMateColors._();

  /// Reactive flag reflecting whether Dark Mode is currently active.
  static bool isDark = false;

  // Backgrounds & Surfaces
  static Color get background => isDark ? const Color(0xFF0B0F19) : const Color(0xFFF5F5F7);
  static Color get surfaceWhite => isDark ? const Color(0xFF1E293B) : Colors.white;

  // Brand Accents
  static Color get primary => isDark ? const Color(0xFF818CF8) : const Color(0xFF5856D6); // Indigo
  static Color get primaryDark => isDark ? const Color(0xFF6366F1) : const Color(0xFF1C1C1E);
  static Color get accent => isDark ? const Color(0xFF38BDF8) : const Color(0xFFAF52DE); // Purple/Cyan

  // Typography - High contrast, beautifully readable in both Light & Dark modes!
  static Color get textPrimary => isDark ? const Color(0xFFF8FAFC) : const Color(0xFF111111);
  static Color get textSecondary => isDark ? const Color(0xFF94A3B8) : const Color(0xFF6E6E73);
  static Color get textTertiary => isDark ? const Color(0xFF64748B) : const Color(0xFFAEAEB2);
  static Color get textDisabled => isDark ? const Color(0xFF475569) : const Color(0xFFC7C7CC);

  // Subtle frosted divider
  static Color get divider => isDark ? const Color(0x1FFFFFFF) : const Color(0x0F000000);

  // Status badges - high contrast in dark mode
  static Color get statusPending => const Color(0xFFFF9800);
  static Color get statusPendingBg => isDark ? const Color(0x33FF9800) : const Color(0xFFFFF3E0);
  static Color get statusPendingText => isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100);

  static Color get statusInProgress => const Color(0xFF2196F3);
  static Color get statusInProgressBg => isDark ? const Color(0x332196F3) : const Color(0xFFE3F2FD);
  static Color get statusInProgressText => isDark ? const Color(0xFF64B5F6) : const Color(0xFF1565C0);

  static Color get statusCompleted => const Color(0xFF4CAF50);
  static Color get statusCompletedBg => isDark ? const Color(0x334CAF50) : const Color(0xFFE8F5E9);
  static Color get statusCompletedText => isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32);

  static Color get statusError => const Color(0xFFF44336);
  static Color get statusErrorBg => isDark ? const Color(0x33F44336) : const Color(0xFFFFEBEE);
  static Color get statusErrorText => isDark ? const Color(0xFFE57373) : const Color(0xFFC62828);

  // Glass card
  static Color get glassBackground => isDark ? const Color(0x661E293B) : const Color(0xB8FFFFFF);
  static Color get glassBorder => isDark ? const Color(0x2EFFFFFF) : const Color(0xE6FFFFFF);
}

class DormMateTextStyles {
  DormMateTextStyles._();

  static TextStyle get largeTitle => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: DormMateColors.textPrimary,
    letterSpacing: -0.8,
  );

  static TextStyle get title => TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: DormMateColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle get sectionTitle => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: DormMateColors.textPrimary,
  );

  static TextStyle get cardValue => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: DormMateColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle get body => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: DormMateColors.textPrimary,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: DormMateColors.textPrimary,
  );

  static TextStyle get caption => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: DormMateColors.textSecondary,
  );

  static TextStyle get label => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: DormMateColors.textTertiary,
    letterSpacing: 0.8,
  );
}

class DormMateDimens {
  DormMateDimens._();

  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 24.0;
}
