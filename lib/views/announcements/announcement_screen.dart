import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/dormmate_constants.dart';
import '../../viewmodels/announcement_viewmodel.dart';
import '../../widgets/announcement_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/app_animations.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementViewModel>().loadAnnouncements();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnnouncementViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Announcements', style: DormMateTextStyles.title),
        actions: [
          if (vm.unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all_rounded, size: 22),
              tooltip: 'Mark all as read',
              onPressed: () {
                vm.markAllAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All notices marked as read'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Column(
              children: [
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: DormMateColors.glassBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: DormMateColors.divider),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: DormMateColors.textTertiary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            setState(() {});
                            vm.setSearchQuery(val);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search notices and updates...',
                            hintStyle: TextStyle(fontSize: 13, color: DormMateColors.textTertiary),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: TextStyle(fontSize: 13, color: DormMateColors.textPrimary),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() {});
                            vm.setSearchQuery('');
                          },
                          child: Icon(Icons.close_rounded, size: 18, color: DormMateColors.textTertiary),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Category Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Unread', 'Important', 'Maintenance'].map((cat) {
                      final isSelected = vm.selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => vm.setCategory(cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? DormMateColors.primary : DormMateColors.glassBackground,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected ? DormMateColors.primary : DormMateColors.divider,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  cat,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? Colors.white : DormMateColors.textSecondary,
                                  ),
                                ),
                                if (cat == 'Unread' && vm.unreadCount > 0) ...[
                                  const SizedBox(width: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.white : DormMateColors.primary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${vm.unreadCount}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? DormMateColors.primary : Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Announcements List
          Expanded(
            child: vm.isLoading && vm.announcements.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    child: Column(
                      children: [
                        ShimmerSkeletonCard(height: 90, borderRadius: 16),
                        ShimmerSkeletonCard(height: 90, borderRadius: 16),
                        ShimmerSkeletonCard(height: 90, borderRadius: 16),
                      ],
                    ),
                  )
                : vm.errorMessage != null && vm.announcements.isEmpty
                    ? ErrorView(
                        message: vm.errorMessage!,
                        onRetry: vm.loadAnnouncements,
                      )
                    : vm.isEmpty
                        ? EmptyStateView(
                            icon: Icons.campaign_outlined,
                            title: 'No Announcements Found',
                            subtitle: vm.searchQuery.isNotEmpty || vm.selectedCategory != 'All'
                                ? 'No announcements match your search or filter.'
                                : 'There are no dormitory notices at this time.',
                            actionText: vm.searchQuery.isNotEmpty || vm.selectedCategory != 'All'
                                ? 'Clear Filters'
                                : null,
                            onAction: vm.searchQuery.isNotEmpty || vm.selectedCategory != 'All'
                                ? () {
                                    _searchController.clear();
                                    setState(() {});
                                    vm.setSearchQuery('');
                                    vm.setCategory('All');
                                  }
                                : null,
                          )
                        : RefreshIndicator(
                            onRefresh: vm.loadAnnouncements,
                            color: DormMateColors.primary,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(left: 18, right: 18, top: 6, bottom: 96),
                              itemCount: vm.filteredAnnouncements.length,
                              itemBuilder: (context, index) {
                                final ann = vm.filteredAnnouncements[index];
                                return FadeSlideEntry(
                                  key: ValueKey(ann.id),
                                  delay: Duration(milliseconds: 30 * index),
                                  child: AnnouncementCard(
                                    announcement: ann,
                                    onTap: () => context.go('/announcements/${ann.id}'),
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
