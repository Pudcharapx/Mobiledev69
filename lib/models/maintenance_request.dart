class MaintenanceRequest {
  final int id;
  final String title;
  final String category;
  final String description;
  final String? imageUrl;
  final String status; // Pending | In Progress | Completed | Cancelled
  final String urgency; // Normal | High | Emergency
  final String preferredTimeSlot; // Anytime | Morning (09:00 - 12:00) | Afternoon (13:00 - 17:00)
  final String createdAt;
  final String updatedAt;

  const MaintenanceRequest({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    this.imageUrl,
    required this.status,
    this.urgency = 'Normal',
    this.preferredTimeSlot = 'Anytime',
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => status == 'Pending' || status == 'In Progress';
  bool get isDeletable => status == 'Pending';

  String get displayDate {
    try {
      final dt = DateTime.parse(createdAt);
      const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return createdAt;
    }
  }

  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) {
    return MaintenanceRequest(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      status: json['status'] as String? ?? 'Pending',
      urgency: json['urgency'] as String? ?? 'Normal',
      preferredTimeSlot: json['preferred_time_slot'] as String? ?? json['preferredTimeSlot'] as String? ?? 'Anytime',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'category': category,
    'description': description,
    'urgency': urgency,
    'preferred_time_slot': preferredTimeSlot,
    if (imageUrl != null) 'image_url': imageUrl,
  };
}

class MaintenanceCategories {
  static const List<String> list = [
    'Electrical',
    'Water',
    'Air Conditioner',
    'Furniture',
    'Internet',
    'Bathroom',
    'Cleaning',
    'Other',
  ];
}

class MaintenanceUrgencies {
  static const String normal = 'Normal';
  static const String high = 'High';
  static const String emergency = 'Emergency';

  static const List<String> list = [normal, high, emergency];
}

class MaintenanceTimeSlots {
  static const String anytime = 'Anytime';
  static const String morning = 'Morning (09:00 - 12:00)';
  static const String afternoon = 'Afternoon (13:00 - 17:00)';

  static const List<String> list = [anytime, morning, afternoon];
}
