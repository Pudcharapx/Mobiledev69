import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/theme/theme_service.dart';

class FakeStorage extends FlutterSecureStorage {
  final Map<String, String> data = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      data[key] = value;
    } else {
      data.remove(key);
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return data[key];
  }
}

void main() {
  group('ThemeService Saved Preference Tests (SRS 8.3)', () {
    late FakeStorage storage;
    late ThemeService themeService;

    setUp(() {
      storage = FakeStorage();
      themeService = ThemeService(storage: storage);
    });

    test('defaults to ThemeMode.system before initialization', () {
      expect(themeService.themeMode, equals(ThemeMode.system));
      expect(themeService.isDarkMode, isFalse);
    });

    test('setThemeMode updates theme and persists preference in storage', () async {
      await themeService.setThemeMode(ThemeMode.dark);
      expect(themeService.themeMode, equals(ThemeMode.dark));
      expect(themeService.isDarkMode, isTrue);
      expect(storage.data[ThemeService.keyThemeMode], equals('dark'));

      await themeService.setThemeMode(ThemeMode.light);
      expect(themeService.themeMode, equals(ThemeMode.light));
      expect(themeService.isDarkMode, isFalse);
      expect(storage.data[ThemeService.keyThemeMode], equals('light'));
    });

    test('toggleDarkMode toggles between dark and light modes', () async {
      await themeService.toggleDarkMode(true);
      expect(themeService.themeMode, equals(ThemeMode.dark));
      expect(storage.data[ThemeService.keyThemeMode], equals('dark'));

      await themeService.toggleDarkMode(false);
      expect(themeService.themeMode, equals(ThemeMode.light));
      expect(storage.data[ThemeService.keyThemeMode], equals('light'));
    });

    test('initialize restores saved dark theme mode from storage', () async {
      storage.data[ThemeService.keyThemeMode] = 'dark';

      final service = ThemeService(storage: storage);
      await service.initialize();

      expect(service.isInitialized, isTrue);
      expect(service.themeMode, equals(ThemeMode.dark));
      expect(service.isDarkMode, isTrue);
    });

    test('initialize restores saved light theme mode from storage', () async {
      storage.data[ThemeService.keyThemeMode] = 'light';

      final service = ThemeService(storage: storage);
      await service.initialize();

      expect(service.isInitialized, isTrue);
      expect(service.themeMode, equals(ThemeMode.light));
      expect(service.isDarkMode, isFalse);
    });
  });
}
