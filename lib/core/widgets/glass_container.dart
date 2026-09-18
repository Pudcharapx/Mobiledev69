import 'dart:ui';
import 'package:flutter/material.dart';

/// A versatile, luxury Glassmorphism container featuring:
/// - Real-time frosted glass backdrop blur ([BackdropFilter])
/// - Subtle specular gradient border simulating glass refraction
/// - Deep multi-layer soft ambient shadow
/// - Smooth rounded corners ([borderRadius])
class GlassContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final double borderWidth;
  final Color? color;
  final Color? borderColor;
  final double? opacity;
  final Gradient? gradient;
  final Gradient? borderGradient;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final AlignmentGeometry? alignment;

  const GlassContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 24.0,
    this.blur = 16.0,
    this.borderWidth = 1.2,
    this.color,
    this.borderColor,
    this.opacity,
    this.gradient,
    this.borderGradient,
    this.shadows,
    this.onTap,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Default specular border gradient: bright highlight at top-left, fading down
    final defaultBorderGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              Colors.white.withValues(alpha: 0.35),
              Colors.white.withValues(alpha: 0.08),
              Colors.black.withValues(alpha: 0.15),
            ]
          : [
              Colors.white.withValues(alpha: 0.85),
              Colors.white.withValues(alpha: 0.25),
              const Color(0xFF6366F1).withValues(alpha: 0.15),
            ],
      stops: const [0.0, 0.6, 1.0],
    );

    // Default glass surface fill gradient
    final defaultSurfaceGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              Colors.white.withValues(alpha: 0.12),
              Colors.white.withValues(alpha: 0.04),
            ]
          : [
              Colors.white.withValues(alpha: 0.70),
              Colors.white.withValues(alpha: 0.40),
            ],
    );

    // Default soft floating shadow
    final defaultShadows = [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.35)
            : const Color(0xFF0F172A).withValues(alpha: 0.08),
        blurRadius: 24,
        spreadRadius: -2,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.20)
            : const Color(0xFF0F172A).withValues(alpha: 0.04),
        blurRadius: 8,
        spreadRadius: -1,
        offset: const Offset(0, 4),
      ),
    ];

    final effectiveRadius = BorderRadius.circular(borderRadius);

    Widget content = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        boxShadow: shadows ?? defaultShadows,
      ),
      child: Container(
        // Outer layer creates the specular gradient border
        decoration: BoxDecoration(
          borderRadius: effectiveRadius,
          gradient: borderGradient ??
              (borderColor != null
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        borderColor!,
                        borderColor!.withValues(alpha: 0.4),
                      ],
                    )
                  : defaultBorderGradient),
        ),
        padding: EdgeInsets.all(borderWidth),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            (borderRadius - borderWidth).clamp(0.0, double.infinity),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              alignment: alignment,
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  (borderRadius - borderWidth).clamp(0.0, double.infinity),
                ),
                color: color != null && opacity != null
                    ? color!.withValues(alpha: opacity!)
                    : color,
                gradient: color == null
                    ? (gradient ??
                        (opacity != null
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isDark
                                    ? [
                                        Colors.white.withValues(
                                            alpha: (0.12 * opacity!)
                                                .clamp(0.0, 1.0)),
                                        Colors.white.withValues(
                                            alpha: (0.04 * opacity!)
                                                .clamp(0.0, 1.0)),
                                      ]
                                    : [
                                        Colors.white.withValues(
                                            alpha: (0.70 * opacity!)
                                                .clamp(0.0, 1.0)),
                                        Colors.white.withValues(
                                            alpha: (0.40 * opacity!)
                                                .clamp(0.0, 1.0)),
                                      ],
                              )
                            : defaultSurfaceGradient))
                    : null,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: effectiveRadius,
          onTap: onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Pre-styled Glassmorphism Card for dashboards, forms, and feature lists.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Color? tintColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20.0),
    this.margin,
    this.borderRadius = 24.0,
    this.blur = 16.0,
    this.tintColor,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      padding: padding,
      borderRadius: borderRadius,
      blur: blur,
      borderColor: borderColor,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          (tintColor ?? (isDark ? Colors.white : Colors.white)).withValues(
            alpha: isDark ? 0.12 : 0.75,
          ),
          (tintColor ?? (isDark ? Colors.white : Colors.white)).withValues(
            alpha: isDark ? 0.04 : 0.45,
          ),
        ],
      ),
      onTap: onTap,
      child: child,
    );
  }
}

/// An interactive Glassmorphism Button with subtle glow and specular border.
class GlassButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget? icon;
  final String? label;
  final Widget? child;
  final Color? accentColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool isLoading;

  const GlassButton({
    super.key,
    required this.onPressed,
    this.icon,
    this.label,
    this.child,
    this.accentColor,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    this.isLoading = false,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = widget.accentColor ?? (isDark ? const Color(0xFF6366F1) : const Color(0xFF1E293B));

    final baseAlpha = _isPressed
        ? 0.35
        : (_isHovered ? 0.25 : 0.15);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: GlassContainer(
            borderRadius: widget.borderRadius,
            blur: 14.0,
            borderWidth: 1.2,
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: _isHovered ? 0.6 : 0.4),
                accent.withValues(alpha: _isHovered ? 0.4 : 0.2),
              ],
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withValues(alpha: baseAlpha + 0.08),
                accent.withValues(alpha: baseAlpha),
              ],
            ),
            shadows: [
              BoxShadow(
                color: accent.withValues(alpha: _isHovered ? 0.30 : 0.15),
                blurRadius: _isHovered ? 20 : 12,
                offset: const Offset(0, 4),
              ),
            ],
            padding: widget.padding,
            child: widget.isLoading
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : widget.child ??
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          widget.icon!,
                          const SizedBox(width: 8),
                        ],
                        if (widget.label != null)
                          Flexible(
                            child: Text(
                              widget.label!,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}
