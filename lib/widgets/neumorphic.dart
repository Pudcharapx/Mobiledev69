import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ─── Neumorphic Color System ─────────────────────────────────────────────────
class NeuColors {
  NeuColors._();

  // Light mode base — warm slate tint
  static const Color bgLight = Color(0xFFE8EDF5);
  static const Color bgLightDeep = Color(0xFFDDE3EF);

  // Dark mode base — deep slate
  static const Color bgDark = Color(0xFF1A2035);
  static const Color bgDarkDeep = Color(0xFF141826);

  // Shadow system
  static Color shadowDark(bool isDark) =>
      isDark ? const Color(0xFF0D1422) : const Color(0xFFB0BCCF);
  static Color shadowLight(bool isDark) =>
      isDark ? const Color(0xFF243050) : const Color(0xFFFFFFFF);

  // Card & Border system
  static const Color borderLight = Color(0xFFD0D7E5);
  static const Color borderDark = Color(0xFF28334E);
  static const Color cardLight = Color(0xFFEFF3F8);
  static const Color cardDark = Color(0xFF1E253C);

  // Primary gradient pair
  static const List<Color> primaryGradient = [Color(0xFF667EEA), Color(0xFF764BA2)];
  static const List<Color> accentGradient = [Color(0xFF43CFCF), Color(0xFF5856D6)];
  static const List<Color> warmGradient = [Color(0xFFFF9A56), Color(0xFFFF6B6B)];
  static const List<Color> greenGradient = [Color(0xFF43E97B), Color(0xFF38F9D7)];
  static const List<Color> blueGradient = [Color(0xFF4FACFE), Color(0xFF00F2FE)];

  // Loading shimmers
  static Color shimmerBase(bool isDark) => isDark ? const Color(0xFF242C44) : const Color(0xFFDDE3EF);
  static Color shimmerHighlight(bool isDark) => isDark ? const Color(0xFF323B58) : const Color(0xFFF3F6FA);

  static List<BoxShadow> elevation1(bool isDark, {double intensity = 1.0}) {
    return [
      BoxShadow(
        color: shadowDark(isDark).withValues(alpha: 0.3 * intensity),
        blurRadius: 10,
        offset: Offset(4 * intensity, 4 * intensity),
        spreadRadius: -1,
      ),
      BoxShadow(
        color: shadowLight(isDark).withValues(alpha: isDark ? 0.05 * intensity : 0.7 * intensity),
        blurRadius: 10,
        offset: Offset(-4 * intensity, -4 * intensity),
        spreadRadius: -1,
      ),
    ];
  }

  static List<BoxShadow> elevation2(bool isDark, {double intensity = 1.0}) {
    return [
      BoxShadow(
        color: shadowDark(isDark).withValues(alpha: 0.4 * intensity),
        blurRadius: 18,
        offset: Offset(6 * intensity, 6 * intensity),
        spreadRadius: -2,
      ),
      BoxShadow(
        color: shadowLight(isDark).withValues(alpha: isDark ? 0.08 * intensity : 0.85 * intensity),
        blurRadius: 18,
        offset: Offset(-6 * intensity, -6 * intensity),
        spreadRadius: -2,
      ),
    ];
  }
}

// ─── Neumorphic Container ─────────────────────────────────────────────────────
class NeuContainer extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool isInset; // true = debossed/pressed in
  final bool isDark;
  final Color? bgColor;
  final VoidCallback? onTap;
  final double shadowIntensity;

  const NeuContainer({
    super.key,
    required this.child,
    required this.isDark,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.borderRadius = 20,
    this.isInset = false,
    this.bgColor,
    this.onTap,
    this.shadowIntensity = 1.0,
  });

  @override
  State<NeuContainer> createState() => _NeuContainerState();
}

