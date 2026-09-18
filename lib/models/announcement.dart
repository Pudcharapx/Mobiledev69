class Announcement {
  final int id;
  final String title;
  final String summary;
  final String content;
  final String? imageUrl;
  final String publishedAt;
  bool isRead;

  Announcement({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    this.imageUrl,
    required this.publishedAt,
    this.isRead = false,
  });

  String get displayDate {
    try {
      final dt = DateTime.parse(publishedAt);
      const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return publishedAt;
    }
  }

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      content: json['content'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      publishedAt: json['published_at'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'summary': summary,
    'content': content,
    'image_url': imageUrl,
    'published_at': publishedAt,
    'is_read': isRead,
  };
}
