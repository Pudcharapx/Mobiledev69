class LaundryMachine {
  final String id;
  final String name;
  final String type; // 'Washer', 'Dryer'
  final String floor;
  final String status; // 'Available', 'In Use', 'Maintenance'
  final int remainingMinutes;
  final int totalMinutes;

  const LaundryMachine({
    required this.id,
    required this.name,
    required this.type,
    required this.floor,
    required this.status,
    this.remainingMinutes = 0,
    this.totalMinutes = 45,
  });

  bool get isAvailable => status == 'Available';
  bool get isInUse => status == 'In Use';
  bool get isMaintenance => status == 'Maintenance';

  LaundryMachine copyWith({
    String? id,
    String? name,
    String? type,
    String? floor,
    String? status,
    int? remainingMinutes,
    int? totalMinutes,
  }) {
    return LaundryMachine(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      floor: floor ?? this.floor,
      status: status ?? this.status,
      remainingMinutes: remainingMinutes ?? this.remainingMinutes,
      totalMinutes: totalMinutes ?? this.totalMinutes,
    );
  }
}

class Amenity {
  final String id;
  final String name;
  final String type; // 'Study Room', 'Co-working Pod', 'Fitness Space', 'Meeting Room'
  final String floor;
  final int capacity;
  final String description;
  final List<String> availableSlots;

  const Amenity({
    required this.id,
    required this.name,
    required this.type,
    required this.floor,
    required this.capacity,
    required this.description,
    required this.availableSlots,
  });
}

class AmenityBooking {
  final String id;
  final String amenityId;
  final String amenityName;
  final String slot;
  final DateTime date;
  final String roomNumber;
  final String status; // 'Confirmed', 'Cancelled'

  const AmenityBooking({
    required this.id,
    required this.amenityId,
    required this.amenityName,
    required this.slot,
    required this.date,
    required this.roomNumber,
    required this.status,
  });

  String get displayDate => '${date.day}/${date.month}/${date.year}';
}