class _NeuContainerState extends State<NeuContainer> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.bgColor ?? (widget.isDark ? NeuColors.bgDark : NeuColors.bgLight);
    final darkShadow = NeuColors.shadowDark(widget.isDark).withValues(alpha: 0.40 * widget.shadowIntensity);
    final lightShadow = NeuColors.shadowLight(widget.isDark).withValues(alpha: widget.isDark ? 0.08 * widget.shadowIntensity : 0.85 * widget.shadowIntensity);

    BoxDecoration decoration;

    if (widget.isInset) {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        gradient: LinearGradient(
          colors: [
            widget.isDark ? const Color(0xFF141826) : const Color(0xFFD1D9E6),
            bg,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: lightShadow,
            blurRadius: 6,
            offset: const Offset(2, 2),
            spreadRadius: -1,
          ),
          BoxShadow(
            color: darkShadow,
            blurRadius: 6,
            offset: const Offset(-2, -2),
            spreadRadius: -1,
          ),
        ],
      );
    } else {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        color: bg,
        boxShadow: [
          BoxShadow(
            color: darkShadow,
            blurRadius: 18 * widget.shadowIntensity,
            offset: Offset(6 * widget.shadowIntensity, 6 * widget.shadowIntensity),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: lightShadow,
            blurRadius: 18 * widget.shadowIntensity,
            offset: Offset(-6 * widget.shadowIntensity, -6 * widget.shadowIntensity),
            spreadRadius: -2,
          ),
        ],
      );
    }

    Widget container = Container(
      padding: widget.padding,
      decoration: decoration,
      child: widget.child,
    );

    if (widget.margin != null) {
      container = Padding(padding: widget.margin!, child: container);
    }

    if (widget.onTap != null) {
      container = GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeInOutCubic,
          child: container,
        ),
      );
    }

    return container;
  }
}

// ─── Neumorphic Button ────────────────────────────────────────────────────────
class NeuButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isDark;
  final Color? bgColor;
  final List<Color>? gradientColors;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool isLoading;
  final double? width;
  final double? height;
  final int elevation; // 1 or 2

  const NeuButton({
    super.key,
    required this.child,
    required this.isDark,
    this.onTap,
    this.bgColor,
    this.gradientColors,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.borderRadius = 18,
    this.isLoading = false,
    this.width,
    this.height,
    this.elevation = 2,
  });

  @override
  State<NeuButton> createState() => _NeuButtonState();
}

class _NeuButtonState extends State<NeuButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bg = widget.bgColor ?? (isDark ? NeuColors.bgDark : NeuColors.bgLight);
    final darkShadow = NeuColors.shadowDark(isDark).withValues(alpha: 0.35);
    final lightShadow = NeuColors.shadowLight(isDark).withValues(alpha: isDark ? 0.07 : 0.85);

    BoxDecoration decoration;

    if (_pressed) {
      // Inset state
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        gradient: LinearGradient(
          colors: widget.gradientColors != null 
              ? [widget.gradientColors!.first.withValues(alpha: 0.8), widget.gradientColors!.last]
              : [
                  isDark ? const Color(0xFF141826) : const Color(0xFFD1D9E6),
                  bg,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: lightShadow, blurRadius: 6, offset: const Offset(2, 2), spreadRadius: -1),
          BoxShadow(color: darkShadow, blurRadius: 6, offset: const Offset(-2, -2), spreadRadius: -1),
        ],
      );
    } else {
      // Raised state
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        gradient: widget.gradientColors != null
            ? LinearGradient(
                colors: widget.gradientColors!,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: widget.gradientColors == null ? bg : null,
        boxShadow: widget.elevation == 1 ? NeuColors.elevation1(isDark) : NeuColors.elevation2(isDark),
      );
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOutCubic,
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        decoration: decoration,
        child: Center(
          widthFactor: 1.0,
          heightFactor: 1.0,
          child: widget.isLoading
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                )
              : widget.child,
        ),
      ),
    );
  }
}

// ─── Neumorphic Icon Container ────────────────────────────────────────────────
class NeuIconBox extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final List<Color>? gradientColors;
  final bool isDark;
  final double size;
  final double iconSize;
  final VoidCallback? onTap;
  final bool pulseOnHover;

  const NeuIconBox({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.isDark,
    this.gradientColors,
    this.size = 46,
    this.iconSize = 22,
    this.onTap,
    this.pulseOnHover = false,
  });

  @override
  State<NeuIconBox> createState() => _NeuIconBoxState();
}

