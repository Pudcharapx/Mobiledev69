import 'package:flutter/material.dart';
import '../core/constants/dormmate_constants.dart';
import '../models/announcement.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.84),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.95),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6, right: 12),
              decoration: BoxDecoration(
                color: announcement.isRead
                    ? DormMateColors.textDisabled
                    : DormMateColors.primary,
                shape: BoxShape.circle,
                boxShadow: announcement.isRead
                    ? null
                    : [
                        BoxShadow(
                          color: DormMateColors.primary.withValues(alpha: 0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
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
                      fontWeight: announcement.isRead
                          ? FontWeight.w500
                          : FontWeight.w700,
                      color: DormMateColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    announcement.summary,
                    style: TextStyle(
                      fontSize: 12,
                      color: DormMateColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    announcement.displayDate,
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
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
