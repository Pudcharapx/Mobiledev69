import '../models/facility.dart';

abstract class FacilityRepository {
  Future<List<LaundryMachine>> getMachines();
  Future<void> startMachineCycle(String id, int minutes);
  Future<List<Amenity>> getAmenities();
  Future<List<AmenityBooking>> getBookings();
  Future<AmenityBooking> bookAmenity({
    required String amenityId,
    required String amenityName,
    required String slot,
    required DateTime date,
    required String roomNumber,
  });
  Future<void> cancelBooking(String bookingId);
}

class FacilityRepositoryImpl implements FacilityRepository {
  List<LaundryMachine> _machines = [
    const LaundryMachine(
      id: 'WM-01',
      name: 'Front-Load Washer 12kg #1',
      type: 'Washer',
      floor: 'Fl. 1 · Bldg B Laundry Room',
      status: 'Available',
    ),
    const LaundryMachine(
      id: 'WM-02',
      name: 'Front-Load Washer 12kg #2',
      type: 'Washer',
      floor: 'Fl. 1 · Bldg B Laundry Room',
      status: 'In Use',
      remainingMinutes: 14,
      totalMinutes: 40,
    ),
    const LaundryMachine(
      id: 'WM-03',
      name: 'Top-Load Washer 14kg #3',
      type: 'Washer',
      floor: 'Fl. 1 · Bldg B Laundry Room',
      status: 'Available',
    ),
    const LaundryMachine(
      id: 'DR-01',
      name: 'Heavy-Duty Dryer 15kg #1',
      type: 'Dryer',
      floor: 'Fl. 1 · Bldg B Laundry Room',
      status: 'In Use',
      remainingMinutes: 28,
      totalMinutes: 50,
    ),
    const LaundryMachine(
      id: 'DR-02',
      name: 'Heavy-Duty Dryer 15kg #2',
      type: 'Dryer',
      floor: 'Fl. 1 · Bldg B Laundry Room',
      status: 'Available',
    ),
    const LaundryMachine(
      id: 'WM-04',
      name: 'Front-Load Washer 10kg #4',
      type: 'Washer',
      floor: 'Fl. 1 · Bldg B Laundry Room',
      status: 'Maintenance',
    ),
  ];

  final List<Amenity> _amenities = [
    const Amenity(
      id: 'AM-01',
      name: 'Silent Study Room (ห้องอ่านหนังสือเงียบ)',
      type: 'Study Room',
      floor: 'Fl. 2 · Bldg B',
      capacity: 8,
      description: 'Individual desk study cubicles with high-speed Wi-Fi and power outlets.',
      availableSlots: [
        '09:00 - 12:00',
        '13:00 - 16:00',
        '16:00 - 19:00',
        '19:00 - 22:00',
      ],
    ),
    const Amenity(
      id: 'AM-02',
      name: 'Group Meeting Pod (ห้องทำงานกลุ่ม)',
      type: 'Meeting Room',
      floor: 'Fl. 2 · Bldg B',
      capacity: 6,
      description: 'Sound-dampened meeting room with smart TV display and magnetic whiteboard.',
      availableSlots: [
        '10:00 - 12:00',
        '13:00 - 15:00',
        '15:00 - 17:00',
        '17:00 - 19:00',
        '19:00 - 21:00',
      ],
    ),
    const Amenity(
      id: 'AM-03',
      name: 'Co-working & Lounge (พื้นที่สร้างสรรค์)',
      type: 'Co-working Pod',
      floor: 'Fl. 1 · Clubhouse',
      capacity: 12,
      description: 'Open collaborative space with sofa seating, coffee station, and beanbags.',
      availableSlots: [
        '08:00 - 12:00',
        '13:00 - 17:00',
        '18:00 - 22:00',
      ],
    ),
  ];

  List<AmenityBooking> _bookings = [
    AmenityBooking(
      id: 'BK-101',
      amenityId: 'AM-01',
      amenityName: 'Silent Study Room (ห้องอ่านหนังสือเงียบ)',
      slot: '19:00 - 22:00',
      date: DateTime.now(),
      roomNumber: 'B-204',
      status: 'Confirmed',
    ),
  ];

  FacilityRepositoryImpl({
    List<LaundryMachine>? initialMachines,
    List<AmenityBooking>? initialBookings,
  }) {
    if (initialMachines != null) _machines = List.from(initialMachines);
    if (initialBookings != null) _bookings = List.from(initialBookings);
  }

  @override
  Future<List<LaundryMachine>> getMachines() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return List.unmodifiable(_machines);
  }

  @override
  Future<void> startMachineCycle(String id, int minutes) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final index = _machines.indexWhere((m) => m.id == id);
    if (index != -1) {
      _machines[index] = _machines[index].copyWith(
        status: 'In Use',
        remainingMinutes: minutes,
        totalMinutes: minutes,
      );
    }
  }

  @override
  Future<List<Amenity>> getAmenities() async {
    await Future.delayed(const Duration(milliseconds: 30));
    return List.unmodifiable(_amenities);
  }

  @override
  Future<List<AmenityBooking>> getBookings() async {
    await Future.delayed(const Duration(milliseconds: 40));
    return List.unmodifiable(_bookings);
  }

  @override
  Future<AmenityBooking> bookAmenity({
    required String amenityId,
    required String amenityName,
    required String slot,
    required DateTime date,
    required String roomNumber,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final newBooking = AmenityBooking(
      id: 'BK-${DateTime.now().millisecondsSinceEpoch % 10000}',
      amenityId: amenityId,
      amenityName: amenityName,
      slot: slot,
      date: date,
      roomNumber: roomNumber,
      status: 'Confirmed',
    );
    _bookings.insert(0, newBooking);
    return newBooking;
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 40));
    _bookings.removeWhere((b) => b.id == bookingId);
  }
}
