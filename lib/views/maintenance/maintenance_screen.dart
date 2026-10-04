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
import '../../widgets/neumorphic.dart';
import '../../core/localization/language_service.dart';
import '../../widgets/language_toggle_button.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isThai = context.isThai;

    String getFilterLabel(String f) {
      if (!isThai) return f;
      switch (f) {
        case 'All': return 'ทั้งหมด';
        case 'Pending': return 'รอดำเนินการ';
        case 'Active': return 'กำลังซ่อม';
        case 'Done': return 'เสร็จสิ้น';
        default: return f;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isThai ? 'แจ้งซ่อม' : 'Maintenance',
          style: DormMateTextStyles.title.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
          ),
        ),
        actions: [
          LanguageToggleButton(isDark: isDark),
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: isThai ? 'ขั้นตอนการแจ้งซ่อม' : 'Maintenance Guide',
            onPressed: () => showFeatureGuideSheet(context, FeatureGuide.maintenanceGuide),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 26),
            tooltip: isThai ? 'เพิ่มรายการแจ้งซ่อม' : 'Add Request',
            onPressed: () => context.push('/maintenance/create'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: NeuButton(
          isDark: isDark,
          gradientColors: const [Color(0xFF667EEA), Color(0xFF764BA2)],
          borderRadius: 28,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          onTap: () => context.push('/maintenance/create'),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 6),
              Text(
                isThai ? 'แจ้งซ่อมใหม่' : 'New Request',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
      body: AnimatedOrbBackground(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated Filter Pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: NeuContainer(
                isDark: isDark,
                isInset: true,
                borderRadius: 24,
                padding: const EdgeInsets.all(4),
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
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
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
                              child: Text(getFilterLabel(filter)),
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
                              ? EmptyStateView(
                                  icon: Icons.check_circle_outline_rounded,
                                  title: isThai ? 'ไม่มีรายการแจ้งซ่อม' : 'No Maintenance Requests',
                                  subtitle: isThai ? 'ทุกอย่างอยู่ในสภาพดี ไม่พบปัญหาที่รายงาน' : 'Everything looks good. No problems reported.',
                                )
                              : EmptyStateView(
                                  icon: vm.selectedFilter == 'Done'
                                      ? Icons.task_alt_rounded
                                      : Icons.pending_actions_rounded,
                                  title: isThai ? 'ไม่มีรายการ${getFilterLabel(vm.selectedFilter)}' : 'No ${vm.selectedFilter} Requests',
                                  subtitle: isThai ? 'ปัจจุบันคุณไม่มีรายการในหมวด "${getFilterLabel(vm.selectedFilter)}"' : 'You currently have no requests marked as "${vm.selectedFilter}".',
                                  actionText: isThai ? 'แสดงทุกรายการ' : 'Show All Requests',
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
                                          isThai ? 'ปัดไปทางซ้ายบนรายการที่รอดำเนินการเพื่อยกเลิก' : 'Swipe left on pending requests to cancel',
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
                                      onTap: () => context.push('/maintenance/${req.id}'),
                                      onCancel: () async {
                                        final ok = await vm.cancelRequest(req.id);
                                        if (ok && context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(isThai ? 'ยกเลิกคำขอเรียบร้อยแล้ว' : 'Request cancelled'),
                                              duration: const Duration(seconds: 2),
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
      ),
    );
  }
}
