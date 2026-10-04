import 'package:flutter/material.dart';
import '../core/constants/dormmate_constants.dart';
import '../core/localization/language_service.dart';
import '../models/maintenance_request.dart';
import '../widgets/neumorphic.dart';
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

  String _getCategoryLabel(String category, bool isThai) {
    if (!isThai) return category;
    switch (category.toLowerCase()) {
      case 'air conditioner':
        return 'เครื่องปรับอากาศ';
      case 'water':
      case 'bathroom':
        return 'ระบบประปา / ห้องน้ำ';
      case 'electrical':
        return 'ระบบไฟฟ้า';
      case 'furniture':
        return 'เฟอร์นิเจอร์';
      case 'internet':
        return 'อินเทอร์เน็ต';
      case 'cleaning':
        return 'ทำความสะอาด';
      default:
        return category;
    }
  }

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

  List<Color> _getCategoryGradient(String category) {
    switch (category.toLowerCase()) {
      case 'air conditioner':
        return NeuColors.accentGradient;
      case 'water':
      case 'bathroom':
        return NeuColors.blueGradient;
      case 'electrical':
        return NeuColors.warmGradient;
      case 'furniture':
        return const [Color(0xFF8B5CF6), Color(0xFFA78BFA)];
      case 'internet':
        return NeuColors.greenGradient;
      default:
        return NeuColors.primaryGradient;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final icon = _getCategoryIcon(request.category);
    final gradient = _getCategoryGradient(request.category);

    Widget content = NeuContainer(
      isDark: isDark,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      borderRadius: 18,
      shadowIntensity: 0.85,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Category icon with gradient
          NeuIconBox(
            icon: icon,
            iconColor: gradient.first,
            isDark: isDark,
            gradientColors: gradient,
            size: 46,
            iconSize: 22,
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
                    fontWeight: FontWeight.w700,
                    color: DormMateColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_getCategoryLabel(request.category, context.isThai)} · ${request.displayDate}',
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
                      NeuBadge(
                        text: context.tr(request.urgency, request.urgency == 'Emergency' ? 'ฉุกเฉิน' : (request.urgency == 'High' ? 'เร่งด่วน' : 'ปกติ')),
                        color: request.urgency == 'Emergency'
                            ? DormMateColors.statusError
                            : DormMateColors.statusPending,
                        isDark: isDark,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              StatusBadge(status: request.status),
              const SizedBox(height: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: DormMateColors.textDisabled,
                size: 18,
              ),
            ],
          ),
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
            gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(DormMateDimens.radiusMd),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.delete_outline, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                context.tr('Cancel', 'ยกเลิก'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
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
              title: Text(context.tr('Cancel Request', 'ยกเลิกคำขอ')),
              content: Text(
                context.tr('Are you sure you want to cancel this maintenance request?', 'คุณแน่ใจหรือไม่ว่าต้องการยกเลิกคำขอแจ้งซ่อมนี้?'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(context.tr('Keep', 'คงไว้')),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(
                    context.tr('Cancel Request', 'ยืนยันยกเลิก'),
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
