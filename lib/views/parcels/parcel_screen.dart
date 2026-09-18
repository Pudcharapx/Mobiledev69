import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/dormmate_constants.dart';
import '../../viewmodels/parcel_viewmodel.dart';
import '../../widgets/parcel_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/app_animations.dart';
import '../../models/feature_guide.dart';
import '../../widgets/feature_guide_sheet.dart';

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

  Widget _buildFilterChip(String label, String value, int count, ParcelViewModel vm) {
    final isSelected = vm.activeFilter == value;
    return GestureDetector(
      onTap: () => vm.setFilter(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? DormMateColors.primary
              : DormMateColors.glassBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? DormMateColors.primary : DormMateColors.divider,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: DormMateColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
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
                      : DormMateColors.divider,
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Parcels', style: DormMateTextStyles.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () => showFeatureGuideSheet(context, FeatureGuide.parcelGuide),
            tooltip: 'ขั้นตอนการรับพัสดุ',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: vm.loadParcels,
            tooltip: 'Refresh Parcels',
          ),
        ],
      ),
      body: vm.isLoading && vm.parcels.isEmpty
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
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F172A).withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.inventory_2_rounded,
                                    color: Color(0xFF34D399),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${vm.readyCount} Parcel${vm.readyCount > 1 ? 's' : ''} Ready for Pickup',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Waiting at Dormitory Front Desk / Locker Room',
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
                        child: Container(
                          decoration: BoxDecoration(
                            color: DormMateColors.glassBackground,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: DormMateColors.divider),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: TextStyle(fontSize: 13, color: DormMateColors.textPrimary),
                            onChanged: vm.search,
                            decoration: InputDecoration(
                              hintText: 'Search by tracking no. or carrier...',
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
                              _buildFilterChip('All', 'All', vm.parcels.length, vm),
                              const SizedBox(width: 8),
                              _buildFilterChip('Ready for Pickup', 'Ready', vm.readyCount, vm),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                'Claimed',
                                'Claimed',
                                vm.parcels.where((p) => p.isClaimed).length,
                                vm,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Parcel List
                      if (vm.filteredParcels.isEmpty) ...[
                        const SizedBox(height: 20),
                        const EmptyStateView(
                          icon: Icons.inventory_2_outlined,
                          title: 'No Parcels Found',
                          subtitle: 'No parcel records match your current filter or search.',
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
                    ],
                  ),
                ),
    );
  }
}
