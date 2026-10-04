import 'package:flutter/material.dart';
import '../core/constants/dormmate_constants.dart';
import '../core/localization/language_service.dart';
import '../models/announcement.dart';
import '../widgets/neumorphic.dart';

class AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final VoidCallback? onTap;

  const AnnouncementCard({
    super.key,
    required this.announcement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnread = !announcement.isRead;

    return GestureDetector(
      onTap: onTap,
      child: NeuContainer(
        isDark: isDark,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 10),
        borderRadius: 18,
        shadowIntensity: 0.85,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread indicator dot
            Padding(
              padding: const EdgeInsets.only(top: 6, right: 12),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isUnread
                      ? const LinearGradient(
                          colors: NeuColors.primaryGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isUnread ? null : DormMateColors.textDisabled.withValues(alpha: 0.4),
                  boxShadow: isUnread
                      ? [
                          BoxShadow(
                            color: const Color(0xFF667EEA).withValues(alpha: 0.50),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    announcement.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                      color: DormMateColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    announcement.summary,
                    style: TextStyle(
                      fontSize: 12,
                      color: DormMateColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 11,
                        color: DormMateColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        announcement.displayDate,
                        style: TextStyle(
                          fontSize: 11,
                          color: DormMateColors.textTertiary,
                        ),
                      ),
                      if (isUnread) ...[
                        const SizedBox(width: 10),
                        NeuBadge(
                          text: context.tr('NEW', 'ใหม่'),
                          color: const Color(0xFF667EEA),
                          isDark: isDark,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: DormMateColors.textDisabled,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
