import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/dormmate_constants.dart';
import '../../core/localization/language_service.dart';
import '../../viewmodels/announcement_viewmodel.dart';
import '../../widgets/state_views.dart';
import '../../widgets/neumorphic.dart';
import '../../widgets/language_toggle_button.dart';

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

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      try {
        context.go('/announcements');
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnnouncementViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ann = vm.selectedAnnouncement;

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
          context.tr('Announcement', 'ประกาศหอพัก'),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A2035),
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          LanguageToggleButton(isDark: isDark),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedOrbBackground(
        isDark: isDark,
        child: vm.isLoading
            ? LoadingView(message: context.tr('Loading...', 'กำลังโหลด...'))
            : vm.errorMessage != null
                ? ErrorView(
                    message: vm.errorMessage!,
                    onRetry: () => vm.selectAnnouncement(widget.announcementId),
                  )
                : ann == null
                    ? EmptyStateView(
                        icon: Icons.article_outlined,
                        title: context.tr('Not Found', 'ไม่พบข้อมูล'),
                        subtitle: context.tr('The announcement could not be found.', 'ไม่พบประกาศที่ระบุ'),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            NeuContainer(
                              isDark: isDark,
                              padding: const EdgeInsets.all(22),
                              borderRadius: 22,
                              shadowIntensity: 0.85,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          context.tr('NOTICE', 'ประกาศ'),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        ann.displayDate,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: DormMateColors.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    ann.title,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: DormMateColors.textPrimary,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Divider(color: isDark ? const Color(0xFF28334E) : DormMateColors.divider),
                                  const SizedBox(height: 14),
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
                            const SizedBox(height: 64),
                          ],
                        ),
                      ),
      ),
    );
  }
}
