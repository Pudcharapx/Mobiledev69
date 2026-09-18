import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/dormmate_constants.dart';
import '../core/theme/dormmate_theme_presets.dart';

class MainNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<DormMateThemeExtension>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final navBg = isDark
        ? (themeExt?.surface.withValues(alpha: 0.88) ?? const Color(0xFF1E293B).withValues(alpha: 0.88))
        : Colors.white.withValues(alpha: 0.88);
    final navBorder = isDark
        ? (themeExt?.cardBorder ?? Colors.white.withValues(alpha: 0.18))
        : Colors.white.withValues(alpha: 0.95);
    final selectedColor = themeExt?.primary ?? DormMateColors.primary;
    final unselectedColor = isDark
        ? Colors.white38
        : DormMateColors.textDisabled;

    final navDecoration = BoxDecoration(
      color: navBg,
      borderRadius: BorderRadius.circular(26),
      border: Border.all(color: navBorder, width: 1.2),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black38 : const Color(0xFF0F172A).withValues(alpha: 0.10),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );

    final navBarContent = BottomNavigationBar(
      currentIndex: navigationShell.currentIndex,
      onTap: (index) {
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
      backgroundColor: Colors.transparent,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: selectedColor,
      unselectedItemColor: unselectedColor,
      selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
      unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long_rounded),
          label: 'Expenses',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.build_outlined),
          activeIcon: Icon(Icons.build_rounded),
          label: 'Maintenance',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.campaign_outlined),
          activeIcon: Icon(Icons.campaign_rounded),
          label: 'Announce',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );

    // On Web, render without heavy offscreen BackdropFilter to protect WebGL context
    final bottomBarChild = kIsWeb
        ? Container(
            decoration: navDecoration,
            child: navBarContent,
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                decoration: navDecoration,
                child: navBarContent,
              ),
            ),
          );

    return Scaffold(
      body: navigationShell,
      extendBody: true,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: bottomBarChild,
        ),
      ),
    );
  }
}
