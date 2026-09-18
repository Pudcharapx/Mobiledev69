import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/dormmate_constants.dart';
import '../../viewmodels/maintenance_viewmodel.dart';
import '../../widgets/maintenance_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/app_animations.dart';
import '../../models/feature_guide.dart';
import '../../widgets/feature_guide_sheet.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaintenanceViewModel>().loadRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MaintenanceViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Maintenance', style: DormMateTextStyles.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'ขั้นตอนการแจ้งซ่อม',
            onPressed: () => showFeatureGuideSheet(context, FeatureGuide.maintenanceGuide),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 26),
            tooltip: 'Add Request',
            onPressed: () => context.go('/maintenance/create'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: PressableScale(
          onTap: () => context.go('/maintenance/create'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: DormMateColors.primary,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 22),
                SizedBox(width: 6),
                Text(
                  'New Request',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated Filter Pills
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: DormMateColors.glassBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: DormMateColors.divider),
              ),
              child: Row(
                children: ['All', 'Pending', 'Active', 'Done'].map((filter) {
                  final isSelected = vm.selectedFilter == filter;
                  return Expanded(
                    child: PressableScale(
                      onTap: () => vm.setFilter(filter),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? DormMateColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected
                              ? const [
                                  BoxShadow(
                                    color: Color(0x1F000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : DormMateColors.textSecondary,
                            ),
                            child: Text(filter),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Main list content
          Expanded(
            child: vm.isLoading && vm.requests.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Column(
                      children: [
                        ShimmerSkeletonCard(height: 80, borderRadius: 16),
                        ShimmerSkeletonCard(height: 80, borderRadius: 16),
                        ShimmerSkeletonCard(height: 80, borderRadius: 16),
                      ],
                    ),
                  )
                : vm.errorMessage != null && vm.requests.isEmpty
                    ? ErrorView(
                        message: vm.errorMessage!,
                        onRetry: vm.loadRequests,
                      )
                    : vm.isEmpty
                        ? (vm.selectedFilter == 'All'
                            ? const EmptyStateView(
                                icon: Icons.check_circle_outline_rounded,
                                title: 'No Maintenance Requests',
                                subtitle: 'Everything looks good. No problems reported.',
                              )
                            : EmptyStateView(
                                icon: vm.selectedFilter == 'Done'
                                    ? Icons.task_alt_rounded
                                    : Icons.pending_actions_rounded,
                                title: 'No ${vm.selectedFilter} Requests',
                                subtitle: 'You currently have no requests marked as "${vm.selectedFilter}".',
                                actionText: 'Show All Requests',
                                onAction: () => vm.setFilter('All'),
                              ))
                        : RefreshIndicator(
                            onRefresh: vm.loadRequests,
                            color: DormMateColors.primary,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(left: 18, right: 18, top: 8, bottom: 96),
                              itemCount: vm.filteredRequests.length + 1,
                              itemBuilder: (context, index) {
                                if (index == vm.filteredRequests.length) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 24),
                                    child: Center(
                                      child: Text(
                                        'Swipe left on pending requests to cancel',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: DormMateColors.textTertiary,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                final req = vm.filteredRequests[index];
                                return FadeSlideEntry(
                                  key: ValueKey(req.id),
                                  delay: Duration(milliseconds: 35 * index),
                                  child: MaintenanceCard(
                                    request: req,
                                    onTap: () => context.go('/maintenance/${req.id}'),
                                    onCancel: () async {
                                      final ok = await vm.cancelRequest(req.id);
                                      if (ok && context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Request cancelled'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
