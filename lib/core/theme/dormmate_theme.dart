import 'package:flutter/material.dart';
import '../constants/dormmate_constants.dart';
import 'dormmate_theme_presets.dart';

/// Builds a customized Material 3 [ThemeData] for DormMate according to [DormMateThemePreset].
ThemeData buildDormMateTheme({
  DormMateThemePreset preset = DormMateThemePreset.light,
  Brightness? overrideBrightness,
}) {
  final Brightness targetBrightness;
  if (overrideBrightness != null) {
    targetBrightness = overrideBrightness;
  } else if (preset == DormMateThemePreset.system) {
    targetBrightness = Brightness.light;
  } else {
    targetBrightness = preset.palette.brightness;
  }

  final DormMatePalette palette = preset == DormMateThemePreset.system
      ? (targetBrightness == Brightness.dark ? DormMatePalette.dark : DormMatePalette.light)
      : preset.palette;

  final isDark = targetBrightness == Brightness.dark;

  return ThemeData(
    useMaterial3: true,
    brightness: targetBrightness,
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: ColorScheme(
      brightness: targetBrightness,
      primary: palette.primary,
      onPrimary: Colors.white,
      secondary: palette.accent,
      onSecondary: Colors.white,
      error: DormMateColors.statusError,
      onError: Colors.white,
      surface: palette.surface,
      onSurface: palette.textPrimary,
      outline: palette.divider,
    ),
    extensions: [
      palette.toThemeExtension(),
    ],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: palette.textPrimary),
      titleTextStyle: DormMateTextStyles.sectionTitle.copyWith(
        color: palette.textPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: palette.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DormMateDimens.radiusMd),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: palette.primary,
        side: BorderSide(color: palette.primary.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DormMateDimens.radiusMd),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: palette.divider,
      thickness: 1,
      space: 1,
    ),
    cardTheme: CardThemeData(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DormMateDimens.radiusLg),
      ),
    ),
    canvasColor: isDark ? const Color(0xFF1E293B) : Colors.white,
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      modalBackgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DormMateDimens.radiusLg),
      ),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: palette.textPrimary,
      ),
      contentTextStyle: TextStyle(
        fontSize: 14,
        color: palette.textSecondary,
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: palette.textPrimary),
      bodyMedium: TextStyle(color: palette.textPrimary),
      bodySmall: TextStyle(color: palette.textSecondary),
      titleLarge: TextStyle(color: palette.textPrimary, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(color: palette.textPrimary, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: palette.textSecondary, fontWeight: FontWeight.w600),
      labelLarge: TextStyle(color: palette.textPrimary, fontWeight: FontWeight.w600),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0x331E293B) : const Color(0xD9FFFFFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DormMateDimens.radiusMd),
        borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0x14000000)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DormMateDimens.radiusMd),
        borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0x14000000)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DormMateDimens.radiusMd),
        borderSide: BorderSide(color: palette.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: TextStyle(
        fontSize: 13,
        color: palette.textTertiary,
      ),
    ),
  );
}