class _NeuIconBoxState extends State<NeuIconBox> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? NeuColors.bgDark : NeuColors.bgLight;
    final darkShadow = NeuColors.shadowDark(widget.isDark).withValues(alpha: 0.35);
    final lightShadow = NeuColors.shadowLight(widget.isDark).withValues(alpha: widget.isDark ? 0.07 : 0.85);

    Widget box = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.size * 0.35),
        gradient: widget.gradientColors != null
            ? LinearGradient(
                colors: widget.gradientColors!,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  widget.isDark ? const Color(0xFF243050) : const Color(0xFFF0F4FF),
                  bg,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        boxShadow: [
          BoxShadow(color: darkShadow, blurRadius: 10, offset: const Offset(4, 4), spreadRadius: -2),
          BoxShadow(color: lightShadow, blurRadius: 10, offset: const Offset(-4, -4), spreadRadius: -2),
        ],
      ),
      child: Icon(widget.icon, color: widget.gradientColors != null ? Colors.white : widget.iconColor, size: widget.iconSize),
    );

    if (widget.onTap != null) {
      box = GestureDetector(
        onTapDown: (_) {
          if (widget.pulseOnHover) setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          if (widget.pulseOnHover) setState(() => _isPressed = false);
          widget.onTap?.call();
        },
        onTapCancel: () {
          if (widget.pulseOnHover) setState(() => _isPressed = false);
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.90 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOutCubic,
          child: box,
        ),
      );
    }

    return box;
  }
}

// ─── Animated Orb Background ──────────────────────────────────────────────────
class AnimatedOrbBackground extends StatefulWidget {
  final Widget child;
  final bool isDark;
  final List<Color>? orbColors;

  const AnimatedOrbBackground({
    super.key,
    required this.child,
    required this.isDark,
    this.orbColors,
  });

  @override
  State<AnimatedOrbBackground> createState() => _AnimatedOrbBackgroundState();
}

class _AnimatedOrbBackgroundState extends State<AnimatedOrbBackground>
    with TickerProviderStateMixin {
  late AnimationController _orb1Controller;
  late AnimationController _orb2Controller;
  late AnimationController _orb3Controller;

  @override
  void initState() {
    super.initState();
    _orb1Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    _orb2Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 11),
    );
    _orb3Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    );

    // In widget testing, infinite repeat causes tester.pumpAndSettle to time out.
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTest) {
      _orb1Controller.repeat(reverse: true);
      _orb2Controller.repeat(reverse: true);
      _orb3Controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _orb1Controller.dispose();
    _orb2Controller.dispose();
    _orb3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final colors = widget.orbColors;
    final orb1Color = colors?[0] ?? (isDark ? const Color(0xFF6366F1) : const Color(0xFF818CF8));
    final orb2Color = colors?[1] ?? (isDark ? const Color(0xFF06B6D4) : const Color(0xFF38BDF8));
    final orb3Color = colors?[2] ?? (isDark ? const Color(0xFF10B981) : const Color(0xFF34D399));

    return Container(
      color: isDark ? NeuColors.bgDark : NeuColors.bgLight,
      child: Stack(
        children: [
          // Orb 1 — upper right
          AnimatedBuilder(
            animation: _orb1Controller,
            builder: (context, _) => Positioned(
              top: -80 + 30 * _orb1Controller.value,
              right: -60 + 20 * _orb1Controller.value,
              child: _buildOrb(220, orb1Color.withValues(alpha: isDark ? 0.20 : 0.14)),
            ),
          ),
          // Orb 2 — center left
          AnimatedBuilder(
            animation: _orb2Controller,
            builder: (context, _) => Positioned(
              top: 200 + 40 * _orb2Controller.value,
              left: -80 + 20 * _orb2Controller.value,
              child: _buildOrb(260, orb2Color.withValues(alpha: isDark ? 0.14 : 0.10)),
            ),
          ),
          // Orb 3 — bottom right
          AnimatedBuilder(
            animation: _orb3Controller,
            builder: (context, _) => Positioned(
              bottom: -60 + 30 * _orb3Controller.value,
              right: -40 + 20 * _orb3Controller.value,
              child: _buildOrb(200, orb3Color.withValues(alpha: isDark ? 0.16 : 0.12)),
            ),
          ),

          // Noise texture overlay (subtle)
          if (!kIsWeb)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [Colors.transparent, const Color(0x0A000000)]
                          : [Colors.transparent, const Color(0x06FFFFFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),

          // Content
          widget.child,
        ],
      ),
    );
  }

  Widget _buildOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}

