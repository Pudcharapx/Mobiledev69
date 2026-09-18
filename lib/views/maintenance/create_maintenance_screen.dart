import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/dormmate_constants.dart';
import '../../models/maintenance_request.dart';
import '../../viewmodels/maintenance_viewmodel.dart';
import '../../widgets/glass_card.dart';
import '../../models/feature_guide.dart';
import '../../widgets/feature_guide_sheet.dart';

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
          content: const Text('Maintenance request submitted successfully!'),
          backgroundColor: DormMateColors.statusCompleted,
        ),
      );
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        try {
          context.pop();
        } catch (_) {}
      }
    }
  }

  Widget _buildUrgencyOption(String urgency, String label, Color activeColor, IconData icon) {
    final isSelected = _selectedUrgency == urgency;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedUrgency = urgency),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: 0.16) : DormMateColors.glassBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeColor : DormMateColors.divider,
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? activeColor : DormMateColors.textSecondary,
              ),
              const SizedBox(height: 4),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Request'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'ขั้นตอนการแจ้งซ่อม',
            onPressed: () => showFeatureGuideSheet(context, FeatureGuide.maintenanceGuide),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PROBLEM TITLE', style: DormMateTextStyles.label),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Air conditioner not cooling',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Please enter a problem title' : null,
                    ),
                    const SizedBox(height: 18),

                    Text('CATEGORY', style: DormMateTextStyles.label),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      dropdownColor: DormMateColors.surfaceWhite,
                      style: TextStyle(color: DormMateColors.textPrimary, fontSize: 14),
                      decoration: const InputDecoration(),
                      items: MaintenanceCategories.list.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),
                    const SizedBox(height: 18),

                    Text('URGENCY LEVEL', style: DormMateTextStyles.label),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildUrgencyOption(
                          MaintenanceUrgencies.normal,
                          'Normal',
                          DormMateColors.primary,
                          Icons.check_circle_outline_rounded,
                        ),
                        const SizedBox(width: 8),
                        _buildUrgencyOption(
                          MaintenanceUrgencies.high,
                          'High',
                          const Color(0xFFFF9500),
                          Icons.priority_high_rounded,
                        ),
                        const SizedBox(width: 8),
                        _buildUrgencyOption(
                          MaintenanceUrgencies.emergency,
                          'Emergency',
                          DormMateColors.statusErrorText,
                          Icons.warning_amber_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    Text('PREFERRED TIME SLOT', style: DormMateTextStyles.label),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedTimeSlot,
                      dropdownColor: DormMateColors.surfaceWhite,
                      style: TextStyle(color: DormMateColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.schedule_rounded, size: 20, color: DormMateColors.textSecondary),
                      ),
                      items: MaintenanceTimeSlots.list.map((slot) {
                        return DropdownMenuItem(value: slot, child: Text(slot));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedTimeSlot = val);
                      },
                    ),
                    const SizedBox(height: 18),

                    Text('DESCRIPTION', style: DormMateTextStyles.label),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Describe what happened and when it started...',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Please describe the issue' : null,
                    ),
                    const SizedBox(height: 18),

                    Text('PHOTO EVIDENCE (OPTIONAL)', style: DormMateTextStyles.label),
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
                                      'Attach Photo Evidence',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: DormMateColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Adding clear photos helps technicians prepare the right tools.',
                                      style: TextStyle(fontSize: 12, color: DormMateColors.textSecondary),
                                    ),
                                    const SizedBox(height: 16),
                                    ListTile(
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: DormMateColors.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(Icons.camera_alt_rounded, color: DormMateColors.primary),
                                      ),
                                      title: const Text('Take Photo', style: TextStyle(fontWeight: FontWeight.w600)),
                                      subtitle: const Text('Use camera to capture issue'),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        setState(() => _hasAttachedPhoto = true);
                                      },
                                    ),
                                    ListTile(
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.photo_library_rounded, color: Color(0xFF007AFF)),
                                      ),
                                      title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                                      subtitle: const Text('Select from photo album'),
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
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: _hasAttachedPhoto
                              ? DormMateColors.primary.withValues(alpha: 0.06)
                              : Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(DormMateDimens.radiusMd),
                          border: Border.all(
                            color: _hasAttachedPhoto
                                ? DormMateColors.primary
                                : const Color(0x1F000000),
                            style: BorderStyle.solid,
                            width: _hasAttachedPhoto ? 1.5 : 1,
                          ),
                        ),
                        child: _hasAttachedPhoto
                            ? Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: DormMateColors.primary.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.image_rounded,
                                      color: DormMateColors.primary,
                                      size: 26,
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
                                          '1.8 MB · Tap to remove or replace',
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
                                    'Attach Photo Evidence (แนบภาพประกอบ)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: DormMateColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Take a photo or choose from gallery',
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

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: vm.isSubmitting ? null : _submit,
                  child: vm.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Submit Request'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: DormMateColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(height: 96),
            ],
          ),
        ),
      ),
    );
  }
}
