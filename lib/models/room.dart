class Room {
  final int id;
  final String building;
  final int floor;
  final String roomNumber;
  final String roomType;
  final String status;

  const Room({
    required this.id,
    required this.building,
    required this.floor,
    required this.roomNumber,
    required this.roomType,
    required this.status,
  });

  String get displayLabel => '$building-$roomNumber';
  String get subtitle => 'Building $building · ${_ordinal(floor)} Floor';

  static String _ordinal(int n) {
    if (n == 1) return '1st';
    if (n == 2) return '2nd';
    if (n == 3) return '3rd';
    return '${n}th';
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as int? ?? 0,
      building: json['building'] as String? ?? '',
      floor: json['floor'] as int? ?? 0,
      roomNumber: json['room_number'] as String? ?? '',
      roomType: json['room_type'] as String? ?? '',
      status: json['status'] as String? ?? 'Active',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'building': building,
    'floor': floor,
    'room_number': roomNumber,
    'room_type': roomType,
    'status': status,
  };
}
