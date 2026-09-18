import 'package:flutter/material.dart';
import '../../core/constants/dormmate_constants.dart';
import '../../models/utility_usage.dart';
import '../../widgets/utility_analytics_card.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/app_animations.dart';
import '../../models/feature_guide.dart';
import '../../widgets/feature_guide_sheet.dart';

class UtilityAnalyticsScreen extends StatelessWidget {
  const UtilityAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final analytics = UtilityAnalyticsData.mockDefault();

    return Scaffold(
      appBar: AppBar(
        title: Text('Usage Analytics', style: DormMateTextStyles.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'คำแนะนำการวิเคราะห์พลังงาน',
            onPressed: () => showFeatureGuideSheet(context, FeatureGuide.paymentGuide),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Interactive 6-Month Bar Chart Card
            FadeSlideEntry(
              delay: const Duration(milliseconds: 40),
              child: UtilityAnalyticsCard(data: analytics),
            ),
            const SizedBox(height: 14),

            // Tariffs and Rates Card
            FadeSlideEntry(
              delay: const Duration(milliseconds: 90),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.receipt_outlined, size: 18, color: DormMateColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Dormitory Utility Tariffs (อัตราค่าบริการ)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: DormMateColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFFFF9500)),
                            const SizedBox(width: 6),
                            Text('Electricity / ค่าไฟฟ้า', style: TextStyle(fontSize: 13, color: DormMateColors.textSecondary)),
                          ],
                        ),
                        Text('฿7.00 / kWh (Unit)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.orange.shade800)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Divider(height: 1, color: DormMateColors.divider),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.water_drop_rounded, size: 16, color: Color(0xFF007AFF)),
                            const SizedBox(width: 6),
                            Text('Water / ค่าน้ำประปา', style: TextStyle(fontSize: 13, color: DormMateColors.textSecondary)),
                          ],
                        ),
                        Text('฿18.00 / m³ (Unit)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.blue.shade700)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Energy Saving Tips
            FadeSlideEntry(
              delay: const Duration(milliseconds: 140),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.eco_rounded, size: 18, color: Color(0xFF10B981)),
                        const SizedBox(width: 8),
                        Text(
                          'Eco Tips for Dorm Life (เทคนิคประหยัดพลังงาน)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: DormMateColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildTipRow('เปิดแอร์ 25-26°C ควบคู่พัดลม', 'ช่วยกระจายลมเย็นและประหยัดค่าไฟได้ถึง 10-15%'),
                    _buildTipRow('ล้างแผ่นกรองแอร์ทุก 2-3 สัปดาห์', 'แอร์ไม่อุดตัน ระบายความเย็นไวขึ้น ไม่กินไฟ'),
                    _buildTipRow('ถอดปลั๊กเมื่อไม่ใช้งาน', 'ป้องกันกระแสไฟรั่วไหล (Phantom Load) ในอุปกรณ์อิเล็กทรอนิกส์'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTipRow(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 6,
            height: 6,
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
                const SizedBox(height: 1),
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
