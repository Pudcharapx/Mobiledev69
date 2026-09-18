import 'package:flutter/foundation.dart';
import '../models/announcement.dart';
import '../repositories/announcement_repository.dart';

class AnnouncementViewModel extends ChangeNotifier {
  final AnnouncementRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<Announcement> _announcements = [];
  Announcement? _selectedAnnouncement;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  AnnouncementViewModel(this._repository);

  bool get isLoading => _isLoading;
  bool get isEmpty => !_isLoading && filteredAnnouncements.isEmpty;
  String? get errorMessage => _errorMessage;
  List<Announcement> get announcements => _announcements;
  Announcement? get selectedAnnouncement => _selectedAnnouncement;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  int get unreadCount => _announcements.where((a) => !a.isRead).length;

  List<Announcement> get filteredAnnouncements {
    var list = _announcements;

    if (_selectedCategory == 'Unread') {
      list = list.where((a) => !a.isRead).toList();
    } else if (_selectedCategory == 'Maintenance') {
      list = list.where((a) {
        final t = '${a.title} ${a.summary} ${a.content}'.toLowerCase();
        return t.contains('repair') || t.contains('maintenance') || t.contains('water') || t.contains('electric') || t.contains('elevator');
      }).toList();
    } else if (_selectedCategory == 'Important') {
      list = list.where((a) {
        final t = '${a.title} ${a.summary} ${a.content}'.toLowerCase();
        return t.contains('urgent') || t.contains('important') || t.contains('notice') || t.contains('fire') || t.contains('inspection');
      }).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((a) {
        return a.title.toLowerCase().contains(q) ||
               a.summary.toLowerCase().contains(q) ||
               a.content.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void markAllAsRead() {
    for (final a in _announcements) {
      if (!a.isRead) {
        a.isRead = true;
        _repository.markAsRead(a.id);
      }
    }
    notifyListeners();
  }

  Future<void> loadAnnouncements() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _announcements = await _repository.getAnnouncements();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load announcements.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectAnnouncement(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedAnnouncement = await _repository.getDetail(id);
      final idx = _announcements.indexWhere((a) => a.id == id);
      if (idx != -1) {
        _announcements[idx].isRead = true;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load announcement details.';
      _isLoading = false;
      notifyListeners();
    }
  }

  void markAsRead(int id) {
    _repository.markAsRead(id);
    final idx = _announcements.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _announcements[idx].isRead = true;
      notifyListeners();
    }
  }

  void clearSelection() {
    _selectedAnnouncement = null;
    notifyListeners();
  }
}
