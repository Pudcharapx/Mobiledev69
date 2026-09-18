import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/dormmate_constants.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/room_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/app_animations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadDashboard();
    });
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: PressableScale(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: DormMateColors.glassBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: DormMateColors.glassBorder,
              width: 1.2,
            ),
            boxShadow: [
              const BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
              BoxShadow(
                color: color.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.16),
                      color.withValues(alpha: 0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withValues(alpha: 0.22),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.10),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(height: 7),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: DormMateColors.textPrimary,
                  letterSpacing: -0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    return Scaffold(
      body: SafeArea(
        child: vm.isLoading && vm.room == null
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Column(
                  children: [
                    ShimmerSkeletonCard(height: 150, borderRadius: 24),
                    Row(
                      children: [
                        Expanded(child: ShimmerSkeletonCard(height: 120, borderRadius: 18)),
                        SizedBox(width: 12),
                        Expanded(child: ShimmerSkeletonCard(height: 120, borderRadius: 18)),
                      ],
                    ),
                    ShimmerSkeletonCard(height: 160, borderRadius: 20),
                  ],
                ),
              )
            : vm.errorMessage != null && vm.room == null
                ? ErrorView(
                    message: vm.errorMessage!,
                    onRetry: vm.loadDashboard,
                  )
                : RefreshIndicator(
                    onRefresh: vm.refresh,
                    color: DormMateColors.primary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header greeting
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _greeting,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: DormMateColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    vm.userName,
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: DormMateColors.textPrimary,
                                      letterSpacing: -0.6,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    vm.userName.isNotEmpty ? vm.userName[0].toUpperCase() : 'U',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Room card
                          FadeSlideEntry(
                            delay: const Duration(milliseconds: 50),
                            child: RoomCard(room: vm.room),
                          ),

                          const SizedBox(height: 14),

                          // Quick Actions Bar
                          FadeSlideEntry(
                            delay: const Duration(milliseconds: 90),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    _buildQuickAction(
                                      icon: Icons.qr_code_2_rounded,
                                      label: 'Pay Bills',
                                      color: DormMateColors.isDark ? const Color(0xFF38BDF8) : const Color(0xFF003D6B),
                                      onTap: () => context.go('/expenses'),
                                    ),
                                    const SizedBox(width: 10),
                                    _buildQuickAction(
                                      icon: Icons.inventory_2_rounded,
                                      label: 'Parcels',
                                      color: const Color(0xFF059669),
                                      onTap: () => context.push('/parcels'),
                                    ),
                                    const SizedBox(width: 10),
                                    _buildQuickAction(
                                      icon: Icons.build_rounded,
                                      label: 'Report Issue',
                                      color: const Color(0xFFFF9500),
                                      onTap: () => context.go('/maintenance/create'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    _buildQuickAction(
                                      icon: Icons.local_laundry_service_rounded,
                                      label: 'Laundry',
                                      color: const Color(0xFF2563EB),
                                      onTap: () => context.push('/facilities'),
                                    ),
                                    const SizedBox(width: 10),
                                    _buildQuickAction(
                                      icon: Icons.bar_chart_rounded,
                                      label: 'Usage Stats',
                                      color: const Color(0xFF7C3AED),
                                      onTap: () => context.push('/expenses/analytics'),
                                    ),
                                    const SizedBox(width: 10),
                                    _buildQuickAction(
                                      icon: Icons.campaign_rounded,
                                      label: 'Notices',
                                      color: DormMateColors.primary,
                                      onTap: () => context.go('/announcements'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Mini statistics grid
                          FadeSlideEntry(
                            delay: const Duration(milliseconds: 130),
                            child: Row(
                              children: [
                                // Expenses mini card
                                Expanded(
                                  child: GlassCard(
                                    onTap: () => context.go('/expenses'),
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: DormMateColors.primary.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.bolt_rounded,
                                                size: 16,
                                                color: DormMateColors.primary,
                                              ),
                                            ),
                                            if (vm.unpaidExpenseCount > 0)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: DormMateColors.statusErrorBg,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  '${vm.unpaidExpenseCount} Due',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    color: DormMateColors.statusErrorText,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          vm.latestExpense != null
                                              ? vm.latestExpense!.displayMonth.split(' ').first.toUpperCase()
                                              : 'THIS MONTH',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: DormMateColors.textTertiary,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        vm.latestExpense != null
                                            ? CountUpAmount(
                                                targetAmount: vm.latestExpense!.total,
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w800,
                                                  color: DormMateColors.textPrimary,
                                                  letterSpacing: -0.5,
                                                ),
                                              )
                                            : Text(
                                                '฿0',
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w800,
                                                  color: DormMateColors.textPrimary,
                                                  letterSpacing: -0.5,
                                                ),
                                              ),
                                        const SizedBox(height: 2),
                                        Text(
                                          vm.unpaidExpenseCount > 0
                                              ? '฿${vm.unpaidExpenseTotal.toStringAsFixed(0)} Due · Pay now'
                                              : 'All paid up',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: vm.unpaidExpenseCount > 0 ? FontWeight.w600 : FontWeight.w400,
                                            color: vm.unpaidExpenseCount > 0 ? DormMateColors.statusErrorText : DormMateColors.statusCompletedText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                              // Maintenance mini card
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => context.go('/maintenance'),
                                  child: GlassCard(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFF9500).withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.build_outlined,
                                            size: 16,
                                            color: Color(0xFFFF9500),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'MAINTENANCE',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: DormMateColors.textTertiary,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${vm.activeMaintenanceCount} Active',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: DormMateColors.textPrimary,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: vm.activeMaintenanceCount > 0
                                                    ? DormMateColors.statusInProgress
                                                    : DormMateColors.statusCompleted,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              vm.activeMaintenanceStatus ?? 'All resolved',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: DormMateColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),

                          // Announcements section
                          FadeSlideEntry(
                            delay: const Duration(milliseconds: 180),
                            child: GlassCard(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Announcements',
                                        style: DormMateTextStyles.sectionTitle,
                                      ),
                                      GestureDetector(
                                        onTap: () => context.go('/announcements'),
                                        child: Text(
                                          'See all',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: DormMateColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (vm.latestAnnouncements.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Text(
                                        'No announcements right now.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: DormMateColors.textTertiary,
                                        ),
                                      ),
                                    )
                                  else
                                    ...vm.latestAnnouncements.asMap().entries.map((entry) {
                                      final item = entry.value;
                                      final isLast = entry.key == vm.latestAnnouncements.length - 1;
                                      return Column(
                                        children: [
                                          InkWell(
                                            onTap: () => context.go('/announcements/${item.id}'),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 7,
                                                    height: 7,
                                                    decoration: BoxDecoration(
                                                      color: DormMateColors.primary,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          item.title,
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.w600,
                                                            color: DormMateColors.textPrimary,
                                                          ),
                                                        ),
                                                        Text(
                                                          item.displayDate,
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: DormMateColors.textTertiary,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.chevron_right_rounded,
                                                    color: DormMateColors.textDisabled,
                                                    size: 18,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (!isLast)
                                            Divider(
                                              height: 1,
                                              color: DormMateColors.divider,
                                            ),
                                        ],
                                      );
                                    }),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Quick actions
                          FadeSlideEntry(
                            delay: const Duration(milliseconds: 240),
                            child: Row(
                              children: [
                                Expanded(
                                  child: PressableScale(
                                    onTap: () => context.go('/maintenance/create'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      decoration: BoxDecoration(
                                        color: DormMateColors.primary,
                                        borderRadius: BorderRadius.circular(DormMateDimens.radiusMd),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_rounded, size: 18, color: Colors.white),
                                          SizedBox(width: 6),
                                          Text(
                                            'New Request',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: PressableScale(
                                    onTap: () => context.go('/expenses'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      decoration: BoxDecoration(
                                        color: DormMateColors.primary.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(DormMateDimens.radiusMd),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.receipt_long_outlined, size: 18, color: DormMateColors.primary),
                                          const SizedBox(width: 6),
                                          Text(
                                            'View Expenses',
                                            style: TextStyle(
                                              color: DormMateColors.primary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
