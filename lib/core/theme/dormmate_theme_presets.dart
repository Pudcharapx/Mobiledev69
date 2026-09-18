import 'package:flutter/material.dart';

/// Available theme presets for DormMate (Light, Dark, and System Default).
enum DormMateThemePreset {
  system,
  light,
  dark;

  String get id => name;

  String get title {
    switch (this) {
      case DormMateThemePreset.system:
        return 'System Default';
      case DormMateThemePreset.light:
        return 'Light Theme';
      case DormMateThemePreset.dark:
        return 'Dark Theme';
    }
  }

  String get thaiTitle {
    switch (this) {
      case DormMateThemePreset.system:
        return 'ตามระบบเครื่อง (System)';
      case DormMateThemePreset.light:
        return 'โหมดสว่าง (Light)';
      case DormMateThemePreset.dark:
        return 'โหมดมืด (Dark OLED)';
    }
  }

  String get description {
    switch (this) {
      case DormMateThemePreset.system:
        return 'ปรับโหมดสว่าง/มืดตามการตั้งค่าของอุปกรณ์อัตโนมัติ';
      case DormMateThemePreset.light:
        return 'โทนสีสว่าง สะอาดตา สไตล์ Frosted Glass';
      case DormMateThemePreset.dark:
        return 'โทนสีดำลึก สนิทถนอมสายตา ประหยัดพลังงานหน้าจอ OLED';
    }
  }

  IconData get icon {
    switch (this) {
      case DormMateThemePreset.system:
        return Icons.brightness_auto_rounded;
      case DormMateThemePreset.light:
        return Icons.light_mode_rounded;
      case DormMateThemePreset.dark:
        return Icons.dark_mode_rounded;
    }
  }

  bool get isDarkModePreset => this == DormMateThemePreset.dark;

  /// Returns the corresponding [DormMatePalette].
  DormMatePalette get palette {
    switch (this) {
      case DormMateThemePreset.system:
        return DormMatePalette.light; // Default fallback
      case DormMateThemePreset.light:
        return DormMatePalette.light;
      case DormMateThemePreset.dark:
        return DormMatePalette.dark;
    }
  }

  /// Resolve palette taking into account an active system brightness if preset is [system].
  DormMatePalette resolvePalette(Brightness platformBrightness) {
    if (this == DormMateThemePreset.system) {
      return platformBrightness == Brightness.dark
          ? DormMatePalette.dark
          : DormMatePalette.light;
    }
    return palette;
  }
}

/// Concrete color palette definitions for DormMate themes.
class DormMatePalette {
  final String name;
  final Brightness brightness;
  final Color primary;
  final Color primaryDark;
  final Color accent;
  final Color background;
  final Color surface;
  final Color cardBackground;
  final Color cardBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color divider;
  final Color orb1;
  final Color orb2;
  final Color orb3;
  final List<Color> previewColors;

  const DormMatePalette({
    required this.name,
    required this.brightness,
    required this.primary,
    required this.primaryDark,
    required this.accent,
    required this.background,
    required this.surface,
    required this.cardBackground,
    required this.cardBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.divider,
    required this.orb1,
    required this.orb2,
    required this.orb3,
    required this.previewColors,
  });

  bool get isDark => brightness == Brightness.dark;

  // 1. Light Theme (Light Glassmorphic)
  static const DormMatePalette light = DormMatePalette(
    name: 'Light Glassmorphic',
    brightness: Brightness.light,
    primary: Color(0xFF5856D6), // Royal Indigo
    primaryDark: Color(0xFF1C1C1E),
    accent: Color(0xFFAF52DE), // Violet
    background: Color(0xFFF1F5F9), // Soft Slate
    surface: Colors.white,
    cardBackground: Color(0xD9FFFFFF), // 85% frosted white
    cardBorder: Color(0xE6FFFFFF),
    textPrimary: Color(0xFF0F172A), // Deep Slate
    textSecondary: Color(0xFF64748B),
    textTertiary: Color(0xFF94A3B8),
    divider: Color(0x0F000000),
    orb1: Color(0xFF38BDF8), // Sky Blue
    orb2: Color(0xFF818CF8), // Indigo
    orb3: Color(0xFF34D399), // Mint Green
    previewColors: [Color(0xFF5856D6), Color(0xFF38BDF8), Color(0xFFF1F5F9)],
  );

