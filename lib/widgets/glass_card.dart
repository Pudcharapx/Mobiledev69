import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/constants/dormmate_constants.dart';
import '../core/theme/dormmate_theme_presets.dart';
import 'app_animations.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Border? border;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin = const EdgeInsets.only(bottom: 12),
    this.borderRadius = DormMateDimens.radiusLg,
    this.backgroundColor,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<DormMateThemeExtension>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = backgroundColor ??
        themeExt?.cardBackground ??
        (isDark ? const Color(0x661E293B) : DormMateColors.glassBackground);

    final cardBorder = border ??
        Border.all(
          color: themeExt?.cardBorder ??
              (isDark ? const Color(0x2EFFFFFF) : DormMateColors.glassBorder),
          width: 1.0,
        );

    final shadowColor = isDark ? const Color(0x33000000) : const Color(0x0A000000);

    final decoration = BoxDecoration(
      color: cardBg,
      borderRadius: BorderRadius.circular(borderRadius),
      border: cardBorder,
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );

    // On Web, avoid multiple nested BackdropFilter allocations to prevent WebGL context loss
    Widget card = kIsWeb
        ? Container(
            padding: padding,
            decoration: decoration,
            child: child,
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: padding,
                decoration: decoration,
                child: child,
              ),
            ),
          );

    if (onTap != null) {
      card = PressableScale(
        onTap: onTap,
        child: card,
      );
    }

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    return card;
  }
}
