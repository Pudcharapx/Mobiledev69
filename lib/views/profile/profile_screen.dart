import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/dormmate_constants.dart';
import '../../core/theme/dormmate_theme_presets.dart';
import '../../core/theme/dormmate_theme_service.dart';
import '../../core/localization/language_service.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/state_views.dart';
import '../../widgets/app_animations.dart';
import '../../widgets/neumorphic.dart';
import '../../widgets/language_toggle_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifyBills = true;
  bool _notifyMaintenance = true;
  bool _notifyNotices = true;
  bool _notifySound = true;
  String _selectedTheme = 'Light Glassmorphic';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadProfile();
    });
  }

  void _showPersonalInfoSheet(String displayName, String email, String roomDisplay) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.85,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: DormMateColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: DormMateColors.primary,
                      child: Text(
                        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(displayName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: DormMateColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text(email, style: TextStyle(fontSize: 12, color: DormMateColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(height: 1, color: DormMateColors.divider),
                const SizedBox(height: 12),
                _buildInfoRow(context.tr('Student / Resident ID', 'รหัสนักศึกษา / ผู้พัก'), 'STD-6510204'),
                _buildInfoRow(context.tr('Room Number', 'หมายเลขห้องพัก'), '${context.tr('Room', 'ห้อง')} $roomDisplay (${context.tr('Building B', 'อาคาร B')})'),
                _buildInfoRow(context.tr('Contact Phone', 'เบอร์ติดต่อ'), '081-234-5678'),
                _buildInfoRow(context.tr('Emergency Contact', 'ผู้ติดต่อฉุกเฉิน'), '089-876-5432 (${context.tr('Parent', 'ผู้ปกครอง')})'),
                _buildInfoRow(context.tr('Lease Term', 'ระยะเวลาสัญญาเช่า'), 'Aug 2026 - May 2027 (${context.tr('Active', 'ใช้งานอยู่')})'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(context.tr('Close', 'ปิด')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRoomDetailsSheet(String roomDisplay) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.85,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: DormMateColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  context.tr('Room Information', 'ข้อมูลห้องพัก'),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: DormMateColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  context.isThai ? 'ห้อง $roomDisplay · อาคาร B · ชั้น 2' : 'Room $roomDisplay · Building B · Floor 2',
                  style: TextStyle(fontSize: 13, color: DormMateColors.textSecondary),
                ),
                const SizedBox(height: 18),
                _buildInfoRow(context.tr('Room Type', 'ประเภทห้อง'), context.tr('Twin Room (2 Residents)', 'ห้องเตียงคู่ (2 คน)')),
                _buildInfoRow(context.tr('Bed Assignment', 'ตำแหน่งเตียง'), context.tr('Bed 01 (Left Side)', 'เตียง 01 (ฝั่งซ้าย)')),
                _buildInfoRow(context.tr('Wi-Fi Network', 'ชื่อเครือข่าย Wi-Fi'), 'DormMate_B204'),
                _buildInfoRow(context.tr('Wi-Fi Password', 'รหัสผ่าน Wi-Fi'), 'dormmate2026'),
                _buildInfoRow(context.tr('Keycard Number', 'หมายเลขคีย์การ์ด'), 'KC-990234-B'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DormMateColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(text: 'dormmate2026'));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.tr('Wi-Fi password copied to clipboard!', 'คัดลอกรหัสผ่าน Wi-Fi แล้ว!'))),
                      );
                    },
                    icon: const Icon(Icons.wifi_rounded, size: 18),
                    label: Text(context.tr('Copy Wi-Fi Password', 'คัดลอกรหัส Wi-Fi')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: DormMateColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('Notification Preferences', 'ตั้งค่าการแจ้งเตือน'),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: DormMateColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr('Choose which dormitory alerts you wish to receive', 'เลือกรายการแจ้งเตือนหอพักที่คุณต้องการรับ'),
                    style: TextStyle(fontSize: 12, color: DormMateColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      context.tr('Bill Due Date Reminders', 'แจ้งเตือนกำหนดชำระบิล'),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DormMateColors.textPrimary),
                    ),
                    subtitle: Text(
                      context.tr('Alert when monthly bills are published or overdue', 'แจ้งเตือนเมื่อออกบิลใหม่หรือใกล้ครบกำหนด'),
                      style: TextStyle(fontSize: 11, color: DormMateColors.textSecondary),
                    ),
                    value: _notifyBills,
                    activeTrackColor: DormMateColors.primary,
                    onChanged: (val) {
                      setState(() => _notifyBills = val);
                      setSheetState(() {});
                    },
                  ),
                  Divider(height: 1, color: DormMateColors.divider),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      context.tr('Maintenance Status Updates', 'อัปเดตสถานะแจ้งซ่อม'),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DormMateColors.textPrimary),
                    ),
                    subtitle: Text(
                      context.tr('Notify when technician is assigned or job completed', 'แจ้งเตือนเมื่อมอบหมายช่างหรือซ่อมเสร็จสิ้น'),
                      style: TextStyle(fontSize: 11, color: DormMateColors.textSecondary),
                    ),
                    value: _notifyMaintenance,
                    activeTrackColor: DormMateColors.primary,
                    onChanged: (val) {
                      setState(() => _notifyMaintenance = val);
                      setSheetState(() {});
                    },
                  ),
                  Divider(height: 1, color: DormMateColors.divider),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      context.tr('Urgent Announcements', 'ประกาศด่วนจากหอพัก'),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DormMateColors.textPrimary),
                    ),
                    subtitle: Text(
                      context.tr('Water/power shut-off, inspections, fire safety', 'แจ้งตัดน้ำ/ไฟ, ตรวจห้อง, ซ้อมหนีไฟ'),
                      style: TextStyle(fontSize: 11, color: DormMateColors.textSecondary),
                    ),
                    value: _notifyNotices,
                    activeTrackColor: DormMateColors.primary,
                    onChanged: (val) {
                      setState(() => _notifyNotices = val);
                      setSheetState(() {});
                    },
                  ),
                  Divider(height: 1, color: DormMateColors.divider),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      context.tr('In-App Haptics & Sound', 'ระบบสั่นและเสียงในแอป'),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DormMateColors.textPrimary),
                    ),
                    subtitle: Text(
                      context.tr('Vibration feedback on tap and submit', 'สั่นตอบสนองเมื่อกดปุ่มหรือส่งคำขอ'),
                      style: TextStyle(fontSize: 11, color: DormMateColors.textSecondary),
                    ),
                    value: _notifySound,
                    activeTrackColor: DormMateColors.primary,
                    onChanged: (val) {
                      setState(() => _notifySound = val);
                      setSheetState(() {});
                    },
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DormMateColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.tr('Notification preferences saved', 'บันทึกการตั้งค่าการแจ้งเตือนแล้ว'))),
                        );
                      },
                      child: Text(context.tr('Done', 'เสร็จสิ้น')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAppearanceSheet() {
    DormMateThemeService? themeService;
    try {
      themeService = context.read<DormMateThemeService>();
    } catch (_) {}

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: DormMateColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr('Appearance & Theme', 'ธีมและรูปลักษณ์'),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: DormMateColors.textPrimary),
                      ),
                      if (themeService != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: DormMateColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            themeService.preset.title,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: DormMateColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr('Customize the visual appearance of DormMate', 'ปรับแต่งรูปแบบการแสดงผลของแอป DormMate'),
                    style: TextStyle(fontSize: 12, color: DormMateColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  _buildThemeOption(
                    title: context.tr('Light Glassmorphic', 'โหมดสว่าง Glassmorphic'),
                    subtitle: 'โหมดสว่าง (Light Mode) · ขาวสะอาดตา สไตล์ Frosted Glass',
                    ctx: ctx,
                    setSheetState: setSheetState,
                    preset: DormMateThemePreset.light,
                    swatchColors: const [Color(0xFF5856D6), Color(0xFF38BDF8), Color(0xFFF1F5F9)],
                  ),
                  _buildThemeOption(
                    title: context.tr('Dark Mode', 'โหมดมืด (Dark Mode)'),
                    subtitle: 'โหมดมืด (Dark Mode) · ดำสนิท OLED ถนอมสายตายามค่ำคืน',
                    ctx: ctx,
                    setSheetState: setSheetState,
                    preset: DormMateThemePreset.dark,
                    swatchColors: const [Color(0xFF818CF8), Color(0xFF06B6D4), Color(0xFF0B0F19)],
                  ),
                  _buildThemeOption(
                    title: context.tr('System Follow', 'ตามระบบของเครื่อง'),
                    subtitle: 'ตามระบบเครื่อง (System) · สลับสว่าง/มืดตามการตั้งค่าของอุปกรณ์',
                    ctx: ctx,
                    setSheetState: setSheetState,
                    preset: DormMateThemePreset.system,
                    swatchColors: const [Color(0xFF64748B), Color(0xFF94A3B8), Color(0xFFE2E8F0)],
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required String title,
    required String subtitle,
    required BuildContext ctx,
    required StateSetter setSheetState,
    required DormMateThemePreset preset,
    required List<Color> swatchColors,
  }) {
    DormMateThemeService? themeService;
    try {
      themeService = context.read<DormMateThemeService>();
    } catch (_) {}

    final isSelected = themeService != null
        ? themeService.preset == preset
        : _selectedTheme == title;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() => _selectedTheme = title);
        if (themeService != null) {
          themeService.setPreset(preset);
        }
        setSheetState(() {});
        Navigator.pop(ctx);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Theme set to: $title', 'เปลี่ยนธีมเป็น: $title'))),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: swatchColors.last,
                border: Border.all(
                  color: isSelected ? swatchColors.first : DormMateColors.divider,
                  width: isSelected ? 2.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: swatchColors.first.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: swatchColors.first,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: swatchColors[1],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? swatchColors.first : DormMateColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: DormMateColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? swatchColors.first : DormMateColors.textDisabled,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: DormMateColors.textSecondary)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DormMateColors.textPrimary)),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DormMateDimens.radiusLg),
        ),
        title: Text(context.tr('Sign Out', 'ออกจากระบบ')),
        content: Text(context.tr('Are you sure you want to sign out of DormMate?', 'คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ DormMate?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.tr('Cancel', 'ยกเลิก')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              context.tr('Sign Out', 'ออกจากระบบ'),
              style: TextStyle(color: DormMateColors.statusErrorText),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthViewModel>().logout();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final authVm = context.watch<AuthViewModel>();
    final user = vm.user;

    final displayName = user?.displayName ?? authVm.currentUserName ?? 'Resident';
    final email = user?.email ?? authVm.currentUserEmail ?? 'resident@dormmate.ac.th';
    final roomDisplay = user?.room?.displayLabel ?? 'B-204';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langService = context.watch<LanguageService?>();
    final isThai = langService?.isThai ?? false;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isThai ? 'โปรไฟล์' : 'Profile',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: DormMateColors.textPrimary,
            letterSpacing: -0.8,
          ),
        ),
        actions: [
          LanguageToggleButton(isDark: isDark),
          const SizedBox(width: 16),
        ],
      ),
      body: AnimatedOrbBackground(
        isDark: isDark,
        orbColors: const [Color(0xFF667EEA), Color(0xFF764BA2), Color(0xFF43CFCF)],
        child: vm.isLoading && user == null
          ? const LoadingView(message: 'Loading profile...')
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Profile hero ──────────────────────────────────────────
                  FadeSlideEntry(
                    delay: const Duration(milliseconds: 50),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A1F35), Color(0xFF0F1525), Color(0xFF1E1040)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(DormMateDimens.radiusXl),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667EEA).withValues(alpha: 0.22),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                            spreadRadius: -4,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.45),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                            spreadRadius: -4,
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          // ambient glow
                          Positioned(
                            top: -30,
                            right: -30,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(colors: [
                                  const Color(0xFF764BA2).withValues(alpha: 0.30),
                                  Colors.transparent,
                                ]),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(22),
                            child: Row(
                              children: [
                                // Avatar with gradient ring
                                NeuContainer(
                                  isDark: true,
                                  borderRadius: 50,
                                  shadowIntensity: 1.5,
                                  padding: const EdgeInsets.all(4),
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: NeuColors.primaryGradient,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: vm.isLoading ?
                                      const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) :
                                      CircleAvatar(
                                        radius: 36,
                                        backgroundColor: const Color(0xFF1A1F35),
                                        child: Text(
                                          displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        email,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withValues(alpha: 0.55),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          _buildMiniStat('Room', roomDisplay),
                                          const SizedBox(width: 8),
                                          _buildMiniStat('Floor', user?.room?.floor.toString() ?? '2'),
                                          const SizedBox(width: 8),
                                          _buildMiniStat('Bldg', user?.room?.building ?? 'B'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Room info section
                  FadeSlideEntry(
                    delay: const Duration(milliseconds: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 3,
                              height: 16,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(1.5),
                                gradient: const LinearGradient(
                                  colors: NeuColors.primaryGradient,
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(context.tr('ROOM INFORMATION', 'ข้อมูลห้องพัก'), style: DormMateTextStyles.label),
                          ],
                        ),
                        const SizedBox(height: 8),
                        NeuContainer(
                          isDark: isDark,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          borderRadius: 20,
                          shadowIntensity: 0.85,
                          child: Column(
                            children: [
                              _buildSettingRow(
                                icon: Icons.apartment_rounded,
                                title: context.tr('Building', 'อาคาร'),
                                subtitle: user?.room?.building != null ? '${context.tr('Building', 'อาคาร')} ${user?.room?.building}' : context.tr('Building B', 'อาคาร B'),
                                onTap: () => _showRoomDetailsSheet(roomDisplay),
                                isDark: isDark,
                              ),
                              GradientDivider(isDark: isDark),
                              _buildSettingRow(
                                icon: Icons.meeting_room_outlined,
                                title: context.tr('Room Number', 'เลขห้องพัก'),
                                subtitle: user?.room?.roomNumber != null ? '${user?.room?.roomNumber} · ${context.tr('Floor', 'ชั้น')} ${user?.room?.floor}' : 'B-204 · 2nd Floor',
                                onTap: () => _showRoomDetailsSheet(roomDisplay),
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Account settings section
                  FadeSlideEntry(
                    delay: const Duration(milliseconds: 180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr('ACCOUNT & PREFERENCES', 'บัญชีและการตั้งค่า'), style: DormMateTextStyles.label),
                        const SizedBox(height: 8),
                        NeuContainer(
                          isDark: isDark,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          borderRadius: 20,
                          shadowIntensity: 0.85,
                          child: Column(
                            children: [
                              _buildSettingRow(
                                icon: Icons.person_outline_rounded,
                                title: context.tr('Personal Info', 'ข้อมูลส่วนตัว'),
                                subtitle: context.tr('View resident & lease details', 'ดูรายละเอียดผู้พักและสัญญาเช่า'),
                                onTap: () => _showPersonalInfoSheet(displayName, email, roomDisplay),
                                isDark: isDark,
                              ),
                              GradientDivider(isDark: isDark),
                              _buildSettingRow(
                                icon: Icons.notifications_none_rounded,
                                title: context.tr('Notifications', 'การแจ้งเตือน'),
                                subtitle: context.tr('Bill due, repair & notice alerts', 'แจ้งเตือนบิล, งานซ่อม และประกาศ'),
                                onTap: _showNotificationsSheet,
                                isDark: isDark,
                              ),
                              GradientDivider(isDark: isDark),
                              _buildSettingRow(
                                icon: Icons.palette_outlined,
                                title: context.tr('Appearance', 'รูปแบบหน้าตาแอป'),
                                subtitle: () {
                                  try {
                                    final s = context.watch<DormMateThemeService>();
                                    return '${s.preset.title} (${s.preset.thaiTitle})';
                                  } catch (_) {
                                    return _selectedTheme;
                                  }
                                }(),
                                onTap: _showAppearanceSheet,
                                isDark: isDark,
                              ),
                              GradientDivider(isDark: isDark),
                              Builder(
                                builder: (context) {
                                  DormMateThemeService? themeService;
                                  try {
                                    themeService = context.watch<DormMateThemeService>();
                                  } catch (_) {}
                                  return _buildSwitchRow(
                                    icon: Icons.dark_mode_outlined,
                                    title: context.tr('Dark Mode (โหมดมืด)', 'โหมดมืด (Dark Mode)'),
                                    subtitle: context.tr('OLED Black night mode', 'ถนอมสายตายามค่ำคืน'),
                                    value: themeService?.isDarkMode ?? false,
                                    isDark: isDark,
                                    onChanged: (val) {
                                      if (themeService != null) {
                                        themeService.toggleDarkMode(val);
                                      }
                                    },
                                  );
                                },
                              ),
                              GradientDivider(isDark: isDark),
                              _buildSettingRow(
                                icon: Icons.translate_rounded,
                                title: isThai ? 'ภาษา (Language)' : 'Language',
                                subtitle: isThai ? 'ภาษาไทย · Thai' : 'English · ภาษาอังกฤษ',
                                trailing: LanguageToggleButton(isDark: isDark),
                                onTap: () => showLanguageSelectionSheet(context),
                                isDark: isDark,
                              ),
                              GradientDivider(isDark: isDark),
                              _buildSettingRow(
                                icon: Icons.menu_book_rounded,
                                title: context.tr('Resident Handbook & Guides', 'คู่มือและระเบียบหอพัก'),
                                subtitle: context.tr('Dormitory handbook & procedures', 'คู่มือและขั้นตอนการใช้งานหอพัก'),
                                onTap: () => context.push('/resident-guide'),
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Logout button ─────────────────────────────────────────
                  FadeSlideEntry(
                    delay: const Duration(milliseconds: 240),
                    child: SizedBox(
                      width: double.infinity,
                      child: NeuButton(
                        isDark: isDark,
                        gradientColors: const [Color(0xFFEF4444), Color(0xFFDC2626)],
                        borderRadius: 16,
                        onTap: _handleLogout,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              context.tr('Sign Out', 'ออกจากระบบ'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'DormMate v1.0 · MVVM Architecture',
                      style: TextStyle(fontSize: 11, color: DormMateColors.textTertiary),
                    ),
                  ),
                  const SizedBox(height: 96),
                ],
              ),
            ),
        ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2035).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF667EEA).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.white54)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            NeuIconBox(
              icon: icon,
              iconColor: DormMateColors.primary,
              isDark: isDark,
              size: 36,
              iconSize: 18,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: DormMateColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: DormMateColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: DormMateColors.textDisabled,
                  size: 18,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        children: [
          NeuIconBox(
            icon: icon,
            iconColor: DormMateColors.primary,
            isDark: isDark,
            size: 36,
            iconSize: 18,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: DormMateColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: DormMateColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: DormMateColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
