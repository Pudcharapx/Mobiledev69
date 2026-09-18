import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/dormmate_constants.dart';
import '../../viewmodels/maintenance_viewmodel.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/state_views.dart';

class MaintenanceDetailScreen extends StatefulWidget {
  final int requestId;

  const MaintenanceDetailScreen({super.key, required this.requestId});

  @override
  State<MaintenanceDetailScreen> createState() => _MaintenanceDetailScreenState();
}

class _MaintenanceDetailScreenState extends State<MaintenanceDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaintenanceViewModel>().selectRequest(widget.requestId);
    });
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

  Widget _buildUrgencyBadge(String urgency) {
    Color bg;
    Color text;
    IconData icon;

    switch (urgency.toLowerCase()) {
      case 'emergency':
        bg = const Color(0xFFFFE5E5);
        text = const Color(0xFFD32F2F);
        icon = Icons.warning_amber_rounded;
        break;
      case 'high':
        bg = const Color(0xFFFFF4E5);
        text = const Color(0xFFE65100);
        icon = Icons.priority_high_rounded;
        break;
      case 'normal':
      default:
        bg = const Color(0xFFF0F0F5);
        text = const Color(0xFF555555);
        icon = Icons.check_circle_outline_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: text),
          const SizedBox(width: 4),
          Text(
            urgency,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required bool isDone,
    required bool isActive,
    required bool isLast,
    bool isCancelled = false,
  }) {
    Color circleColor;
    Widget icon;

    if (isCancelled) {
      circleColor = DormMateColors.statusError;
      icon = const Icon(Icons.close_rounded, size: 14, color: Colors.white);
    } else if (isDone) {
      circleColor = DormMateColors.statusCompleted;
      icon = const Icon(Icons.check_rounded, size: 14, color: Colors.white);
    } else if (isActive) {
      circleColor = DormMateColors.primary;
      icon = const Icon(Icons.hourglass_top_rounded, size: 13, color: Colors.white);
    } else {
      circleColor = const Color(0xFFE0E0E0);
      icon = const SizedBox(width: 6, height: 6);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
                boxShadow: (isDone || isActive)
                    ? [
                        BoxShadow(
                          color: circleColor.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Center(child: icon),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: isDone ? DormMateColors.statusCompleted : const Color(0xFFE5E5EA),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isDone || isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isCancelled
                        ? DormMateColors.statusErrorText
                        : isDone || isActive
                            ? DormMateColors.textPrimary
                            : DormMateColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: DormMateColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MaintenanceViewModel>();
    final req = vm.selectedRequest;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Details'),
      ),
      body: vm.isLoading && req == null
          ? const LoadingView(message: 'Loading request details...')
          : vm.errorMessage != null && req == null
              ? ErrorView(
                  message: vm.errorMessage!,
                  onRetry: () => vm.selectRequest(widget.requestId),
                )
              : req == null
                  ? const EmptyStateView(
                      icon: Icons.search_off_rounded,
                      title: 'Request Not Found',
                      subtitle: 'The requested maintenance record could not be found.',
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header GlassCard
                          GlassCard(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: _getCategoryColor(req.category).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _getCategoryIcon(req.category),
                                        color: _getCategoryColor(req.category),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            req.category,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: DormMateColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            req.displayDate,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: DormMateColors.textTertiary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    StatusBadge(status: req.status),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  req.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: DormMateColors.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _buildUrgencyBadge(req.urgency),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0x0A000000),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.schedule_rounded, size: 12, color: DormMateColors.textSecondary),
                                          const SizedBox(width: 4),
                                          Text(
                                            req.preferredTimeSlot,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: DormMateColors.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Description
                          Text('DESCRIPTION', style: DormMateTextStyles.label),
                          const SizedBox(height: 8),
                          GlassCard(
                            padding: const EdgeInsets.all(18),
                            child: SizedBox(
                              width: double.infinity,
                              child: Text(
                                req.description.isEmpty ? 'No description provided.' : req.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: DormMateColors.textPrimary,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Status Tracking Timeline
                          Text('STATUS TIMELINE', style: DormMateTextStyles.label),
                          const SizedBox(height: 8),
                          GlassCard(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                if (req.status == 'Cancelled') ...[
                                  _buildTimelineStep(
                                    title: 'Request Submitted',
                                    subtitle: 'Submitted on ${req.displayDate}',
                                    isDone: true,
                                    isActive: false,
                                    isLast: false,
                                  ),
                                  _buildTimelineStep(
                                    title: 'Request Cancelled',
                                    subtitle: 'Cancelled by resident',
                                    isDone: true,
                                    isActive: false,
                                    isLast: true,
                                    isCancelled: true,
                                  ),
                                ] else ...[
                                  _buildTimelineStep(
                                    title: 'Request Submitted',
                                    subtitle: 'Problem reported on ${req.displayDate}',
                                    isDone: true,
                                    isActive: false,
                                    isLast: false,
                                  ),
                                  _buildTimelineStep(
                                    title: 'Technician Assigned',
                                    subtitle: req.status == 'Pending'
                                        ? 'Pending dormitory staff assignment'
                                        : 'Assigned to facility maintenance crew',
                                    isDone: req.status == 'In Progress' || req.status == 'Completed',
                                    isActive: req.status == 'Pending',
                                    isLast: false,
                                  ),
                                  _buildTimelineStep(
                                    title: 'Repair In Progress',
                                    subtitle: req.status == 'Completed'
                                        ? 'Inspection and repair completed'
                                        : req.status == 'In Progress'
                                            ? 'Technician currently resolving the issue'
                                            : 'Scheduled visit during ${req.preferredTimeSlot}',
                                    isDone: req.status == 'Completed',
                                    isActive: req.status == 'In Progress',
                                    isLast: false,
                                  ),
                                  _buildTimelineStep(
                                    title: 'Completed & Verified',
                                    subtitle: req.status == 'Completed'
                                        ? 'Issue resolved successfully'
                                        : 'Awaiting repair completion and sign-off',
                                    isDone: req.status == 'Completed',
                                    isActive: false,
                                    isLast: true,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DormMateColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(DormMateDimens.radiusMd),
                                ),
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  builder: (ctx) => SafeArea(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Contact Dorm Staff & Technicians',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: DormMateColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Available Mon-Sun 08:30 - 18:00 · Emergency 24/7',
                                            style: TextStyle(fontSize: 12, color: DormMateColors.textSecondary),
                                          ),
                                          const SizedBox(height: 16),
                                          ListTile(
                                            leading: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Icon(Icons.phone_rounded, color: Color(0xFF007AFF)),
                                            ),
                                            title: Text('Building B Office', style: TextStyle(fontWeight: FontWeight.w600, color: DormMateColors.textPrimary)),
                                            subtitle: Text('02-888-2424 · Tap to call', style: TextStyle(color: DormMateColors.textSecondary)),
                                            onTap: () {
                                              Navigator.pop(ctx);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Calling Dorm Office: 02-888-2424...')),
                                              );
                                            },
                                          ),
                                          ListTile(
                                            leading: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF34C759).withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF34C759)),
                                            ),
                                            title: Text('Technician LINE Official', style: TextStyle(fontWeight: FontWeight.w600, color: DormMateColors.textPrimary)),
                                            subtitle: Text('@dormmate_repair · Chat with staff', style: TextStyle(color: DormMateColors.textSecondary)),
                                            onTap: () {
                                              Navigator.pop(ctx);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Opening LINE: @dormmate_repair')),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.support_agent_rounded, size: 18),
                              label: const Text('Contact Dorm Office / Technician'),
                            ),
                          ),

                          // Cancel request action if permitted
                          if (req.isDeletable) ...[
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: DormMateColors.statusErrorText,
                                  side: const BorderSide(color: Color(0x33FF3B30)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(DormMateDimens.radiusMd),
                                  ),
                                ),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
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
                                          child: const Text('Keep Request'),
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

                                  if (confirmed == true && context.mounted) {
                                    final ok = await vm.cancelRequest(req.id);
                                    if (ok && context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Maintenance request cancelled'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                      context.pop();
                                    }
                                  }
                                },
                                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                label: const Text('Cancel Request'),
                              ),
                            ),
                          ],

                          const SizedBox(height: 96),
                        ],
                      ),
                    ),
    );
  }
}
