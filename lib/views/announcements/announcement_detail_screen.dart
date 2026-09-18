import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/dormmate_constants.dart';
import '../../viewmodels/announcement_viewmodel.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/state_views.dart';

class AnnouncementDetailScreen extends StatefulWidget {
  final int announcementId;

  const AnnouncementDetailScreen({super.key, required this.announcementId});

  @override
  State<AnnouncementDetailScreen> createState() => _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementViewModel>().selectAnnouncement(widget.announcementId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnnouncementViewModel>();
    final ann = vm.selectedAnnouncement;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcement'),
      ),
      body: vm.isLoading
          ? const LoadingView(message: 'Loading...')
          : vm.errorMessage != null
              ? ErrorView(
                  message: vm.errorMessage!,
                  onRetry: () => vm.selectAnnouncement(widget.announcementId),
                )
              : ann == null
                  ? const EmptyStateView(
                      icon: Icons.article_outlined,
                      title: 'Not Found',
                      subtitle: 'The announcement could not be found.',
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GlassCard(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: DormMateColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'NOTICE',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: DormMateColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      ann.displayDate,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: DormMateColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  ann.title,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: DormMateColors.textPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Divider(color: DormMateColors.divider),
                                const SizedBox(height: 12),
                                Text(
                                  ann.content,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: DormMateColors.textPrimary,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
