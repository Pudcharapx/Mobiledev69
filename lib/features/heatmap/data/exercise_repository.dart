import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/result.dart';
import '../../workout/domain/exercise.dart';

/// Repository for loading seed exercises per SRS 3.3.
class ExerciseRepository {
  final ApiClient _apiClient;
  List<Exercise> _cache = [];

  ExerciseRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  List<Exercise> get cachedExercises => List.unmodifiable(_cache);

  /// Fetch all exercises from backend API.
  Future<Result<List<Exercise>>> getExercises({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache.isNotEmpty) {
      return Success(_cache);
    }

    final result = await _apiClient.get<dynamic>(ApiEndpoints.exercises);

    return result.when(
      success: (data) {
        if (data is List) {
          final exercises = data
              .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
              .toList();
          _cache = exercises;
          return Success(exercises);
        }
        return const Failure('Invalid response format for exercises.');
      },
      failure: (message, exception) => Failure(message, exception: exception),
    );
  }

  /// Get exercise by ID from cache or API.
  Future<Result<Exercise>> getExerciseById(int id) async {
    if (_cache.isNotEmpty) {
      try {
        final found = _cache.firstWhere((e) => e.id == id);
        return Success(found);
      } catch (_) {}
    }

    final result = await _apiClient.get<dynamic>(ApiEndpoints.exerciseDetail(id));

    return result.when(
      success: (data) {
        if (data is Map<String, dynamic>) {
          return Success(Exercise.fromJson(data));
        }
        return const Failure('Invalid exercise data format.');
      },
      failure: (message, exception) => Failure(message, exception: exception),
    );
  }
}
