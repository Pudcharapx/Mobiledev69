import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/dormmate_constants.dart';
import '../../core/theme/dormmate_theme_presets.dart';
import '../../core/theme/dormmate_theme_service.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/app_animations.dart';

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
                _buildInfoRow('Student / Resident ID', 'STD-6510204'),
                _buildInfoRow('Room Number', 'Room $roomDisplay (Building B)'),
                _buildInfoRow('Contact Phone', '081-234-5678'),
                _buildInfoRow('Emergency Contact', '089-876-5432 (Parent)'),
                _buildInfoRow('Lease Term', 'Aug 2026 - May 2027 (Active)'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
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
                  'Room Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: DormMateColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text('Room $roomDisplay · Building B · Floor 2', style: TextStyle(fontSize: 13, color: DormMateColors.textSecondary)),
                const SizedBox(height: 18),
                _buildInfoRow('Room Type', 'Twin Room (2 Residents)'),
                _buildInfoRow('Bed Assignment', 'Bed 01 (Left Side)'),
                _buildInfoRow('Wi-Fi Network', 'DormMate_B204'),
                _buildInfoRow('Wi-Fi Password', 'dormmate2026'),
                _buildInfoRow('Keycard Number', 'KC-990234-B'),
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
                        const SnackBar(content: Text('Wi-Fi password copied to clipboard!')),
                      );
                    },
                    icon: const Icon(Icons.wifi_rounded, size: 18),
                    label: const Text('Copy Wi-Fi Password'),
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
                    'Notification Preferences',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: DormMateColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text('Choose which dormitory alerts you wish to receive', style: TextStyle(fontSize: 12, color: DormMateColors.textSecondary)),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Bill Due Date Reminders', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DormMateColors.textPrimary)),
                    subtitle: Text('Alert when monthly bills are published or overdue', style: TextStyle(fontSize: 11, color: DormMateColors.textSecondary)),
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
                    title: Text('Maintenance Status Updates', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DormMateColors.textPrimary)),
                    subtitle: Text('Notify when technician is assigned or job completed', style: TextStyle(fontSize: 11, color: DormMateColors.textSecondary)),
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
                    title: Text('Urgent Announcements', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DormMateColors.textPrimary)),
                    subtitle: Text('Water/power shut-off, inspections, fire safety', style: TextStyle(fontSize: 11, color: DormMateColors.textSecondary)),
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
                    title: Text('In-App Haptics & Sound', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DormMateColors.textPrimary)),
                    subtitle: Text('Vibration feedback on tap and submit', style: TextStyle(fontSize: 11, color: DormMateColors.textSecondary)),
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
                          const SnackBar(content: Text('Notification preferences saved')),
                        );
                      },
                      child: const Text('Done'),
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
                        'Appearance & Theme',
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
                  Text('Customize the visual appearance of DormMate', style: TextStyle(fontSize: 12, color: DormMateColors.textSecondary)),
                  const SizedBox(height: 16),
                  _buildThemeOption(
                    title: 'Light Glassmorphic',
                    subtitle: 'โหมดสว่าง (Light Mode) · ขาวสะอาดตา สไตล์ Frosted Glass',
                    ctx: ctx,
                    setSheetState: setSheetState,
                    preset: DormMateThemePreset.light,
                    swatchColors: const [Color(0xFF5856D6), Color(0xFF38BDF8), Color(0xFFF1F5F9)],
                  ),
                  _buildThemeOption(
                    title: 'Dark Mode',
                    subtitle: 'โหมดมืด (Dark Mode) · ดำสนิท OLED ถนอมสายตายามค่ำคืน',
                    ctx: ctx,
                    setSheetState: setSheetState,
                    preset: DormMateThemePreset.dark,
                    swatchColors: const [Color(0xFF818CF8), Color(0xFF06B6D4), Color(0xFF0B0F19)],
                  ),
                  _buildThemeOption(
                    title: 'System Follow',
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
          SnackBar(content: Text('Theme set to: $title')),
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
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of DormMate?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Sign Out',
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: DormMateTextStyles.title),
      ),
      body: vm.isLoading && user == null
          ? const LoadingView(message: 'Loading profile...')
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile hero
                  FadeSlideEntry(
                    delay: const Duration(milliseconds: 50),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1C1C1E), Color(0xFF2D2D35)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(DormMateDimens.radiusXl),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: DormMateColors.primary,
                            child: Text(
                              displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  email,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0x335856D6),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0x665856D6),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'Room $roomDisplay',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFA29BFE),
                                    ),
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
                        Text('ROOM INFORMATION', style: DormMateTextStyles.label),
                        const SizedBox(height: 8),
                        GlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Column(
                            children: [
                              _buildSettingRow(
                                icon: Icons.apartment_rounded,
                                title: 'Building',
                                subtitle: user?.room?.building != null ? 'Building ${user?.room?.building}' : 'Building B',
                                onTap: () => _showRoomDetailsSheet(roomDisplay),
                              ),
                              Divider(height: 1, color: DormMateColors.divider),
                              _buildSettingRow(
                                icon: Icons.meeting_room_outlined,
                                title: 'Room Number',
                                subtitle: user?.room?.roomNumber != null ? '${user?.room?.roomNumber} · Floor ${user?.room?.floor}' : 'B-204 · 2nd Floor',
                                onTap: () => _showRoomDetailsSheet(roomDisplay),
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
                        Text('ACCOUNT & PREFERENCES', style: DormMateTextStyles.label),
                        const SizedBox(height: 8),
                        GlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Column(
                            children: [
                              _buildSettingRow(
                                icon: Icons.person_outline_rounded,
                                title: 'Personal Info',
                                subtitle: 'View resident & lease details',
                                onTap: () => _showPersonalInfoSheet(displayName, email, roomDisplay),
                              ),
                              Divider(height: 1, color: DormMateColors.divider),
                              _buildSettingRow(
                                icon: Icons.notifications_none_rounded,
                                title: 'Notifications',
                                subtitle: 'Bill due, repair & notice alerts',
                                onTap: _showNotificationsSheet,
                              ),
                              Divider(height: 1, color: DormMateColors.divider),
                              _buildSettingRow(
                                icon: Icons.palette_outlined,
                                title: 'Appearance',
                                subtitle: () {
                                  try {
                                    final s = context.watch<DormMateThemeService>();
                                    return '${s.preset.title} (${s.preset.thaiTitle})';
                                  } catch (_) {
                                    return _selectedTheme;
                                  }
                                }(),
                                onTap: _showAppearanceSheet,
                              ),
                              Divider(height: 1, color: DormMateColors.divider),
                              Builder(
                                builder: (context) {
                                  DormMateThemeService? themeService;
                                  try {
                                    themeService = context.watch<DormMateThemeService>();
                                  } catch (_) {}
                                  return _buildSwitchRow(
                                    icon: Icons.dark_mode_outlined,
                                    title: 'Dark Mode (โหมดมืด)',
                                    subtitle: 'OLED Black ถนอมสายตายามค่ำคืน',
                                    value: themeService?.isDarkMode ?? false,
                                    onChanged: (val) {
                                      if (themeService != null) {
                                        themeService.toggleDarkMode(val);
                                      }
                                    },
                                  );
                                },
                              ),
                              Divider(height: 1, color: DormMateColors.divider),
                              _buildSettingRow(
                                icon: Icons.menu_book_rounded,
                                title: 'Resident Handbook & Guides',
                                subtitle: 'คู่มือและขั้นตอนการใช้งานหอพัก',
                                onTap: () => context.push('/resident-guide'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Logout button
                  FadeSlideEntry(
                    delay: const Duration(milliseconds: 240),
                    child: PressableScale(
                      onTap: _handleLogout,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: DormMateColors.statusErrorBg,
                          borderRadius: BorderRadius.circular(DormMateDimens.radiusMd),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout_rounded, color: DormMateColors.statusErrorText, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Sign Out',
                              style: TextStyle(
                                color: DormMateColors.statusErrorText,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
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
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: DormMateColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: DormMateColors.primary),
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
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: DormMateColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: DormMateColors.primary),
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
