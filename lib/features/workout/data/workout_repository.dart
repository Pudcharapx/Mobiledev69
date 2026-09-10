import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/result.dart';
import '../domain/workout_log.dart';

/// Single Source of Truth (SSOT) repository for WorkoutLog CRUD operations per SRS 3.1 & 3.3.
class WorkoutRepository {
  final ApiClient _apiClient;

  WorkoutRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Read: List all workout logs for the authenticated user.
  Future<Result<List<WorkoutLog>>> getWorkoutLogs() async {
    final result = await _apiClient.get<dynamic>(ApiEndpoints.workoutLogs);

    return result.when(
      success: (data) {
        if (data is List) {
          final logs = data
              .map((e) => WorkoutLog.fromJson(e as Map<String, dynamic>))
              .toList();
          return Success(logs);
        }
        return const Failure('Invalid response format for workout logs.');
      },
      failure: (message, exception) => Failure(message, exception: exception),
    );
  }

  /// Read: Get single log detail by ID.
  Future<Result<WorkoutLog>> getWorkoutLog(int id) async {
    final result = await _apiClient.get<dynamic>(ApiEndpoints.workoutLogDetail(id));

    return result.when(
      success: (data) {
        if (data is Map<String, dynamic>) {
          return Success(WorkoutLog.fromJson(data));
        }
        return const Failure('Invalid workout log data format.');
      },
      failure: (message, exception) => Failure(message, exception: exception),
    );
  }

  /// Create: Add a new WorkoutLog.
  Future<Result<WorkoutLog>> createWorkoutLog({
    required int exerciseId,
    required DateTime date,
    required int sets,
    required int reps,
    double? weightKg,
    String? note,
  }) async {
    final formattedDate =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final payload = {
      'exercise_id': exerciseId,
      'date': formattedDate,
      'sets': sets,
      'reps': reps,
      'weight_kg': weightKg,
      'note': note,
    };

    final result = await _apiClient.post<dynamic>(
      ApiEndpoints.workoutLogs,
      data: payload,
    );

    return result.when(
      success: (data) {
        if (data is Map<String, dynamic>) {
          return Success(WorkoutLog.fromJson(data));
        }
        return const Failure('Failed to parse created workout log.');
      },
      failure: (message, exception) => Failure(message, exception: exception),
    );
  }

  /// Update: Edit an existing WorkoutLog.
  Future<Result<WorkoutLog>> updateWorkoutLog({
    required int id,
    required int exerciseId,
    required DateTime date,
    required int sets,
    required int reps,
    double? weightKg,
    String? note,
  }) async {
    final formattedDate =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final payload = {
      'exercise_id': exerciseId,
      'date': formattedDate,
      'sets': sets,
      'reps': reps,
      'weight_kg': weightKg,
      'note': note,
    };

    final result = await _apiClient.put<dynamic>(
      ApiEndpoints.workoutLogDetail(id),
      data: payload,
    );

    return result.when(
      success: (data) {
        if (data is Map<String, dynamic>) {
          return Success(WorkoutLog.fromJson(data));
        }
        return const Failure('Failed to parse updated workout log.');
      },
      failure: (message, exception) => Failure(message, exception: exception),
    );
  }

  /// Delete: Remove a WorkoutLog by ID.
  Future<Result<void>> deleteWorkoutLog(int id) async {
    final result = await _apiClient.delete<dynamic>(
      ApiEndpoints.workoutLogDetail(id),
    );

    return result.when(
      success: (_) => const Success(null),
      failure: (message, exception) => Failure(message, exception: exception),
    );
  }
}
