import 'package:flutter/material.dart';
import '../core/constants/dormmate_constants.dart';
import '../models/maintenance_request.dart';
import 'status_badge.dart';

class MaintenanceCard extends StatelessWidget {
  final MaintenanceRequest request;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  const MaintenanceCard({
    super.key,
    required this.request,
    this.onTap,
    this.onCancel,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'air conditioner':
        return Icons.ac_unit_rounded;
      case 'water':
      case 'bathroom':
        return Icons.water_drop_outlined;
      case 'electrical':
        return Icons.bolt_rounded;
      case 'furniture':
        return Icons.chair_outlined;
      case 'internet':
        return Icons.wifi_rounded;
      case 'cleaning':
        return Icons.cleaning_services_outlined;
      default:
        return Icons.build_outlined;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'air conditioner':
        return DormMateColors.primary;
      case 'water':
      case 'bathroom':
        return const Color(0xFF007AFF);
      case 'electrical':
        return const Color(0xFFFF9500);
      default:
        return DormMateColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getCategoryIcon(request.category);
    final color = _getCategoryColor(request.category);

    Widget content = Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.95),
          width: 1.2,
        ),
        boxShadow: [
          const BoxShadow(
            color: Color(0x09000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.16),
                  color.withValues(alpha: 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: color.withValues(alpha: 0.22),
                width: 1,
              ),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: DormMateColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${request.category} · ${request.displayDate}',
                        style: TextStyle(
                          fontSize: 12,
                          color: DormMateColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (request.urgency != 'Normal') ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: request.urgency == 'Emergency'
                              ? const Color(0xFFFFEBEE)
                              : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: request.urgency == 'Emergency'
                                ? const Color(0xFFFFCDD2)
                                : const Color(0xFFFFE0B2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          request.urgency,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: request.urgency == 'Emergency'
                                ? const Color(0xFFD32F2F)
                                : const Color(0xFFE65100),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusBadge(status: request.status),
        ],
      ),
    );

    if (request.isDeletable && onCancel != null) {
      return Dismissible(
        key: ValueKey(request.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: DormMateColors.statusErrorBg,
            borderRadius: BorderRadius.circular(DormMateDimens.radiusMd),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline, color: DormMateColors.statusErrorText),
              const SizedBox(width: 4),
              Text(
                'Cancel',
                style: TextStyle(
                  color: DormMateColors.statusErrorText,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DormMateDimens.radiusLg),
              ),
              title: const Text('Cancel Request'),
              content: const Text(
                'Are you sure you want to cancel this maintenance request?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Keep'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(
                    'Cancel Request',
                    style: TextStyle(color: DormMateColors.statusErrorText),
                  ),
                ),
              ],
            ),
          );
        },
        onDismissed: (_) => onCancel!(),
        child: GestureDetector(onTap: onTap, child: content),
      );
    }

    return GestureDetector(onTap: onTap, child: content);
  }
}
