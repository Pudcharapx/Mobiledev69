import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/dormmate_theme_presets.dart';

/// An ambient glowing mesh background that creates rich color tones
/// and luminous depth for Glassmorphism frosted glass elements to blur against.
/// Dynamically adapts to the active [DormMateThemeExtension].
class AmbientMeshBackground extends StatelessWidget {
  final Widget child;
  final bool animate;

  const AmbientMeshBackground({
    super.key,
    required this.child,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<DormMateThemeExtension>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Color> bgGradientColors;
    if (themeExt != null) {
      if (themeExt.isDark) {
        bgGradientColors = [
          themeExt.background,
          themeExt.surface,
          const Color(0xFF020617),
        ];
      } else {
        bgGradientColors = [
          themeExt.background,
          Color.lerp(themeExt.background, themeExt.surface, 0.6) ?? themeExt.background,
          const Color(0xFFF8FAFC),
        ];
      }
    } else {
      bgGradientColors = isDark
          ? const [
              Color(0xFF0B0F19), // Deep Obsidian
              Color(0xFF0F172A), // Midnight Slate
              Color(0xFF020617), // Deep Navy
            ]
          : const [
              Color(0xFFF1F5F9), // Soft Slate
              Color(0xFFE2E8F0), // Pearl
              Color(0xFFF8FAFC), // Pure Mist
            ];
    }

    // On Web CanvasKit, avoid multiple giant offscreen radial gradients to prevent WebGL context loss
    if (kIsWeb) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF0B0F19),
                    Color(0xFF131B2E),
                    Color(0xFF0F172A),
                    Color(0xFF020617),
                  ]
                : const [
                    Color(0xFFF1F5F9),
                    Color(0xFFE8EEF5),
                    Color(0xFFE2E8F0),
                    Color(0xFFF8FAFC),
                  ],
          ),
        ),
        child: child,
      );
    }

    final Color orb1Color = themeExt?.orb1 ?? (isDark ? const Color(0xFF06B6D4) : const Color(0xFF38BDF8));
    final Color orb2Color = themeExt?.orb2 ?? (isDark ? const Color(0xFF6366F1) : const Color(0xFF818CF8));
    final Color orb3Color = themeExt?.orb3 ?? (isDark ? const Color(0xFF10B981) : const Color(0xFF34D399));

    return Stack(
      children: [
        // Base canvas gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: bgGradientColors,
              ),
            ),
          ),
        ),

        // Glowing Orb 1: Top-Right (Accent 1 Glow)
        Positioned(
          top: -80,
          right: -80,
          width: 320,
          height: 320,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  orb1Color.withValues(alpha: isDark ? 0.28 : 0.20),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.75],
              ),
            ),
          ),
        ),

        // Glowing Orb 2: Center-Left (Accent 2 Glow)
        Positioned(
          top: 220,
          left: -100,
          width: 340,
          height: 340,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  orb2Color.withValues(alpha: isDark ? 0.25 : 0.16),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.8],
              ),
            ),
          ),
        ),

        // Glowing Orb 3: Bottom-Right (Accent 3 Glow)
        Positioned(
          bottom: -60,
          right: -60,
          width: 360,
          height: 360,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  orb3Color.withValues(alpha: isDark ? 0.22 : 0.15),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.75],
              ),
            ),
          ),
        ),

        // Content
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}
