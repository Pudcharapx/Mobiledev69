import 'package:flutter/material.dart';
import '../../core/constants/dormmate_constants.dart';
import '../../core/localization/language_service.dart';
import '../../models/utility_usage.dart';
import '../../widgets/utility_analytics_card.dart';
import '../../widgets/app_animations.dart';
import '../../models/feature_guide.dart';
import '../../widgets/feature_guide_sheet.dart';
import '../../widgets/neumorphic.dart';
import '../../widgets/language_toggle_button.dart';

class UtilityAnalyticsScreen extends StatelessWidget {
  const UtilityAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final analytics = UtilityAnalyticsData.mockDefault();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgDark : NeuColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          context.tr('Usage Analytics', 'สถิติการใช้พลังงาน'),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A2035),
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: context.tr('Energy Guide', 'คำแนะนำการวิเคราะห์พลังงาน'),
            onPressed: () => showFeatureGuideSheet(context, FeatureGuide.paymentGuide),
          ),
          LanguageToggleButton(isDark: isDark),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedOrbBackground(
        isDark: isDark,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Interactive 6-Month Bar Chart Card
              FadeSlideEntry(
                delay: const Duration(milliseconds: 40),
                child: UtilityAnalyticsCard(data: analytics),
              ),
              const SizedBox(height: 16),

              // Tariffs and Rates Card
              FadeSlideEntry(
                delay: const Duration(milliseconds: 90),
                child: NeuContainer(
                  isDark: isDark,
                  padding: const EdgeInsets.all(18),
                  borderRadius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.receipt_outlined, size: 20, color: Color(0xFF667EEA)),
                          const SizedBox(width: 8),
                          Text(
                            context.tr('Dormitory Utility Tariffs', 'อัตราค่าบริการพลังงานหอพัก'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: DormMateColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.bolt_rounded, size: 18, color: Color(0xFFFF9500)),
                              const SizedBox(width: 6),
                              Text(context.tr('Electricity', 'ค่าไฟฟ้า'), style: TextStyle(fontSize: 13, color: DormMateColors.textSecondary)),
                            ],
                          ),
                          Text(
                            context.tr('฿7.00 / kWh (Unit)', '7.00 บาท / หน่วย (kWh)'),
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.orange.shade800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Divider(height: 1, color: isDark ? const Color(0xFF28334E) : DormMateColors.divider),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.water_drop_rounded, size: 18, color: Color(0xFF007AFF)),
                              const SizedBox(width: 6),
                              Text(context.tr('Water', 'ค่าน้ำประปา'), style: TextStyle(fontSize: 13, color: DormMateColors.textSecondary)),
                            ],
                          ),
                          Text(
                            context.tr('฿18.00 / m³ (Unit)', '18.00 บาท / หน่วย (ลบ.ม.)'),
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.blue.shade700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Energy Saving Tips
              FadeSlideEntry(
                delay: const Duration(milliseconds: 140),
                child: NeuContainer(
                  isDark: isDark,
                  padding: const EdgeInsets.all(18),
                  borderRadius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.eco_rounded, size: 20, color: Color(0xFF10B981)),
                          const SizedBox(width: 8),
                          Text(
                            context.tr('Eco Tips for Dorm Life', 'เทคนิคประหยัดพลังงานในหอพัก'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: DormMateColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildTipRow(
                        context.tr('Set AC to 25-26°C with Fan', 'เปิดแอร์ 25-26°C ควบคู่พัดลม'),
                        context.tr('Helps circulate cool air and cuts electricity by 10-15%', 'ช่วยกระจายลมเย็นและประหยัดค่าไฟได้ถึง 10-15%'),
                      ),
                      _buildTipRow(
                        context.tr('Clean AC filter every 2-3 weeks', 'ล้างแผ่นกรองแอร์ทุก 2-3 สัปดาห์'),
                        context.tr('Prevents dust clog and speeds up cooling efficiency', 'แอร์ไม่อุดตัน ระบายความเย็นไวขึ้น ไม่กินไฟ'),
                      ),
                      _buildTipRow(
                        context.tr('Unplug appliances when not in use', 'ถอดปลั๊กเมื่อไม่ใช้งาน'),
                        context.tr('Eliminates standby phantom load power draw', 'ป้องกันกระแสไฟรั่วไหล (Phantom Load) ในอุปกรณ์อิเล็กทรอนิกส์'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 64),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipRow(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: DormMateColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: DormMateColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
