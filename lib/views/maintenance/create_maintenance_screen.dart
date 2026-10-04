import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/dormmate_constants.dart';
import '../../core/localization/language_service.dart';
import '../../models/maintenance_request.dart';
import '../../viewmodels/maintenance_viewmodel.dart';
import '../../models/feature_guide.dart';
import '../../widgets/feature_guide_sheet.dart';
import '../../widgets/neumorphic.dart';
import '../../widgets/language_toggle_button.dart';

class CreateMaintenanceScreen extends StatefulWidget {
  const CreateMaintenanceScreen({super.key});

  @override
  State<CreateMaintenanceScreen> createState() => _CreateMaintenanceScreenState();
}

class _CreateMaintenanceScreenState extends State<CreateMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = MaintenanceCategories.list[2]; // Air Conditioner default
  String _selectedUrgency = MaintenanceUrgencies.normal;
  String _selectedTimeSlot = MaintenanceTimeSlots.anytime;
  bool _hasAttachedPhoto = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

  String _getTimeSlotName(String slot, BuildContext context) {
    if (!context.isThai) return slot;
    switch (slot) {
      case 'Anytime': return 'ตลอดเวลาที่สะดวก';
      case 'Morning (9:00 - 12:00)': return 'ช่วงเช้า (09:00 - 12:00)';
      case 'Afternoon (13:00 - 17:00)': return 'ช่วงบ่าย (13:00 - 17:00)';
      case 'Evening (17:00 - 20:00)': return 'ช่วงเย็น (17:00 - 20:00)';
      default: return slot;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<MaintenanceViewModel>();
    final success = await vm.createRequest(
      title: _titleController.text.trim(),
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
      urgency: _selectedUrgency,
      preferredTimeSlot: _selectedTimeSlot,
      imageUrl: _hasAttachedPhoto ? 'https://images.unsplash.com/photo-1581092160607-ee22621dd758' : null,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Maintenance request submitted successfully!',
              'ส่งคำขอแจ้งซ่อมสำเร็จแล้ว!',
            ),
          ),
          backgroundColor: DormMateColors.statusCompleted,
        ),
      );
      _handleBack();
    }
  }

  Widget _buildUrgencyOption(String urgency, String label, Color activeColor, IconData icon, bool isDark) {
    final isSelected = _selectedUrgency == urgency;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedUrgency = urgency),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.16)
                : (isDark ? NeuColors.cardDark : NeuColors.cardLight),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? activeColor : (isDark ? NeuColors.borderDark : NeuColors.borderLight),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? activeColor : DormMateColors.textSecondary,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? activeColor : DormMateColors.textSecondary,
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
    final vm = context.watch<MaintenanceViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          context.tr('New Request', 'แจ้งซ่อมใหม่'),
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
            tooltip: context.tr('Maintenance Guide', 'ขั้นตอนการแจ้งซ่อม'),
            onPressed: () => showFeatureGuideSheet(context, FeatureGuide.maintenanceGuide),
          ),
          LanguageToggleButton(isDark: isDark),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedOrbBackground(
        isDark: isDark,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NeuContainer(
                  isDark: isDark,
                  padding: const EdgeInsets.all(20),
                  borderRadius: 22,
                  shadowIntensity: 0.8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('PROBLEM TITLE', 'หัวข้อปัญหา'), style: DormMateTextStyles.label),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        style: TextStyle(color: DormMateColors.textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: context.tr('e.g. Air conditioner not cooling', 'เช่น แอร์ไม่เย็น, ก๊อกน้ำรั่ว'),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF131726) : const Color(0xFFEFF2F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark ? NeuColors.borderDark : NeuColors.borderLight,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark ? NeuColors.borderDark : NeuColors.borderLight,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFF667EEA), width: 1.6),
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? context.tr('Please enter a problem title', 'กรุณาระบุหัวข้อปัญหา') : null,
                      ),
                      const SizedBox(height: 18),

                      Text(context.tr('CATEGORY', 'หมวดหมู่'), style: DormMateTextStyles.label),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        dropdownColor: isDark ? const Color(0xFF1F263C) : Colors.white,
                        style: TextStyle(color: DormMateColors.textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark ? const Color(0xFF131726) : const Color(0xFFEFF2F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark ? NeuColors.borderDark : NeuColors.borderLight,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark ? NeuColors.borderDark : NeuColors.borderLight,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFF667EEA), width: 1.6),
                          ),
                        ),
                        items: MaintenanceCategories.list.map((cat) {
                          return DropdownMenuItem(value: cat, child: Text(_getCategoryName(cat, context)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        },
                      ),
                      const SizedBox(height: 18),

                      Text(context.tr('URGENCY LEVEL', 'ระดับความเร่งด่วน'), style: DormMateTextStyles.label),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildUrgencyOption(
                            MaintenanceUrgencies.normal,
                            context.tr('Normal', 'ปกติ'),
                            DormMateColors.primary,
                            Icons.check_circle_outline_rounded,
                            isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildUrgencyOption(
                            MaintenanceUrgencies.high,
                            context.tr('High', 'ด่วน'),
                            const Color(0xFFFF9500),
                            Icons.priority_high_rounded,
                            isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildUrgencyOption(
                            MaintenanceUrgencies.emergency,
                            context.tr('Emergency', 'ฉุกเฉิน'),
                            DormMateColors.statusErrorText,
                            Icons.warning_amber_rounded,
                            isDark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      Text(context.tr('PREFERRED TIME SLOT', 'ช่วงเวลาที่สะดวก'), style: DormMateTextStyles.label),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedTimeSlot,
                        dropdownColor: isDark ? const Color(0xFF1F263C) : Colors.white,
                        style: TextStyle(color: DormMateColors.textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.schedule_rounded, size: 20, color: DormMateColors.textSecondary),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF131726) : const Color(0xFFEFF2F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark ? NeuColors.borderDark : NeuColors.borderLight,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark ? NeuColors.borderDark : NeuColors.borderLight,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFF667EEA), width: 1.6),
                          ),
                        ),
                        items: MaintenanceTimeSlots.list.map((slot) {
                          return DropdownMenuItem(value: slot, child: Text(_getTimeSlotName(slot, context)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedTimeSlot = val);
                        },
                      ),
                      const SizedBox(height: 18),

                      Text(context.tr('DESCRIPTION', 'รายละเอียดปัญหา'), style: DormMateTextStyles.label),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        style: TextStyle(color: DormMateColors.textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: context.tr('Describe what happened and when it started...', 'อธิบายอาการหรือปัญหาที่พบ และเกิดขึ้นเมื่อใด...'),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF131726) : const Color(0xFFEFF2F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark ? NeuColors.borderDark : NeuColors.borderLight,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark ? NeuColors.borderDark : NeuColors.borderLight,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFF667EEA), width: 1.6),
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? context.tr('Please describe the issue', 'กรุณาระบุรายละเอียดปัญหา') : null,
                      ),
                      const SizedBox(height: 18),

                      Text(context.tr('PHOTO EVIDENCE (OPTIONAL)', 'แนบภาพประกอบ (ถ้ามี)'), style: DormMateTextStyles.label),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          if (_hasAttachedPhoto) {
                            setState(() => _hasAttachedPhoto = false);
                          } else {
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
                                        context.tr('Attach Photo Evidence', 'แนบภาพถ่ายประกอบ'),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: DormMateColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        context.tr(
                                          'Adding clear photos helps technicians prepare the right tools.',
                                          'การแนบภาพที่ชัดเจนช่วยให้ช่างเตรียมอุปกรณ์ได้ตรงจุด',
                                        ),
                                        style: TextStyle(fontSize: 12, color: DormMateColors.textSecondary),
                                      ),
                                      const SizedBox(height: 16),
                                      ListTile(
                                        leading: const Icon(Icons.photo_camera_rounded),
                                        title: Text(context.tr('Take a photo with Camera', 'ถ่ายภาพด้วยกล้อง')),
                                        onTap: () {
                                          Navigator.pop(ctx);
                                          setState(() => _hasAttachedPhoto = true);
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.photo_library_rounded),
                                        title: Text(context.tr('Choose from Gallery', 'เลือกจากคลังภาพ')),
                                        onTap: () {
                                          Navigator.pop(ctx);
                                          setState(() => _hasAttachedPhoto = true);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                          decoration: BoxDecoration(
                            color: _hasAttachedPhoto
                                ? const Color(0xFF667EEA).withValues(alpha: 0.1)
                                : (isDark ? const Color(0xFF131726) : const Color(0xFFEFF2F8)),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _hasAttachedPhoto
                                  ? const Color(0xFF667EEA)
                                  : (isDark ? NeuColors.borderDark : NeuColors.borderLight),
                              width: _hasAttachedPhoto ? 1.8 : 1.2,
                            ),
                          ),
                          child: _hasAttachedPhoto
                              ? Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF667EEA).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.image_rounded,
                                        color: Color(0xFF667EEA),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'issue_evidence.jpg',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: DormMateColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            context.tr('1.8 MB · Tap to remove or replace', '1.8 MB · แตะเพื่อลบหรือเปลี่ยนภาพ'),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: DormMateColors.primary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline_rounded, size: 20, color: DormMateColors.statusErrorText),
                                      onPressed: () => setState(() => _hasAttachedPhoto = false),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Icon(
                                      Icons.add_a_photo_outlined,
                                      size: 28,
                                      color: DormMateColors.primary,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      context.tr('Attach Photo Evidence', 'แนบภาพประกอบ'),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: DormMateColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      context.tr('Take a photo or choose from gallery', 'ถ่ายรูปหรือเลือกรูปจากอัลบั้ม'),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: DormMateColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (vm.errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    vm.errorMessage!,
                    style: TextStyle(color: DormMateColors.statusErrorText, fontSize: 13),
                  ),
                ],

                const SizedBox(height: 20),

                NeuButton(
                  isDark: isDark,
                  gradientColors: const [Color(0xFF667EEA), Color(0xFF764BA2)],
                  borderRadius: 16,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  onTap: vm.isSubmitting ? () {} : _submit,
                  child: vm.isSubmitting
                      ? const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            context.tr('Submit Request', 'ส่งคำขอแจ้งซ่อม'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _handleBack,
                    child: Text(
                      context.tr('Cancel', 'ยกเลิก'),
                      style: TextStyle(
                        color: DormMateColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 96),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
