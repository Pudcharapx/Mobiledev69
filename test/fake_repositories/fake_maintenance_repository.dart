import 'package:project/models/maintenance_request.dart';
import 'package:project/repositories/maintenance_repository.dart';

class FakeMaintenanceRepository implements MaintenanceRepository {
  List<MaintenanceRequest> requests;
  bool shouldThrowError;
  String errorMessage;

  FakeMaintenanceRepository({
    List<MaintenanceRequest>? initialRequests,
    this.shouldThrowError = false,
    this.errorMessage = 'Simulated network error',
  }) : requests = initialRequests ?? [];

  @override
  Future<List<MaintenanceRequest>> getRequests() async {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    return List.from(requests);
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
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    final newId = requests.isEmpty ? 1 : (requests.map((r) => r.id).reduce((a, b) => a > b ? a : b) + 1);
    final created = MaintenanceRequest(
      id: newId,
      title: title,
      category: category,
      description: description,
      imageUrl: imageUrl,
      status: 'Pending',
      urgency: urgency,
      preferredTimeSlot: preferredTimeSlot,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    requests.add(created);
    return created;
  }

  @override
  Future<MaintenanceRequest> getDetail(int id) async {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    return requests.firstWhere((r) => r.id == id);
  }

  @override
  Future<void> cancelRequest(int id) async {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    requests.removeWhere((r) => r.id == id);
  }
}
