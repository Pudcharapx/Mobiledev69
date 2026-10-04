import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/dormmate_constants.dart';
import '../../viewmodels/announcement_viewmodel.dart';
import '../../widgets/announcement_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/app_animations.dart';
import '../../widgets/neumorphic.dart';
import '../../core/localization/language_service.dart';
import '../../widgets/language_toggle_button.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isThai = context.isThai;

    String getCategoryLabel(String c) {
      if (!isThai) return c;
      switch (c) {
        case 'All': return 'ทั้งหมด';
        case 'Unread': return 'ยังไม่อ่าน';
        case 'Important': return 'สำคัญ';
        case 'Maintenance': return 'การแจ้งซ่อม';
        default: return c;
      }
    }

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgDark : NeuColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isThai ? 'ประกาศ' : 'Announcements',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF1A2035),
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          LanguageToggleButton(isDark: isDark),
          if (vm.unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all_rounded, size: 22),
              tooltip: isThai ? 'อ่านทั้งหมดแล้ว' : 'Mark all as read',
              onPressed: () {
                vm.markAllAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isThai ? 'ทำเครื่องหมายว่าอ่านครบทุกประกาศแล้ว' : 'All notices marked as read'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedOrbBackground(
        isDark: isDark,
        child: Column(
          children: [
            // Search & Filter Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: Column(
                children: [
                  // Search bar — debossed / inset NeuContainer
                  NeuContainer(
                    isDark: isDark,
                    isInset: true,
                    borderRadius: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    child: SizedBox(
                      height: 44,
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: isDark
                                ? Colors.white38
                                : DormMateColors.textTertiary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) {
                                setState(() {});
                                vm.setSearchQuery(val);
                              },
                              decoration: InputDecoration(
                                hintText: isThai ? 'ค้นหาประกาศและข่าวสาร...' : 'Search notices and updates...',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.white38
                                      : DormMateColors.textTertiary,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white
                                    : DormMateColors.textPrimary,
                              ),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {});
                                vm.setSearchQuery('');
                              },
                              child: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: isDark
                                    ? Colors.white38
                                    : DormMateColors.textTertiary,
                              ),
                            ),
                        ],
                      ),
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
                          child: GestureDetector(
                            onTap: () => vm.setCategory(cat),
                            child: isSelected
                                // Selected: gradient NeuContainer (embossed)
                                ? NeuContainer(
                                    isDark: isDark,
                                    isInset: false,
                                    borderRadius: 20,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 6),
                                    bgColor: const Color(0xFF667EEA),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF667EEA),
                                            Color(0xFF764BA2),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            getCategoryLabel(cat),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          if (cat == 'Unread' && vm.unreadCount > 0) ...[
                                            const SizedBox(width: 5),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 5, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                '${vm.unreadCount}',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF667EEA),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  )
                                // Unselected: small embossed NeuContainer
                                : NeuContainer(
                                    isDark: isDark,
                                    isInset: false,
                                    borderRadius: 20,
                                    shadowIntensity: 0.6,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 6),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          getCategoryLabel(cat),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? Colors.white60
                                                : DormMateColors.textSecondary,
                                          ),
                                        ),
                                        if (cat == 'Unread' && vm.unreadCount > 0) ...[
                                          const SizedBox(width: 5),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 1),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFF667EEA),
                                                  Color(0xFF764BA2),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              '${vm.unreadCount}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
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
                              title: isThai ? 'ไม่พบประกาศ' : 'No Announcements Found',
                              subtitle: vm.searchQuery.isNotEmpty ||
                                      vm.selectedCategory != 'All'
                                  ? (isThai
                                      ? 'ไม่มีประกาศที่ตรงกับคำค้นหาหรือตัวกรองของคุณ'
                                      : 'No announcements match your search or filter.')
                                  : (isThai
                                      ? 'ไม่มีประกาศหอพักในขณะนี้'
                                      : 'There are no dormitory notices at this time.'),
                              actionText: vm.searchQuery.isNotEmpty ||
                                      vm.selectedCategory != 'All'
                                  ? (isThai ? 'ล้างตัวกรอง' : 'Clear Filters')
                                  : null,
                              onAction: vm.searchQuery.isNotEmpty ||
                                      vm.selectedCategory != 'All'
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
                                padding: const EdgeInsets.only(
                                    left: 18, right: 18, top: 6, bottom: 96),
                                itemCount: vm.filteredAnnouncements.length,
                                itemBuilder: (context, index) {
                                  final ann = vm.filteredAnnouncements[index];
                                  return FadeSlideEntry(
                                    key: ValueKey(ann.id),
                                    delay: Duration(milliseconds: 30 * index),
                                    child: AnnouncementCard(
                                      announcement: ann,
                                      onTap: () =>
                                          context.go('/announcements/${ann.id}'),
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
