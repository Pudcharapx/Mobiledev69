import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/dormmate_constants.dart';
import '../../viewmodels/parcel_viewmodel.dart';
import '../../widgets/parcel_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/app_animations.dart';
import '../../models/feature_guide.dart';
import '../../widgets/feature_guide_sheet.dart';
import '../../widgets/neumorphic.dart';
import '../../core/localization/language_service.dart';
import '../../widgets/language_toggle_button.dart';

class ParcelScreen extends StatefulWidget {
  const ParcelScreen({super.key});

  @override
  State<ParcelScreen> createState() => _ParcelScreenState();
}

class _ParcelScreenState extends State<ParcelScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ParcelViewModel>().loadParcels();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      try {
        context.go('/');
      } catch (_) {}
    }
  }

  Widget _buildFilterChip(String label, String value, int count, ParcelViewModel vm, bool isDark) {
    final isSelected = vm.activeFilter == value;
    return GestureDetector(
      onTap: () => vm.setFilter(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : (isDark ? const Color(0xFF222B42) : const Color(0xFFEFF2F8)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : (isDark ? NeuColors.borderDark : NeuColors.borderLight),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : DormMateColors.textSecondary,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : (isDark ? const Color(0xFF2E3B5B) : const Color(0xFFDCE2EE)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : DormMateColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ParcelViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isThai = context.isThai;

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgDark : NeuColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _handleBack,
        ),
        title: Text(
          isThai ? 'พัสดุ' : 'Parcels',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF1A2035),
            letterSpacing: -0.6,
          ),
        ),
        actions: [
          LanguageToggleButton(isDark: isDark),
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () => showFeatureGuideSheet(context, FeatureGuide.parcelGuide),
            tooltip: isThai ? 'ขั้นตอนการรับพัสดุ' : 'Parcel Guide',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: vm.loadParcels,
            tooltip: isThai ? 'รีเฟรชพัสดุ' : 'Refresh Parcels',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: AnimatedOrbBackground(
        isDark: isDark,
        child: vm.isLoading && vm.parcels.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Column(
                  children: [
                    ShimmerSkeletonCard(height: 100, borderRadius: 20),
                    SizedBox(height: 12),
                    ShimmerSkeletonCard(height: 120, borderRadius: 18),
                    SizedBox(height: 12),
                    ShimmerSkeletonCard(height: 120, borderRadius: 18),
                  ],
                ),
              )
            : vm.errorMessage != null && vm.parcels.isEmpty
                ? ErrorView(
                    message: vm.errorMessage!,
                    onRetry: vm.loadParcels,
                  )
                : RefreshIndicator(
                    onRefresh: vm.loadParcels,
                    color: DormMateColors.primary,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      children: [
                        // Active Pickup Alert Banner
                        if (vm.readyCount > 0) ...[
                          FadeSlideEntry(
                            delay: const Duration(milliseconds: 40),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                  const BoxShadow(
                                    color: Color(0x2A000000),
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.inventory_2_rounded,
                                      color: Color(0xFF34D399),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isThai
                                              ? 'พัสดุ ${vm.readyCount} ชิ้น พร้อมรับแล้ว'
                                              : '${vm.readyCount} Parcel${vm.readyCount > 1 ? 's' : ''} Ready for Pickup',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          isThai
                                              ? 'รอรับได้ที่เคาน์เตอร์นิติบุคคล / ห้องล็อกเกอร์'
                                              : 'Waiting at Dormitory Front Desk / Locker Room',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white.withValues(alpha: 0.75),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        // Search Bar
                        FadeSlideEntry(
                          delay: const Duration(milliseconds: 70),
                          child: NeuContainer(
                            isDark: isDark,
                            isInset: true,
                            borderRadius: 16,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(fontSize: 13, color: DormMateColors.textPrimary),
                              onChanged: vm.search,
                              decoration: InputDecoration(
                                hintText: isThai
                                    ? 'ค้นหาตามเลขพัสดุหรือขนส่ง...'
                                    : 'Search by tracking no. or carrier...',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: DormMateColors.textTertiary,
                                ),
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  size: 20,
                                  color: DormMateColors.textSecondary,
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 16),
                                        onPressed: () {
                                          _searchController.clear();
                                          vm.search('');
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Filter Chips
                        FadeSlideEntry(
                          delay: const Duration(milliseconds: 90),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip(isThai ? 'ทั้งหมด' : 'All', 'All', vm.parcels.length, vm, isDark),
                                const SizedBox(width: 8),
                                _buildFilterChip(isThai ? 'พร้อมรับ' : 'Ready for Pickup', 'Ready', vm.readyCount, vm, isDark),
                                const SizedBox(width: 8),
                                _buildFilterChip(
                                  isThai ? 'รับแล้ว' : 'Claimed',
                                  'Claimed',
                                  vm.parcels.where((p) => p.isClaimed).length,
                                  vm,
                                  isDark,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Parcel List
                        if (vm.filteredParcels.isEmpty) ...[
                          const SizedBox(height: 20),
                          EmptyStateView(
                            icon: Icons.inventory_2_outlined,
                            title: isThai ? 'ไม่พบพัสดุ' : 'No Parcels Found',
                            subtitle: isThai
                                ? 'ไม่มีพัสดุที่ตรงกับตัวกรองหรือการค้นหาของคุณ'
                                : 'No parcel records match your current filter or search.',
                          ),
                          const SizedBox(height: 16),
                          const FeatureGuideInlineCard(guide: FeatureGuide.parcelGuide),
                        ] else ...[
                          ...vm.filteredParcels.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final parcel = entry.value;
                            return FadeSlideEntry(
                              delay: Duration(milliseconds: 110 + idx * 30),
                              child: ParcelCard(
                                parcel: parcel,
                                onClaim: vm.claimParcel,
                              ),
                            );
                          }),
                        ],
                        const SizedBox(height: 96),
                      ],
                    ),
                  ),
      ),
    );
  }
}