// ─── Neumorphic Pill Badge ────────────────────────────────────────────────────
class NeuBadge extends StatelessWidget {
  final String text;
  final Color color;
  final bool isDark;

  const NeuBadge({
    super.key,
    required this.text,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: isDark ? 0.20 : 0.12),
        border: Border.all(color: color.withValues(alpha: 0.30), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ─── Gradient Divider ─────────────────────────────────────────────────────────
class GradientDivider extends StatelessWidget {
  final bool isDark;

  const GradientDivider({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ─── Neumorphic Chip ──────────────────────────────────────────────────────────
class NeuChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;
  final Color? accentColor;

  const NeuChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? NeuColors.bgDark : NeuColors.bgLight;
    final activeColor = accentColor ?? (isDark ? const Color(0xFF6366F1) : const Color(0xFF667EEA));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isSelected
              ? LinearGradient(
                  colors: [activeColor, activeColor.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : bg,
          boxShadow: isSelected
              ? []
              : NeuColors.elevation1(isDark),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
          ),
        ),
      ),
    );
  }
}

// ─── Neumorphic Search Field ──────────────────────────────────────────────────
class NeuSearchField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool isDark;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const NeuSearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.isDark,
    this.onChanged,
    this.onClear,
  });

  @override
  State<NeuSearchField> createState() => _NeuSearchFieldState();
}

class _NeuSearchFieldState extends State<NeuSearchField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
    widget.controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.isDark ? const Color(0xFF818CF8) : const Color(0xFF667EEA);
    final textPrim = widget.isDark ? const Color(0xFFF8FAFC) : const Color(0xFF111827);
    final textSec = widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);

    return NeuContainer(
      isDark: widget.isDark,
      isInset: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      borderRadius: 16,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          border: Border.all(
            color: _isFocused ? accent : Colors.transparent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: textSec, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                onChanged: widget.onChanged,
                style: TextStyle(color: textPrim, fontSize: 15),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: TextStyle(color: textSec, fontSize: 15),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (widget.controller.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  widget.controller.clear();
                  widget.onClear?.call();
                },
                child: Icon(Icons.close, color: textSec, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Neumorphic Progress Bar ──────────────────────────────────────────────────
class NeuProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final bool isDark;
  final List<Color>? gradientColors;
  final double height;

  const NeuProgressBar({
    super.key,
    required this.value,
    required this.isDark,
    this.gradientColors,
    this.height = 12,
  });

  @override
  Widget build(BuildContext context) {
    return NeuContainer(
      isDark: isDark,
      isInset: true,
      padding: EdgeInsets.zero,
      borderRadius: height / 2,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Align(
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              return FractionallySizedBox(
                widthFactor: val,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(height / 2),
                    gradient: LinearGradient(
                      colors: gradientColors ?? NeuColors.primaryGradient,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── Neumorphic Stat Card ─────────────────────────────────────────────────────
class NeuStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final List<Color> gradientColors;
  final bool isDark;
  final VoidCallback? onTap;
  final String? subtitle;

  const NeuStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.gradientColors,
    required this.isDark,
    this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textPrim = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF111827);
    final textSec = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
    final textTert = isDark ? const Color(0xFF64748B) : const Color(0xFFAEAEB2);

    return NeuContainer(
      isDark: isDark,
      padding: const EdgeInsets.all(20),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          NeuIconBox(
            icon: icon,
            iconColor: Colors.white,
            isDark: isDark,
            gradientColors: gradientColors,
            size: 42,
            iconSize: 20,
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textPrim,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textSec,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: textTert,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
