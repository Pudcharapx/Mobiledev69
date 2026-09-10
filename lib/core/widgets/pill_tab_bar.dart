import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

/// Pill/segmented control tab switcher per SRS.md section 9.2:
/// "rounded capsule tab switcher, selected tab shown as black background with white text — used to switch between 'Heatmap / Log List / Settings'"
class PillTabBar extends StatelessWidget {
  final String currentRoute;

  const PillTabBar({
    super.key,
    required this.currentRoute,
  });

  static const List<_TabItem> _tabs = [
    _TabItem(title: 'Heatmap', route: '/', icon: Icons.whatshot_rounded),
    _TabItem(title: 'Log List', route: '/workouts', icon: Icons.list_alt_rounded),
    _TabItem(title: 'Settings', route: '/profile', icon: Icons.settings_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: _tabs.map((tab) {
          final isSelected = _isRouteSelected(tab.route);
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isSelected) {
                  context.go(tab.route);
                }
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? Colors.white : Colors.black)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tab.icon,
                      size: 16,
                      color: isSelected
                          ? (isDark ? Colors.black : Colors.white)
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tab.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? (isDark ? Colors.black : Colors.white)
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _isRouteSelected(String tabRoute) {
    if (tabRoute == '/') {
      return currentRoute == '/' || currentRoute.isEmpty;
    }
    return currentRoute.startsWith(tabRoute);
  }
}

class _TabItem {
  final String title;
  final String route;
  final IconData icon;

  const _TabItem({
    required this.title,
    required this.route,
    required this.icon,
  });
}
