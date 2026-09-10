/// Constant endpoints for the backend REST API.
class ApiEndpoints {
  ApiEndpoints._();

  static const String defaultBaseUrl = 'http://127.0.0.1:8000';

  static const String exercises = '/api/exercises/';
  static String exerciseDetail(int id) => '/api/exercises/$id/';

  static const String workoutLogs = '/api/workout-logs/';
  static String workoutLogDetail(int id) => '/api/workout-logs/$id/';

  static const String workoutsAlias = '/api/workouts/';
  static String workoutAliasDetail(int id) => '/api/workouts/$id/';

  static const String weeklyGoals = '/api/weekly-goals/';
  static String weeklyGoalDetail(int id) => '/api/weekly-goals/$id/';
}
