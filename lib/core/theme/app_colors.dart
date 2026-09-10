import 'package:flutter/material.dart';

/// App color palette matching the aesthetic direction described in SRS.md section 9.
class AppColors {
  AppColors._();

  // Primary brand accents
  static const Color primary = Color(0xFF1E293B); // Dark slate
  static const Color primaryLight = Color(0xFF334155);
  static const Color accent = Color(0xFF6366F1); // Indigo

  // Light Theme Surfaces
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Colors.white;
  static const Color cardLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Dark Theme Surfaces
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF334155);

  // Heatmap Gradient (Red -> Yellow -> Green) per SRS 8.1 & 9.1
  static const Color heatmapUnderTrained = Color(0xFFEF4444); // Red (<50%)
  static const Color heatmapModerate = Color(0xFFF59E0B);     // Amber/Yellow (50-79%)
  static const Color heatmapOptimal = Color(0xFF10B981);      // Green (80-100%)
  static const Color heatmapOverTrained = Color(0xFF059669);  // Deep Emerald (>100%)
  static const Color heatmapDefault = Color(0xFFCBD5E1);      // Inactive zone

  // Imbalance Alert Colors per SRS 8.2 & 9.2
  static const Color alertWarning = Color(0xFFF97316); // Vibrant orange
  static const Color alertWarningBg = Color(0xFFFFF7ED);
  static const Color alertWarningBgDark = Color(0xFF431407);

  // Feature Card Colors per SRS 9.2
  static const Color darkFeatureCardBg = Color(0xFF0F172A);
  static const Color darkFeatureCardText = Colors.white;

  /// Map training completion percentage (0.0 to 1.0+) to heatmap color.
  static Color colorForCompletion(double percentage) {
    if (percentage <= 0.0) return heatmapDefault;
    if (percentage < 0.5) return heatmapUnderTrained;
    if (percentage < 0.8) return heatmapModerate;
    if (percentage <= 1.2) return heatmapOptimal;
    return heatmapOverTrained;
  }
}
