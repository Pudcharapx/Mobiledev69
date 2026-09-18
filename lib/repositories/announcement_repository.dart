import '../models/announcement.dart';
import '../services/api_service.dart';

abstract class AnnouncementRepository {
  Future<List<Announcement>> getAnnouncements();
  Future<Announcement> getDetail(int id);
  void markAsRead(int id);
}

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  final ApiService _apiService;
  final Set<int> _readIds = {};

  AnnouncementRepositoryImpl(this._apiService);

  @override
  Future<List<Announcement>> getAnnouncements() async {
    final data = await _apiService.getAnnouncements();
    if (data is List) {
      return data.map((e) {
        final item = Announcement.fromJson(e as Map<String, dynamic>);
        item.isRead = _readIds.contains(item.id);
        return item;
      }).toList();
    }
    return [];
  }

  @override
  Future<Announcement> getDetail(int id) async {
    final data = await _apiService.getAnnouncementDetail(id);
    final item = Announcement.fromJson(data as Map<String, dynamic>);
    markAsRead(id);
    item.isRead = true;
    return item;
  }

  @override
  void markAsRead(int id) {
    _readIds.add(id);
  }
}
