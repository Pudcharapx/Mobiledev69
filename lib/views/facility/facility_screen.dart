import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/dormmate_constants.dart';
import '../../viewmodels/facility_viewmodel.dart';
import '../../models/facility.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/app_animations.dart';
import '../../models/feature_guide.dart';
import '../../widgets/feature_guide_sheet.dart';

class FacilityScreen extends StatefulWidget {
  const FacilityScreen({super.key});

  @override
  State<FacilityScreen> createState() => _FacilityScreenState();
}

class _FacilityScreenState extends State<FacilityScreen> {
  int _selectedTab = 0; // 0 = Laundry, 1 = Amenities

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FacilityViewModel>().loadAll();
    });
  }

  void _showBookingSheet(BuildContext context, Amenity amenity, FacilityViewModel vm) {
    String selectedSlot = amenity.availableSlots.first;
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.85,
              ),
              decoration: BoxDecoration(
                color: DormMateColors.surfaceWhite,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
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
                      const SizedBox(height: 14),

                      Text(
                        amenity.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: DormMateColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${amenity.floor} · Max ${amenity.capacity} Persons',
                        style: TextStyle(
                          fontSize: 12,
                          color: DormMateColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Date selector
                      Text(
                        'Select Date (เลือกวันที่)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: DormMateColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildDateChip(
                            'Today',
                            DateTime.now(),
                            selectedDate,
                            (d) => setSheetState(() => selectedDate = d),
                          ),
                          const SizedBox(width: 8),
                          _buildDateChip(
                            'Tomorrow',
                            DateTime.now().add(const Duration(days: 1)),
                            selectedDate,
                            (d) => setSheetState(() => selectedDate = d),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Time Slot Selector
                      Text(
                        'Available Time Slots (ช่วงเวลาที่เปิดให้จอง)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: DormMateColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: amenity.availableSlots.map((slot) {
                          final isSelected = selectedSlot == slot;
                          return ChoiceChip(
                            label: Text(slot),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) setSheetState(() => selectedSlot = slot);
                            },
                            selectedColor: DormMateColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : DormMateColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 12,
                            ),
                            backgroundColor: DormMateColors.isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DormMateColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () async {
                            final success = await vm.bookAmenity(
                              amenityId: amenity.id,
                              amenityName: amenity.name,
                              slot: selectedSlot,
                              date: selectedDate,
                              roomNumber: 'B-204',
                            );
                            if (context.mounted) {
                              Navigator.pop(ctx);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Booked ${amenity.name} ($selectedSlot) successfully!'),
                                    backgroundColor: const Color(0xFF10B981),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text(
                            'Confirm Booking / ยืนยันการจอง',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDateChip(
    String label,
    DateTime date,
    DateTime selectedDate,
    ValueChanged<DateTime> onSelect,
  ) {
    final isSelected = date.day == selectedDate.day && date.month == selectedDate.month;
    return GestureDetector(
      onTap: () => onSelect(date),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? DormMateColors.primary
              : (DormMateColors.isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : DormMateColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildLaundryCard(LaundryMachine machine, FacilityViewModel vm) {
    final isAvail = machine.isAvailable;
    final isInUse = machine.isInUse;
    final primaryColor = isAvail
        ? const Color(0xFF10B981)
        : (isInUse ? const Color(0xFF007AFF) : const Color(0xFF94A3B8));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: DormMateColors.glassBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: DormMateColors.glassBorder,
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withValues(alpha: 0.16),
                      primaryColor.withValues(alpha: 0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Icon(
                  machine.type == 'Dryer' ? Icons.air_rounded : Icons.local_laundry_service_rounded,
                  color: primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      machine.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: DormMateColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      machine.floor,
                      style: TextStyle(
                        fontSize: 11,
                        color: DormMateColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                status: isAvail ? 'Active' : (isInUse ? 'In Progress' : 'Cancelled'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // In-use countdown or available actions
          if (isInUse) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: DormMateColors.isDark ? const Color(0x330284C7) : const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: DormMateColors.isDark ? const Color(0x550284C7) : const Color(0xFFBAE6FD)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 16, color: DormMateColors.isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '${machine.remainingMinutes} mins left (เหลือ ${machine.remainingMinutes} น.)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: DormMateColors.isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Notification set for ${machine.name}!'),
                          backgroundColor: const Color(0xFF0284C7),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: DormMateColors.isDark ? const Color(0x440284C7) : const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_active_outlined, size: 13, color: DormMateColors.isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7)),
                          const SizedBox(width: 4),
                          Text(
                            'Notify',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: DormMateColors.isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (isAvail) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  await vm.startMachine(machine.id, minutes: 40);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Cycle started on ${machine.name}!')),
                    );
                  }
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text(
                  'Start Cycle / เริ่มใช้งาน (40 mins)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FacilityViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Facilities', style: DormMateTextStyles.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () => showFeatureGuideSheet(
              context,
              _selectedTab == 0 ? FeatureGuide.laundryGuide : FeatureGuide.amenityGuide,
            ),
            tooltip: _selectedTab == 0 ? 'ขั้นตอนการใช้เครื่องซักผ้า' : 'ขั้นตอนการจองห้อง',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: vm.loadAll,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: vm.isLoading && vm.machines.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Column(
                children: [
                  ShimmerSkeletonCard(height: 90, borderRadius: 18),
                  SizedBox(height: 12),
                  ShimmerSkeletonCard(height: 120, borderRadius: 18),
                  SizedBox(height: 12),
                  ShimmerSkeletonCard(height: 120, borderRadius: 18),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: vm.loadAll,
              color: DormMateColors.primary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                children: [
                  // Top Tab Bar
                  FadeSlideEntry(
                    delay: const Duration(milliseconds: 30),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: DormMateColors.glassBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: DormMateColors.divider),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedTab = 0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                decoration: BoxDecoration(
                                  color: _selectedTab == 0 ? DormMateColors.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.local_laundry_service_rounded,
                                      size: 15,
                                      color: _selectedTab == 0 ? Colors.white : DormMateColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'Smart Laundry',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: _selectedTab == 0 ? FontWeight.w700 : FontWeight.w500,
                                          color: _selectedTab == 0 ? Colors.white : DormMateColors.textSecondary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedTab = 1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                decoration: BoxDecoration(
                                  color: _selectedTab == 1 ? DormMateColors.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.meeting_room_rounded,
                                      size: 15,
                                      color: _selectedTab == 1 ? Colors.white : DormMateColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'Book Spaces',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: _selectedTab == 1 ? FontWeight.w700 : FontWeight.w500,
                                          color: _selectedTab == 1 ? Colors.white : DormMateColors.textSecondary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // TAB 1: Smart Laundry
                  if (_selectedTab == 0) ...[
                    // Status summary banner
                    FadeSlideEntry(
                      delay: const Duration(milliseconds: 50),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${vm.availableMachineCount} of ${vm.machines.length} Machines Ready',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    'Dormitory Laundry Room · 1st Floor',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withValues(alpha: 0.75),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Filter chips: All, Washer, Dryer
                    FadeSlideEntry(
                      delay: const Duration(milliseconds: 70),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildMachineFilterChip('All', 'All', vm),
                            const SizedBox(width: 8),
                            _buildMachineFilterChip('Washers (เครื่องซัก)', 'Washer', vm),
                            const SizedBox(width: 8),
                            _buildMachineFilterChip('Dryers (เครื่องอบ)', 'Dryer', vm),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Machines List
                    ...vm.filteredMachines.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final machine = entry.value;
                      return FadeSlideEntry(
                        delay: Duration(milliseconds: 90 + idx * 30),
                        child: _buildLaundryCard(machine, vm),
                      );
                    }),
                  ] else ...[
                    // TAB 2: Facility Booking
                    if (vm.bookings.isNotEmpty) ...[
                      Text(
                        'My Bookings (การจองของคุณ)',
                        style: DormMateTextStyles.sectionTitle,
                      ),
                      const SizedBox(height: 8),
                      ...vm.bookings.map((b) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0x1F000000)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: DormMateColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.event_seat_rounded, color: DormMateColors.primary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      b.amenityName,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${b.displayDate} · ${b.slot}',
                                      style: TextStyle(fontSize: 11, color: DormMateColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 20),
                                tooltip: 'Cancel Booking',
                                onPressed: () async {
                                  await vm.cancelBooking(b.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Booking cancelled')),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                    ],

                    Text(
                      'Available Spaces (พื้นที่ส่วนกลางที่เปิดให้บริการ)',
                      style: DormMateTextStyles.sectionTitle,
                    ),
                    const SizedBox(height: 8),

                    ...vm.amenities.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final amenity = entry.value;
                      return FadeSlideEntry(
                        delay: Duration(milliseconds: 60 + idx * 30),
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.meeting_room_rounded, color: Color(0xFF6366F1), size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          amenity.name,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: DormMateColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${amenity.floor} · Max ${amenity.capacity} Persons',
                                          style: TextStyle(fontSize: 11, color: DormMateColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                amenity.description,
                                style: TextStyle(fontSize: 12, color: DormMateColors.textSecondary),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: DormMateColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () => _showBookingSheet(context, amenity, vm),
                                  icon: const Icon(Icons.add_task_rounded, size: 16),
                                  label: const Text('Book a Slot / จองเวลาใช้งาน', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildMachineFilterChip(String label, String value, FacilityViewModel vm) {
    final isSelected = vm.machineFilter == value;
    return GestureDetector(
      onTap: () => vm.setMachineFilter(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? DormMateColors.primary : DormMateColors.glassBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? DormMateColors.primary : DormMateColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : DormMateColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
