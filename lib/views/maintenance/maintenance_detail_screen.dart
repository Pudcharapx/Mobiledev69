import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/dormmate_constants.dart';
import '../../core/localization/language_service.dart';
import '../../viewmodels/maintenance_viewmodel.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/state_views.dart';
import '../../widgets/neumorphic.dart';
import '../../widgets/language_toggle_button.dart';

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

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      try {
        context.go('/maintenance');
      } catch (_) {}
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

  String _getCategoryName(String cat, BuildContext context) {
    if (!context.isThai) return cat;
    switch (cat) {
      case 'Air Conditioner': return 'เครื่องปรับอากาศ (แอร์)';
      case 'Electrical': return 'ระบบไฟฟ้า / หลอดไฟ';
      case 'Plumbing': return 'ระบบประปา / ท่อน้ำ';
      case 'Furniture': return 'เฟอร์นิเจอร์ / โต๊ะตู้เตียง';
      case 'Door & Window': return 'ประตู / หน้าต่าง / ลูกบิด';
      case 'Appliance': return 'เครื่องใช้ไฟฟ้า';
      default: return cat;
    }
  }

  Widget _buildUrgencyBadge(String urgency, bool isDark) {
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
        bg = isDark ? const Color(0xFF28334E) : const Color(0xFFE8EEF8);
        text = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF555555);
        icon = Icons.check_circle_outline_rounded;
        break;
    }

    String displayUrgency = urgency;
    if (context.isThai) {
      if (urgency.toLowerCase() == 'emergency') {
        displayUrgency = 'ฉุกเฉิน';
      } else if (urgency.toLowerCase() == 'high') {
        displayUrgency = 'ด่วน';
      } else {
        displayUrgency = 'ปกติ';
      }
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
            displayUrgency,
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
      circleColor = const Color(0xFFCBD5E1);
      icon = const SizedBox(width: 6, height: 6);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
                boxShadow: (isDone || isActive)
                    ? [
                        BoxShadow(
                          color: circleColor.withValues(alpha: 0.35),
                          blurRadius: 8,
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
                height: 38,
                color: isDone ? DormMateColors.statusCompleted : const Color(0xFFCBD5E1),
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
                            : DormMateColors.textSecondary,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final req = vm.selectedRequest;

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
          context.tr('Request Details', 'รายละเอียดการแจ้งซ่อม'),
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
        child: vm.isLoading && req == null
            ? LoadingView(message: context.tr('Loading request details...', 'กำลังโหลดรายละเอียดการแจ้งซ่อม...'))
            : vm.errorMessage != null && req == null
                ? ErrorView(
                    message: vm.errorMessage!,
                    onRetry: () => vm.selectRequest(widget.requestId),
                  )
                : req == null
                    ? EmptyStateView(
                        icon: Icons.search_off_rounded,
                        title: context.tr('Request Not Found', 'ไม่พบข้อมูลคำขอ'),
                        subtitle: context.tr('The requested maintenance record could not be found.', 'ไม่พบรายการแจ้งซ่อมที่ระบุ'),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header NeuContainer
                            NeuContainer(
                              isDark: isDark,
                              padding: const EdgeInsets.all(20),
                              borderRadius: 22,
                              shadowIntensity: 0.85,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      NeuIconBox(
                                        icon: _getCategoryIcon(req.category),
                                        iconColor: _getCategoryGradient(req.category).first,
                                        isDark: isDark,
                                        gradientColors: _getCategoryGradient(req.category),
                                        size: 48,
                                        iconSize: 24,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _getCategoryName(req.category, context),
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: DormMateColors.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              req.displayDate,
                                              style: TextStyle(
                                                fontSize: 12,
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
                                      fontSize: 19,
                                      fontWeight: FontWeight.w800,
                                      color: DormMateColors.textPrimary,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      _buildUrgencyBadge(req.urgency, isDark),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF28334E) : const Color(0xFFEFF2F8),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.schedule_rounded, size: 13, color: DormMateColors.textSecondary),
                                            const SizedBox(width: 4),
                                            Text(
                                              req.preferredTimeSlot,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: DormMateColors.textSecondary,
                                                fontWeight: FontWeight.w600,
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
                            Text(context.tr('DESCRIPTION', 'รายละเอียด'), style: DormMateTextStyles.label),
                            const SizedBox(height: 8),
                            NeuContainer(
                              isDark: isDark,
                              padding: const EdgeInsets.all(18),
                              borderRadius: 18,
                              child: SizedBox(
                                width: double.infinity,
                                child: Text(
                                  req.description.isEmpty ? context.tr('No description provided.', 'ไม่มีรายละเอียดเพิ่มเติม') : req.description,
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
                            Text(context.tr('STATUS TIMELINE', 'ไทม์ไลน์สถานะ'), style: DormMateTextStyles.label),
                            const SizedBox(height: 8),
                            NeuContainer(
                              isDark: isDark,
                              padding: const EdgeInsets.all(20),
                              borderRadius: 20,
                              child: Column(
                                children: [
                                  if (req.status == 'Cancelled') ...[
                                    _buildTimelineStep(
                                      title: context.tr('Request Submitted', 'ส่งคำขอแจ้งซ่อมแล้ว'),
                                      subtitle: context.tr('Submitted on ${req.displayDate}', 'แจ้งเมื่อ ${req.displayDate}'),
                                      isDone: true,
                                      isActive: false,
                                      isLast: false,
                                    ),
                                    _buildTimelineStep(
                                      title: context.tr('Request Cancelled', 'ยกเลิกคำขอแล้ว'),
                                      subtitle: context.tr('Cancelled by resident', 'ยกเลิกโดยผู้พักอาศัย'),
                                      isDone: true,
                                      isActive: false,
                                      isLast: true,
                                      isCancelled: true,
                                    ),
                                  ] else ...[
                                    _buildTimelineStep(
                                      title: context.tr('Request Submitted', 'ส่งคำขอแจ้งซ่อมแล้ว'),
                                      subtitle: context.tr('Problem reported on ${req.displayDate}', 'แจ้งปัญหาเมื่อ ${req.displayDate}'),
                                      isDone: true,
                                      isActive: false,
                                      isLast: false,
                                    ),
                                    _buildTimelineStep(
                                      title: context.tr('Technician Assigned', 'มอบหมายช่างแล้ว'),
                                      subtitle: req.status == 'Pending'
                                          ? context.tr('Pending dormitory staff assignment', 'รอเจ้าหน้าที่หอพักมอบหมายช่าง')
                                          : context.tr('Assigned to facility maintenance crew', 'มอบหมายทีมช่างอาคารแล้ว'),
                                      isDone: req.status == 'In Progress' || req.status == 'Completed',
                                      isActive: req.status == 'Pending',
                                      isLast: false,
                                    ),
                                    _buildTimelineStep(
                                      title: context.tr('Repair In Progress', 'กำลังดำเนินการซ่อม'),
                                      subtitle: req.status == 'Completed'
                                          ? context.tr('Inspection and repair completed', 'ตรวจเช็คและซ่อมแซมเสร็จสิ้น')
                                          : req.status == 'In Progress'
                                              ? context.tr('Technician currently resolving the issue', 'ช่างกำลังดำเนินการแก้ไขปัญหา')
                                              : context.tr('Scheduled visit during ${req.preferredTimeSlot}', 'นัดหมายเข้าซ่อมในช่วง ${req.preferredTimeSlot}'),
                                      isDone: req.status == 'Completed',
                                      isActive: req.status == 'In Progress',
                                      isLast: false,
                                    ),
                                    _buildTimelineStep(
                                      title: context.tr('Completed & Verified', 'เสร็จสิ้นและยืนยันผล'),
                                      subtitle: req.status == 'Completed'
                                          ? context.tr('Issue resolved successfully', 'แก้ไขปัญหาเรียบร้อยแล้ว')
                                          : context.tr('Awaiting repair completion and sign-off', 'รอการซ่อมแซมเสร็จสิ้นและตรวจรับงาน'),
                                      isDone: req.status == 'Completed',
                                      isActive: false,
                                      isLast: true,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            NeuButton(
                              isDark: isDark,
                              gradientColors: const [Color(0xFF667EEA), Color(0xFF764BA2)],
                              borderRadius: 16,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              onTap: () {
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
                                            context.tr('Contact Dorm Staff & Technicians', 'ติดต่อเจ้าหน้าที่หอพักและทีมช่าง'),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: DormMateColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            context.tr(
                                              'Available Mon-Sun 08:30 - 18:00 · Emergency 24/7',
                                              'เปิดทำการ จ.-อา. 08:30 - 18:00 · ฉุกเฉิน 24 ชม.',
                                            ),
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
                                            title: Text(
                                              context.tr('Building B Office', 'สำนักงานหอพัก ตึก B'),
                                              style: TextStyle(fontWeight: FontWeight.w600, color: DormMateColors.textPrimary),
                                            ),
                                            subtitle: Text(
                                              context.tr('02-888-2424 · Tap to call', '02-888-2424 · แตะเพื่อโทรออก'),
                                              style: TextStyle(color: DormMateColors.textSecondary),
                                            ),
                                            onTap: () {
                                              Navigator.pop(ctx);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    context.tr('Calling Dorm Office: 02-888-2424...', 'กำลังโทรหาสำนักงานหอพัก: 02-888-2424...'),
                                                  ),
                                                ),
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
                                            title: Text(
                                              context.tr('Technician LINE Official', 'LINE Official ช่างซ่อม'),
                                              style: TextStyle(fontWeight: FontWeight.w600, color: DormMateColors.textPrimary),
                                            ),
                                            subtitle: Text(
                                              context.tr('@dormmate_repair · Chat with staff', '@dormmate_repair · แชทสอบถามเจ้าหน้าที่'),
                                              style: TextStyle(color: DormMateColors.textSecondary),
                                            ),
                                            onTap: () {
                                              Navigator.pop(ctx);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    context.tr('Opening LINE: @dormmate_repair', 'กำลังเปิด LINE: @dormmate_repair'),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.support_agent_rounded, size: 20, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    context.tr('Contact Dorm Office / Technician', 'ติดต่อสำนักงาน / ช่างซ่อม'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Cancel request action if permitted
                            if (req.isDeletable) ...[
                              const SizedBox(height: 12),
                              NeuButton(
                                isDark: isDark,
                                gradientColors: const [Color(0xFFEF4444), Color(0xFFDC2626)],
                                borderRadius: 16,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                onTap: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(DormMateDimens.radiusLg),
                                      ),
                                      title: Text(context.tr('Cancel Request', 'ยกเลิกคำขอ')),
                                      content: Text(
                                        context.tr(
                                          'Are you sure you want to cancel this maintenance request?',
                                          'คุณแน่ใจหรือไม่ว่าต้องการยกเลิกคำขอแจ้งซ่อมนี้?',
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, false),
                                          child: Text(context.tr('Keep Request', 'ไม่ยกเลิก')),
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

                                  if (confirmed == true && context.mounted) {
                                    final ok = await vm.cancelRequest(req.id);
                                    if (ok && context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(context.tr('Maintenance request cancelled', 'ยกเลิกคำขอแจ้งซ่อมเรียบร้อยแล้ว')),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                      _handleBack();
                                    }
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.white),
                                    const SizedBox(width: 6),
                                    Text(
                                      context.tr('Cancel Request', 'ยกเลิกคำขอ'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 96),
                          ],
                        ),
                      ),
      ),
    );
  }
}
