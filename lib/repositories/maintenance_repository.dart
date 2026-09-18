import '../models/maintenance_request.dart';
import '../services/api_service.dart';

abstract class MaintenanceRepository {
  Future<List<MaintenanceRequest>> getRequests();
  Future<MaintenanceRequest> createRequest({
    required String title,
    required String category,
    required String description,
    String? imageUrl,
    String urgency = 'Normal',
    String preferredTimeSlot = 'Anytime',
  });
  Future<MaintenanceRequest> getDetail(int id);
  Future<void> cancelRequest(int id);
}

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  final ApiService _apiService;

  MaintenanceRepositoryImpl(this._apiService);

  @override
  Future<List<MaintenanceRequest>> getRequests() async {
    final data = await _apiService.getMaintenance();
    if (data is List) {
      return data
          .map((e) => MaintenanceRequest.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<MaintenanceRequest> createRequest({
    required String title,
    required String category,
    required String description,
    String? imageUrl,
    String urgency = 'Normal',
    String preferredTimeSlot = 'Anytime',
  }) async {
    final body = {
      'title': title,
      'category': category,
      'description': description,
      'urgency': urgency,
      'preferred_time_slot': preferredTimeSlot,
      if (imageUrl != null) 'image_url': imageUrl,
    };
    final data = await _apiService.createMaintenance(body);
    return MaintenanceRequest.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<MaintenanceRequest> getDetail(int id) async {
    final data = await _apiService.getMaintenanceDetail(id);
    return MaintenanceRequest.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> cancelRequest(int id) => _apiService.deleteMaintenance(id);
}
