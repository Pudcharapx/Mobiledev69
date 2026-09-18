import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';
import '../theme/app_colors.dart';

/// Clean top navigation bar per SRS.md section 9.2:
/// "circular back button on the left, calendar icon + round profile photo on the right, consistent across all screens"
class AppTopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? extraActions;

  const AppTopNavBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBackPressed,
    this.extraActions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canPop = Navigator.of(context).canPop();
    final shouldShowBack = showBackButton || canPop;

    final authService = context.watch<AuthService?>();
    final username = authService?.currentUser?.username ?? 'U';
    final userInitial = username.isNotEmpty ? username[0].toUpperCase() : 'U';

    final todayStr = DateFormat.yMMMd().format(DateTime.now());

    return SafeArea(
      bottom: false,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.backgroundDark : Colors.white)
                  .withValues(alpha: isDark ? 0.75 : 0.80),
              border: Border(
                bottom: BorderSide(
                  color: (isDark ? Colors.white : Colors.black)
                      .withValues(alpha: isDark ? 0.08 : 0.05),
                  width: 1,
                ),
              ),
            ),
            child: Row(
          children: [
            // Circular back button or Circular App Icon on the left (SRS 9.2)
            if (shouldShowBack)
              _CircularIconButton(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Back',
                onPressed: () {
                  if (onBackPressed != null) {
                    onBackPressed!();
                  } else if (canPop) {
                    Navigator.of(context).pop();
                  } else {
                    context.go('/');
                  }
                },
              )
            else
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  size: 20,
                  color: AppColors.accent,
                ),
              ),

            const SizedBox(width: 14),

            // Screen Title
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  letterSpacing: -0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Extra actions (if provided)
            if (extraActions != null) ...extraActions!,

            // Calendar icon on the right (SRS 9.2)
            _CircularIconButton(
              icon: Icons.calendar_month_rounded,
              tooltip: 'Today: $todayStr',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Today is $todayStr'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            const SizedBox(width: 8),

            // Round profile photo / avatar on the right (SRS 9.2)
            GestureDetector(
              onTap: () {
                final currentPath = GoRouterState.of(context).matchedLocation;
                if (currentPath != '/profile') {
                  context.push('/profile');
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  border: Border.all(
                    color: AppColors.accent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  userInitial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
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

class _CircularIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _CircularIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.white.withValues(alpha: 0.75),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.20)
                    : Colors.black.withValues(alpha: 0.08),
                width: 1.2,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
        ),
      ),
    );
  }
}
