import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/theme/dormmate_theme_presets.dart';

void main() {
  group('DormMateThemePreset Tests', () {
    test('has light, dark, and system theme presets', () {
      expect(DormMateThemePreset.values.length, equals(3));
      expect(DormMateThemePreset.values, contains(DormMateThemePreset.system));
      expect(DormMateThemePreset.values, contains(DormMateThemePreset.light));
      expect(DormMateThemePreset.values, contains(DormMateThemePreset.dark));
    });

    test('each preset has valid titles, descriptions, and icons', () {
      for (final preset in DormMateThemePreset.values) {
        expect(preset.title.isNotEmpty, isTrue);
        expect(preset.thaiTitle.isNotEmpty, isTrue);
        expect(preset.description.isNotEmpty, isTrue);
        expect(preset.icon, isNotNull);
      }
    });

    test('isDarkModePreset correctly identifies dark presets', () {
      expect(DormMateThemePreset.dark.isDarkModePreset, isTrue);
      expect(DormMateThemePreset.light.isDarkModePreset, isFalse);
      expect(DormMateThemePreset.system.isDarkModePreset, isFalse);
    });

    test('resolvePalette resolves system preset to light or dark based on platform', () {
      expect(
        DormMateThemePreset.system.resolvePalette(Brightness.light),
        equals(DormMatePalette.light),
      );
      expect(
        DormMateThemePreset.system.resolvePalette(Brightness.dark),
        equals(DormMatePalette.dark),
      );
      expect(
        DormMateThemePreset.light.resolvePalette(Brightness.dark),
        equals(DormMatePalette.light),
      );
    });

    test('palettes have valid ambient mesh orb colors and swatches', () {
      final palettes = [
        DormMatePalette.light,
        DormMatePalette.dark,
      ];

      for (final p in palettes) {
        expect(p.primary, isNotNull);
        expect(p.background, isNotNull);
        expect(p.orb1, isNotNull);
        expect(p.orb2, isNotNull);
        expect(p.orb3, isNotNull);
        expect(p.previewColors.length, equals(3));
      }
    });

    test('toThemeExtension converts palette into DormMateThemeExtension with lerp support', () {
      final ext = DormMatePalette.light.toThemeExtension();
      expect(ext.name, equals('Light Glassmorphic'));
      expect(ext.brightness, equals(Brightness.light));

      final darkExt = DormMatePalette.dark.toThemeExtension();
      final lerped = ext.lerp(darkExt, 0.5);
      expect(lerped, isA<DormMateThemeExtension>());
      expect(lerped.primary, isNotNull);
    });
  });
}
