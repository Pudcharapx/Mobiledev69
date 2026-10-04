import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/dormmate_constants.dart';
import 'dormmate_theme_presets.dart';
import 'dormmate_theme.dart';

/// State management service for DormMate themes and appearance preferences.
/// Persists user theme choice via FlutterSecureStorage.
class DormMateThemeService extends ChangeNotifier {
  static const String keyPreset = 'dormmate_theme_preset';

  final FlutterSecureStorage _storage;
  DormMateThemePreset _preset = DormMateThemePreset.light;
  bool _isInitialized = false;

  DormMateThemeService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  DormMateThemePreset get preset => _preset;
  bool get isInitialized => _isInitialized;

  /// Returns Flutter's [ThemeMode] based on current preset.
  ThemeMode get themeMode {
    switch (_preset) {
      case DormMateThemePreset.system:
        return ThemeMode.system;
      case DormMateThemePreset.dark:
        return ThemeMode.dark;
      case DormMateThemePreset.light:
        return ThemeMode.light;
    }
  }

  /// Whether current active preset is a dark palette.
  bool get isDarkMode => _preset.isDarkModePreset;

  /// Active palette definition.
  DormMatePalette get activePalette => _preset.palette;

  /// Light theme definition configured with the current preset.
  ThemeData get lightTheme => buildDormMateTheme(
        preset: _preset,
        overrideBrightness: Brightness.light,
      );

  /// Dark theme definition configured with the current preset.
  ThemeData get darkTheme => buildDormMateTheme(
        preset: _preset,
        overrideBrightness: Brightness.dark,
      );

  /// Load and restore saved theme preset preference.
  Future<void> initialize() async {
    try {
      final savedPreset = await _storage.read(key: keyPreset);
      if (savedPreset != null) {
        _preset = _parsePreset(savedPreset);
      } else {
        _preset = DormMateThemePreset.light;
      }
    } catch (_) {
      _preset = DormMateThemePreset.light;
    } finally {
      _isInitialized = true;
      DormMateColors.isDark = isDarkMode;
      notifyListeners();
    }
  }

  /// Change active theme preset and persist selection.
  Future<void> setPreset(DormMateThemePreset newPreset) async {
    if (_preset == newPreset) return;
    _preset = newPreset;
    DormMateColors.isDark = isDarkMode;
    notifyListeners();

    try {
      await _storage.write(key: keyPreset, value: newPreset.id);
    } catch (_) {
      // Gracefully handle storage write failures
    }
  }

  /// Quick toggle between light mode and dark mode.
  Future<void> toggleDarkMode(bool isDark) async {
    DormMateColors.isDark = isDark;
    if (isDark) {
      await setPreset(DormMateThemePreset.dark);
    } else {
      await setPreset(DormMateThemePreset.light);
    }
  }

  DormMateThemePreset _parsePreset(String value) {
    for (final p in DormMateThemePreset.values) {
      if (p.id.toLowerCase() == value.toLowerCase()) {
        return p;
      }
    }
    return DormMateThemePreset.light;
  }
}
