class Parcel {
  final String id;
  final String trackingNumber;
  final String carrier;
  final String recipientName;
  final String roomNumber;
  final DateTime arrivedAt;
  final DateTime? pickedUpAt;
  final String status; // 'Ready for Pickup', 'Claimed'
  final String shelfLocation;
  final String pickupCode;

  const Parcel({
    required this.id,
    required this.trackingNumber,
    required this.carrier,
    required this.recipientName,
    required this.roomNumber,
    required this.arrivedAt,
    this.pickedUpAt,
    required this.status,
    required this.shelfLocation,
    required this.pickupCode,
  });

  bool get isReady => status == 'Ready for Pickup';
  bool get isClaimed => status == 'Claimed';

  String get displayArrivedDate {
    final now = DateTime.now();
    final diff = now.difference(arrivedAt);
    if (diff.inHours < 1) {
      return 'Just now (${diff.inMinutes}m ago)';
    } else if (diff.inHours < 24) {
      return 'Today, ${arrivedAt.hour.toString().padLeft(2, '0')}:${arrivedAt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday, ${arrivedAt.hour.toString().padLeft(2, '0')}:${arrivedAt.minute.toString().padLeft(2, '0')}';
    }
    return '${arrivedAt.day}/${arrivedAt.month}/${arrivedAt.year}';
  }

  Parcel copyWith({
    String? id,
    String? trackingNumber,
    String? carrier,
    String? recipientName,
    String? roomNumber,
    DateTime? arrivedAt,
    DateTime? pickedUpAt,
    String? status,
    String? shelfLocation,
    String? pickupCode,
  }) {
    return Parcel(
      id: id ?? this.id,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      carrier: carrier ?? this.carrier,
      recipientName: recipientName ?? this.recipientName,
      roomNumber: roomNumber ?? this.roomNumber,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      status: status ?? this.status,
      shelfLocation: shelfLocation ?? this.shelfLocation,
      pickupCode: pickupCode ?? this.pickupCode,
    );
  }

  factory Parcel.fromJson(Map<String, dynamic> json) {
    return Parcel(
      id: json['id'] as String,
      trackingNumber: json['trackingNumber'] as String,
      carrier: json['carrier'] as String,
      recipientName: json['recipientName'] as String,
      roomNumber: json['roomNumber'] as String,
      arrivedAt: DateTime.parse(json['arrivedAt'] as String),
      pickedUpAt: json['pickedUpAt'] != null
          ? DateTime.parse(json['pickedUpAt'] as String)
          : null,
      status: json['status'] as String? ?? 'Ready for Pickup',
      shelfLocation: json['shelfLocation'] as String? ?? 'Locker',
      pickupCode: json['pickupCode'] as String? ?? 'PK-0000',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trackingNumber': trackingNumber,
      'carrier': carrier,
      'recipientName': recipientName,
      'roomNumber': roomNumber,
      'arrivedAt': arrivedAt.toIso8601String(),
      'pickedUpAt': pickedUpAt?.toIso8601String(),
      'status': status,
      'shelfLocation': shelfLocation,
      'pickupCode': pickupCode,
    };
  }
}
