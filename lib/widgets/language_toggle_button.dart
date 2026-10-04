import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/dormmate_constants.dart';
import '../core/localization/language_service.dart';
import 'neumorphic.dart';

/// Interactive segmented Language Toggle button (TH | EN).
/// Provides smooth neumorphic styling and real-time language switching.
class LanguageToggleButton extends StatelessWidget {
  final bool isDark;
  final bool showLabel;

  const LanguageToggleButton({
    super.key,
    required this.isDark,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final langService = context.watch<LanguageService?>();
    final isThai = langService?.isThai ?? false;

    return NeuContainer(
      isDark: isDark,
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      shadowIntensity: 0.7,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageSegment(
            label: 'TH',
            flag: '🇹🇭',
            isActive: isThai,
            isDark: isDark,
            onTap: () {
              if (!isThai && langService != null) {
                langService.setLanguage('th');
                _showFeedback(context, 'เปลี่ยนภาษาเป็น: ภาษาไทย 🇹🇭');
              }
            },
          ),
          const SizedBox(width: 2),
          _LanguageSegment(
            label: 'EN',
            flag: '🇺🇸',
            isActive: !isThai,
            isDark: isDark,
            onTap: () {
              if (isThai && langService != null) {
                langService.setLanguage('en');
                _showFeedback(context, 'Language changed to: English 🇺🇸');
              }
            },
          ),
        ],
      ),
    );
  }

  void _showFeedback(BuildContext context, String message) {
    if (!context.mounted) return;
    try {
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger != null) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.translate_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1600),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (_) {}
  }
}

class _LanguageSegment extends StatelessWidget {
  final String label;
  final String flag;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _LanguageSegment({
    required this.label,
    required this.flag,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isActive
              ? const LinearGradient(
                  colors: NeuColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive
                    ? Colors.white
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : DormMateColors.textSecondary),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Displays a modal sheet to pick the language preference.
void showLanguageSelectionSheet(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final langService = context.read<LanguageService?>();
  final currentLang = langService?.languageCode ?? 'en';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
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
              'Select Language / เลือกภาษา',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: DormMateColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose your preferred display language across DormMate',
              style: TextStyle(fontSize: 12, color: DormMateColors.textSecondary),
            ),
            const SizedBox(height: 16),
            _buildOption(
              context: ctx,
              flag: '🇹🇭',
              title: 'ภาษาไทย (Thai)',
              subtitle: 'แสดงเมนูและข้อมูลเป็นภาษาไทย',
              isSelected: currentLang == 'th',
              isDark: isDark,
              onTap: () {
                langService?.setLanguage('th');
                Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                    const SnackBar(content: Text('เปลี่ยนภาษาเป็น: ภาษาไทย 🇹🇭')),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            _buildOption(
              context: ctx,
              flag: '🇺🇸',
              title: 'English (อังกฤษ)',
              subtitle: 'Show menus and information in English',
              isSelected: currentLang == 'en',
              isDark: isDark,
              onTap: () {
                langService?.setLanguage('en');
                Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                    const SnackBar(content: Text('Language changed to: English 🇺🇸')),
                  );
                }
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ),
  );
}

Widget _buildOption({
  required BuildContext context,
  required String flag,
  required String title,
  required String subtitle,
  required bool isSelected,
  required bool isDark,
  required VoidCallback onTap,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFF667EEA) : DormMateColors.divider,
          width: isSelected ? 2 : 1,
        ),
        color: isSelected
            ? const Color(0xFF667EEA).withValues(alpha: isDark ? 0.15 : 0.08)
            : Colors.transparent,
      ),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: DormMateColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: DormMateColors.textSecondary),
                ),
              ],
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_circle_rounded, color: Color(0xFF667EEA), size: 22),
        ],
      ),
    ),
  );
}
