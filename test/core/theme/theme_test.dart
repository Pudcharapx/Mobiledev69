import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/theme/app_colors.dart';
import 'package:project/core/theme/app_theme.dart';

void main() {
  group('AppColors Tests', () {
    test('colorForCompletion maps percentages to heatmap colors', () {
      expect(AppColors.colorForCompletion(0.0), AppColors.heatmapDefault);
      expect(AppColors.colorForCompletion(0.4), AppColors.heatmapUnderTrained);
      expect(AppColors.colorForCompletion(0.75), AppColors.heatmapModerate);
      expect(AppColors.colorForCompletion(1.0), AppColors.heatmapOptimal);
      expect(AppColors.colorForCompletion(1.3), AppColors.heatmapOverTrained);
    });
  });

  group('AppTheme Tests', () {
    test('lightTheme has expected brightness and colors', () {
      final light = AppTheme.lightTheme;
      expect(light.brightness, Brightness.light);
      expect(light.useMaterial3, isTrue);
      expect(light.scaffoldBackgroundColor, AppColors.backgroundLight);
    });

    test('darkTheme has expected brightness and colors', () {
      final dark = AppTheme.darkTheme;
      expect(dark.brightness, Brightness.dark);
      expect(dark.useMaterial3, isTrue);
      expect(dark.scaffoldBackgroundColor, AppColors.backgroundDark);
    });
  });
}
