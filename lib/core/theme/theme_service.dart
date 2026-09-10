import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service managing application theme mode with persistent saved preference per SRS.md section 8.3 & 9.3 item 6.
class ThemeService extends ChangeNotifier {
  static const String keyThemeMode = 'app_theme_mode';

  final FlutterSecureStorage _storage;
  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;

  ThemeService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;

  /// Returns true if currently set to dark mode or if system dark mode is active.
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Load and restore saved theme mode preference from storage.
  Future<void> initialize() async {
    try {
      final savedMode = await _storage.read(key: keyThemeMode);
      if (savedMode != null) {
        _themeMode = _parseThemeMode(savedMode);
      }
    } catch (_) {
      _themeMode = ThemeMode.system;
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Update theme mode and persist to storage.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    try {
      await _storage.write(key: keyThemeMode, value: mode.name);
    } catch (_) {
      // Gracefully handle storage write errors
    }
  }

  /// Convenience toggle for dark mode switch: true -> dark, false -> light.
  Future<void> toggleDarkMode(bool isDark) async {
    await setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  ThemeMode _parseThemeMode(String value) {
    switch (value.toLowerCase()) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
