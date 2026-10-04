import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants/dormmate_constants.dart';
import '../core/localization/language_service.dart';
import '../widgets/neumorphic.dart';

// ─── Nav Item Data ─────────────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String labelEn;
  final String labelTh;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.labelEn,
    required this.labelTh,
  });

  String label(bool isThai) => isThai ? labelTh : labelEn;
}

const _kNavItems = [
  _NavItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    labelEn: 'Home',
    labelTh: 'หน้าแรก',
  ),
  _NavItem(
    icon: Icons.receipt_long_outlined,
    activeIcon: Icons.receipt_long_rounded,
    labelEn: 'Expenses',
    labelTh: 'ค่าใช้จ่าย',
  ),
  _NavItem(
    icon: Icons.build_outlined,
    activeIcon: Icons.build_rounded,
    labelEn: 'Maintenance',
    labelTh: 'แจ้งซ่อม',
  ),
  _NavItem(
    icon: Icons.campaign_outlined,
    activeIcon: Icons.campaign_rounded,
    labelEn: 'Announce',
    labelTh: 'ประกาศ',
  ),
  _NavItem(
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
    labelEn: 'Profile',
    labelTh: 'โปรไฟล์',
  ),
];

// ─── Gradient Pill Indicator ───────────────────────────────────────────────────
class _GradientPill extends StatelessWidget {
  final Widget child;

  const _GradientPill({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withValues(alpha: 0.38),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: const Color(0xFF667EEA).withValues(alpha: 0.2), // subtle glow BoxShadow matching gradient color
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── Single Nav Item Widget ────────────────────────────────────────────────────
class _NeuNavItem extends StatefulWidget {
  final _NavItem item;
  final bool isSelected;
  final bool isDark;
  final bool isThai;
  final VoidCallback onTap;

  const _NeuNavItem({
    required this.item,
    required this.isSelected,
    required this.isDark,
    required this.isThai,
    required this.onTap,
  });

  @override
  State<_NeuNavItem> createState() => _NeuNavItemState();
}

class _NeuNavItemState extends State<_NeuNavItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final unselectedColor = widget.isDark
        ? Colors.white.withValues(alpha: 0.35)
        : DormMateColors.textDisabled;

    final displayLabel = widget.item.label(widget.isThai);

    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon — gradient pill when selected, bare icon when not
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: widget.isSelected
                      ? _GradientPill(
                          key: ValueKey('sel_${widget.item.labelEn}'),
                          child: Icon(
                            widget.item.activeIcon,
                            size: 20,
                            color: Colors.white,
                          ),
                        )
                      : Padding(
                          key: ValueKey('unsel_${widget.item.labelEn}'),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          child: Icon(
                            widget.item.icon,
                            size: 20,
                            color: unselectedColor,
                          ),
                        ),
                ),
                const SizedBox(height: 4),
                // Label
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: widget.isSelected
                        ? const Color(0xFF667EEA)
                        : unselectedColor,
                    letterSpacing: 0.1,
                  ),
                  child: Text(displayLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Main Navigation Shell ─────────────────────────────────────────────────────
class MainNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langService = context.watch<LanguageService?>();
    final isThai = langService?.isThai ?? false;

    // Neumorphic base colors
    final neuBg =
        isDark ? NeuColors.bgDark : NeuColors.bgLight;
    final darkShadow = NeuColors.shadowDark(isDark).withValues(alpha: 0.40);
    final lightShadow = NeuColors.shadowLight(isDark)
        .withValues(alpha: isDark ? 0.08 : 0.85);

    // Neumorphic floating pill decoration
    final pillDecoration = BoxDecoration(
      color: neuBg,
      borderRadius: BorderRadius.circular(30),
      border: Border(
        top: BorderSide(
          color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white,
          width: 1.0,
        ),
      ),
      boxShadow: [
        // Dark shadow — lower-right (embossed)
        BoxShadow(
          color: darkShadow,
          blurRadius: 20,
          offset: const Offset(6, 6),
          spreadRadius: -2,
        ),
        // Light shadow — upper-left (embossed)
        BoxShadow(
          color: lightShadow,
          blurRadius: 20,
          offset: const Offset(-6, -6),
          spreadRadius: -2,
        ),
      ],
    );

    final navBar = Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: pillDecoration,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_kNavItems.length, (index) {
          return _NeuNavItem(
            item: _kNavItems[index],
            isSelected: navigationShell.currentIndex == index,
            isDark: isDark,
            isThai: isThai,
            onTap: () => navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            ),
          );
        }),
      ),
    );

    return Scaffold(
      body: navigationShell,
      extendBody: true,
      bottomNavigationBar: SafeArea(
        top: false,
        child: navBar,
      ),
    );
  }
}
