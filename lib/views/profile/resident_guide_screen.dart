import 'package:flutter/material.dart';
import '../../core/constants/dormmate_constants.dart';
import '../../models/feature_guide.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/feature_guide_sheet.dart';
import '../../widgets/app_animations.dart';

class ResidentGuideScreen extends StatefulWidget {
  const ResidentGuideScreen({super.key});

  @override
  State<ResidentGuideScreen> createState() => _ResidentGuideScreenState();
}

class _ResidentGuideScreenState extends State<ResidentGuideScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FeatureGuide> get _filteredGuides {
    final query = _searchController.text.trim().toLowerCase();
    return FeatureGuide.allGuides.where((guide) {
      final matchesCategory = _selectedCategory == 'All' || guide.id == _selectedCategory;
      if (!matchesCategory) return false;

      if (query.isEmpty) return true;
      return guide.title.toLowerCase().contains(query) ||
          guide.titleTh.toLowerCase().contains(query) ||
          guide.subtitle.toLowerCase().contains(query) ||
          guide.steps.any((s) =>
              s.title.toLowerCase().contains(query) ||
              s.description.toLowerCase().contains(query));
    }).toList();
  }

  Widget _buildCategoryChip(String label, String categoryId) {
    final isSelected = _selectedCategory == categoryId;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = categoryId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? DormMateColors.primary
              : DormMateColors.glassBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? DormMateColors.primary : DormMateColors.divider,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: DormMateColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : DormMateColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildGuideCard(FeatureGuide guide) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
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
      child: Material(
        color: Colors.transparent,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  guide.headerColor.withValues(alpha: 0.18),
                  guide.headerColor.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: guide.headerColor.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Icon(guide.headerIcon, color: guide.headerColor, size: 22),
          ),
          title: Text(
            guide.titleTh,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: DormMateColors.textPrimary,
            ),
          ),
          subtitle: Text(
            guide.subtitle,
            style: TextStyle(fontSize: 12, color: DormMateColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Divider(height: 1, color: DormMateColors.divider),
            const SizedBox(height: 14),
            ...guide.steps.asMap().entries.map((entry) {
              final idx = entry.key;
              final step = entry.value;
              final isLast = idx == guide.steps.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: step.color,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${step.stepNumber}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              margin: const EdgeInsets.symmetric(vertical: 3),
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(step.icon, size: 14, color: step.color),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    step.title,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: DormMateColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              step.description,
                              style: TextStyle(
                                fontSize: 11,
                                color: DormMateColors.textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (guide.tip != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: DormMateColors.isDark ? const Color(0x33F59E0B) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: DormMateColors.isDark ? const Color(0x66F59E0B) : const Color(0xFFFDE68A)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_rounded, size: 16, color: Color(0xFFD97706)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        guide.tip!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: DormMateColors.isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => showFeatureGuideSheet(context, guide),
                icon: Icon(Icons.open_in_new_rounded, size: 14, color: guide.headerColor),
                label: Text(
                  'เปิดดูแบบเต็ม (Full Screen)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: guide.headerColor),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }

  @override
  Widget build(BuildContext context) {
    final guides = _filteredGuides;

    return Scaffold(
      appBar: AppBar(
        title: Text('Resident Handbook', style: DormMateTextStyles.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            FadeSlideEntry(
              delay: const Duration(milliseconds: 40),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'คู่มือและขั้นตอนการใช้งานหอพัก',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Dormitory Resident Handbook & App Guide',
                            style: TextStyle(fontSize: 11, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Search Bar
            FadeSlideEntry(
              delay: const Duration(milliseconds: 70),
              child: Container(
                decoration: BoxDecoration(
                  color: DormMateColors.glassBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: DormMateColors.divider),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(fontSize: 13, color: DormMateColors.textPrimary),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'ค้นหาขั้นตอนการใช้งาน หรือระเบียบหอพัก...',
                    hintStyle: TextStyle(fontSize: 13, color: DormMateColors.textTertiary),
                    prefixIcon: Icon(Icons.search_rounded, size: 20, color: DormMateColors.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Category Chips
            FadeSlideEntry(
              delay: const Duration(milliseconds: 90),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip('ทั้งหมด', 'All'),
                    const SizedBox(width: 8),
                    _buildCategoryChip('พัสดุ 📦', 'parcel'),
                    const SizedBox(width: 8),
                    _buildCategoryChip('ซักผ้า 🧺', 'laundry'),
                    const SizedBox(width: 8),
                    _buildCategoryChip('จองห้อง 🏢', 'amenity'),
                    const SizedBox(width: 8),
                    _buildCategoryChip('แจ้งซ่อม 🛠️', 'maintenance'),
                    const SizedBox(width: 8),
                    _buildCategoryChip('ชำระเงิน 💳', 'payment'),
                    const SizedBox(width: 8),
                    _buildCategoryChip('ระเบียบหอพัก 📋', 'rules'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Guides List
            if (guides.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'ไม่พบขั้นตอนการใช้งานที่ตรงกับคำค้นหา',
                        style: TextStyle(fontSize: 14, color: DormMateColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...guides.map(_buildGuideCard),

            const SizedBox(height: 8),

            // Emergency Contacts Card
            FadeSlideEntry(
              delay: const Duration(milliseconds: 150),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.phone_in_talk_rounded, size: 18, color: DormMateColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Emergency & Contacts (ติดต่อเจ้าหน้าที่)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: DormMateColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildContactRow('เคาน์เตอร์นิติบุคคล (Office)', '02-123-4567 (08:30 - 20:30 น.)', Icons.apartment_rounded),
                    Divider(height: 12, color: DormMateColors.divider),
                    _buildContactRow('รปภ. ประจำหอพัก (Security 24/7)', '081-999-8888 (ตลอด 24 ชม.)', Icons.shield_rounded),
                    Divider(height: 12, color: DormMateColors.divider),
                    _buildContactRow('ช่างอาคารฉุกเฉิน (Technician)', '089-777-6666 (ท่อแตก, ไฟดับ)', Icons.handyman_rounded),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: DormMateColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: DormMateColors.textSecondary)),
              Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DormMateColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}
