import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/theme/dormmate_theme_presets.dart';
import 'package:project/core/theme/dormmate_theme_service.dart';

class MockStorage extends FlutterSecureStorage {
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
  group('DormMateThemeService Tests', () {
    late MockStorage storage;
    late DormMateThemeService service;

    setUp(() {
      storage = MockStorage();
      service = DormMateThemeService(storage: storage);
    });

    test('defaults to DormMateThemePreset.light before initialization', () {
      expect(service.preset, equals(DormMateThemePreset.light));
      expect(service.themeMode, equals(ThemeMode.light));
      expect(service.isDarkMode, isFalse);
    });

    test('setPreset updates preset and persists preference to storage', () async {
      await service.setPreset(DormMateThemePreset.dark);
      expect(service.preset, equals(DormMateThemePreset.dark));
      expect(service.themeMode, equals(ThemeMode.dark));
      expect(service.isDarkMode, isTrue);
      expect(storage.data[DormMateThemeService.keyPreset], equals('dark'));

      await service.setPreset(DormMateThemePreset.light);
      expect(service.preset, equals(DormMateThemePreset.light));
      expect(service.themeMode, equals(ThemeMode.light));
      expect(service.isDarkMode, isFalse);
      expect(storage.data[DormMateThemeService.keyPreset], equals('light'));
    });

    test('toggleDarkMode toggles between dark and light presets', () async {
      await service.toggleDarkMode(true);
      expect(service.preset, equals(DormMateThemePreset.dark));
      expect(service.themeMode, equals(ThemeMode.dark));
      expect(service.isDarkMode, isTrue);

      await service.toggleDarkMode(false);
      expect(service.preset, equals(DormMateThemePreset.light));
      expect(service.themeMode, equals(ThemeMode.light));
      expect(service.isDarkMode, isFalse);
    });

    test('initialize restores saved preset from storage', () async {
      storage.data[DormMateThemeService.keyPreset] = 'dark';

      final newService = DormMateThemeService(storage: storage);
      await newService.initialize();

      expect(newService.isInitialized, isTrue);
      expect(newService.preset, equals(DormMateThemePreset.dark));
      expect(newService.activePalette.name, equals('Midnight OLED'));
    });

    test('provides valid lightTheme and darkTheme ThemeData', () {
      final light = service.lightTheme;
      final dark = service.darkTheme;

      expect(light.brightness, equals(Brightness.light));
      expect(dark.brightness, equals(Brightness.dark));
      expect(light.extensions.isNotEmpty, isTrue);
      expect(dark.extensions.isNotEmpty, isTrue);
    });
  });
}