  // 2. Dark Mode (Midnight OLED)
  static const DormMatePalette dark = DormMatePalette(
    name: 'Midnight OLED',
    brightness: Brightness.dark,
    primary: Color(0xFF818CF8), // Luminous Violet-Indigo
    primaryDark: Color(0xFF020617),
    accent: Color(0xFF38BDF8), // Cyan
    background: Color(0xFF0B0F19), // Deep Obsidian
    surface: Color(0xFF1E293B),
    cardBackground: Color(0x661E293B), // Frosted dark slate
    cardBorder: Color(0x2EFFFFFF),
    textPrimary: Color(0xFFF8FAFC), // Bright Pearl White
    textSecondary: Color(0xFF94A3B8),
    textTertiary: Color(0xFF64748B),
    divider: Color(0x1FFFFFFF),
    orb1: Color(0xFF06B6D4), // Cyan Glow
    orb2: Color(0xFF6366F1), // Deep Violet
    orb3: Color(0xFF10B981), // Emerald Glow
    previewColors: [Color(0xFF818CF8), Color(0xFF06B6D4), Color(0xFF0B0F19)],
  );

  /// Convert to a [DormMateThemeExtension] for Flutter Material 3.
  DormMateThemeExtension toThemeExtension() {
    return DormMateThemeExtension(
      name: name,
      brightness: brightness,
      primary: primary,
      primaryDark: primaryDark,
      accent: accent,
      background: background,
      surface: surface,
      cardBackground: cardBackground,
      cardBorder: cardBorder,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      textTertiary: textTertiary,
      divider: divider,
      orb1: orb1,
      orb2: orb2,
      orb3: orb3,
    );
  }
}

/// ThemeExtension allowing any widget in the tree to access the custom DormMate palette.
class DormMateThemeExtension extends ThemeExtension<DormMateThemeExtension> {
  final String name;
  final Brightness brightness;
  final Color primary;
  final Color primaryDark;
  final Color accent;
  final Color background;
  final Color surface;
  final Color cardBackground;
  final Color cardBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color divider;
  final Color orb1;
  final Color orb2;
  final Color orb3;

  const DormMateThemeExtension({
    required this.name,
    required this.brightness,
    required this.primary,
    required this.primaryDark,
    required this.accent,
    required this.background,
    required this.surface,
    required this.cardBackground,
    required this.cardBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.divider,
    required this.orb1,
    required this.orb2,
    required this.orb3,
  });

  bool get isDark => brightness == Brightness.dark;

  static const DormMateThemeExtension light = DormMateThemeExtension(
    name: 'Light Glassmorphic',
    brightness: Brightness.light,
    primary: Color(0xFF5856D6),
    primaryDark: Color(0xFF1C1C1E),
    accent: Color(0xFFAF52DE),
    background: Color(0xFFF1F5F9),
    surface: Colors.white,
    cardBackground: Color(0xD9FFFFFF),
    cardBorder: Color(0xE6FFFFFF),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF64748B),
    textTertiary: Color(0xFF94A3B8),
    divider: Color(0x0F000000),
    orb1: Color(0xFF38BDF8),
    orb2: Color(0xFF818CF8),
    orb3: Color(0xFF34D399),
  );

  @override
  DormMateThemeExtension copyWith({
    String? name,
    Brightness? brightness,
    Color? primary,
    Color? primaryDark,
    Color? accent,
    Color? background,
    Color? surface,
    Color? cardBackground,
    Color? cardBorder,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? divider,
    Color? orb1,
    Color? orb2,
    Color? orb3,
  }) {
    return DormMateThemeExtension(
      name: name ?? this.name,
      brightness: brightness ?? this.brightness,
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      accent: accent ?? this.accent,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      cardBackground: cardBackground ?? this.cardBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      divider: divider ?? this.divider,
      orb1: orb1 ?? this.orb1,
      orb2: orb2 ?? this.orb2,
      orb3: orb3 ?? this.orb3,
    );
  }

  @override
  DormMateThemeExtension lerp(ThemeExtension<DormMateThemeExtension>? other, double t) {
    if (other is! DormMateThemeExtension) return this;
    return DormMateThemeExtension(
      name: t < 0.5 ? name : other.name,
      brightness: t < 0.5 ? brightness : other.brightness,
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t) ?? primaryDark,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t) ?? cardBackground,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t) ?? cardBorder,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t) ?? textTertiary,
      divider: Color.lerp(divider, other.divider, t) ?? divider,
      orb1: Color.lerp(orb1, other.orb1, t) ?? orb1,
      orb2: Color.lerp(orb2, other.orb2, t) ?? orb2,
      orb3: Color.lerp(orb3, other.orb3, t) ?? orb3,
    );
  }
}

/// Convenience context extension for accessing DormMate theme colors.
extension DormMateThemeContextX on BuildContext {
  DormMateThemeExtension get dormColors =>
      Theme.of(this).extension<DormMateThemeExtension>() ?? DormMateThemeExtension.light;
  bool get isDormDark => Theme.of(this).brightness == Brightness.dark;
}
