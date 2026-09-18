import 'package:flutter/foundation.dart';
import '../models/maintenance_request.dart';
import '../repositories/maintenance_repository.dart';

class MaintenanceViewModel extends ChangeNotifier {
  final MaintenanceRepository _repository;

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _submissionSuccessMessage;
  List<MaintenanceRequest> _requests = [];
  MaintenanceRequest? _selectedRequest;
  String _selectedFilter = 'All';

  MaintenanceViewModel(this._repository);

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get isEmpty => !_isLoading && filteredRequests.isEmpty;
  String? get errorMessage => _errorMessage;
  String? get submissionSuccessMessage => _submissionSuccessMessage;
  List<MaintenanceRequest> get requests => _requests;
  MaintenanceRequest? get selectedRequest => _selectedRequest;
  String get selectedFilter => _selectedFilter;

  List<MaintenanceRequest> get filteredRequests {
    if (_selectedFilter == 'Pending') {
      return _requests.where((r) => r.status == 'Pending').toList();
    }
    if (_selectedFilter == 'Active') {
      return _requests.where((r) => r.status == 'In Progress' || r.status == 'Pending').toList();
    }
    if (_selectedFilter == 'Done') {
      return _requests.where((r) => r.status == 'Completed' || r.status == 'Cancelled').toList();
    }
    return _requests;
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  Future<void> loadRequests() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _requests = await _repository.getRequests();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load maintenance requests.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectRequest(int id) async {
    // If request already exists in current list, show it immediately
    final cached = _requests.where((r) => r.id == id).toList();
    if (cached.isNotEmpty) {
      _selectedRequest = cached.first;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedRequest = await _repository.getDetail(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // If we already have cached item, keep it without showing hard failure
      if (_selectedRequest == null) {
        _errorMessage = 'Failed to load request details.';
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelection() {
    _selectedRequest = null;
    notifyListeners();
  }

  Future<bool> createRequest({
    required String title,
    required String category,
    required String description,
    String? imageUrl,
    String urgency = 'Normal',
    String preferredTimeSlot = 'Anytime',
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newRequest = await _repository.createRequest(
        title: title,
        category: category,
        description: description,
        imageUrl: imageUrl,
        urgency: urgency,
        preferredTimeSlot: preferredTimeSlot,
      );
      _requests.insert(0, newRequest);
      _isSubmitting = false;
      _submissionSuccessMessage = 'Request submitted successfully';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to submit request: ${e.toString()}';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelRequest(int id) async {
    try {
      await _repository.cancelRequest(id);
      _requests.removeWhere((r) => r.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to cancel request.';
      notifyListeners();
      return false;
    }
  }
}
