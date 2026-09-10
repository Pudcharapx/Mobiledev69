import 'package:flutter/foundation.dart';
import '../../heatmap/data/exercise_repository.dart';
import '../data/workout_repository.dart';
import '../domain/exercise.dart';
import '../domain/workout_log.dart';

/// ViewModel managing state and business logic for the workout feature per SRS 3.1.
class WorkoutViewModel extends ChangeNotifier {
  final WorkoutRepository _workoutRepository;
  final ExerciseRepository _exerciseRepository;

  List<WorkoutLog> _logs = [];
  List<Exercise> _exercises = [];
  bool _isLoading = false;
  String? _errorMessage;

  WorkoutViewModel({
    required WorkoutRepository workoutRepository,
    required ExerciseRepository exerciseRepository,
  })  : _workoutRepository = workoutRepository,
        _exerciseRepository = exerciseRepository;

  List<WorkoutLog> get logs => List.unmodifiable(_logs);
  List<Exercise> get exercises => List.unmodifiable(_exercises);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Clear the active error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Initial load of both exercises and workout logs.
  Future<void> loadInitialData() async {
    _setLoading(true);
    await Future.wait([
      fetchExercises(),
      fetchLogs(),
    ]);
    _setLoading(false);
  }

  /// Fetch all available exercises from the repository.
  Future<void> fetchExercises() async {
    final result = await _exerciseRepository.getExercises();
    result.when(
      success: (data) {
        _exercises = data;
        _errorMessage = null;
      },
      failure: (message, _) {
        _errorMessage = message;
      },
    );
    notifyListeners();
  }

  /// Fetch workout logs for the authenticated user (sorted by date descending).
  Future<void> fetchLogs() async {
    final result = await _workoutRepository.getWorkoutLogs();
    result.when(
      success: (data) {
        // Ensure sorted by date descending per SRS 7.3
        _logs = List.from(data)..sort((a, b) => b.date.compareTo(a.date));
        _errorMessage = null;
      },
      failure: (message, _) {
        _errorMessage = message;
      },
    );
    notifyListeners();
  }

  /// Create a new workout log entry.
  Future<bool> createLog({
    required int exerciseId,
    required DateTime date,
    required int sets,
    required int reps,
    double? weightKg,
    String? note,
  }) async {
    _setLoading(true);
    final result = await _workoutRepository.createWorkoutLog(
      exerciseId: exerciseId,
      date: date,
      sets: sets,
      reps: reps,
      weightKg: weightKg,
      note: note,
    );

    bool success = false;
    result.when(
      success: (created) {
        _logs.insert(0, created);
        _logs.sort((a, b) => b.date.compareTo(a.date));
        _errorMessage = null;
        success = true;
      },
      failure: (message, _) {
        _errorMessage = message;
        success = false;
      },
    );

    _setLoading(false);
    return success;
  }

  /// Update an existing workout log entry.
  Future<bool> updateLog({
    required int id,
    required int exerciseId,
    required DateTime date,
    required int sets,
    required int reps,
    double? weightKg,
    String? note,
  }) async {
    _setLoading(true);
    final result = await _workoutRepository.updateWorkoutLog(
      id: id,
      exerciseId: exerciseId,
      date: date,
      sets: sets,
      reps: reps,
      weightKg: weightKg,
      note: note,
    );

    bool success = false;
    result.when(
      success: (updated) {
        final index = _logs.indexWhere((l) => l.id == id);
        if (index != -1) {
          _logs[index] = updated;
          _logs.sort((a, b) => b.date.compareTo(a.date));
        }
        _errorMessage = null;
        success = true;
      },
      failure: (message, _) {
        _errorMessage = message;
        success = false;
      },
    );

    _setLoading(false);
    return success;
  }

  /// Delete a workout log entry.
  Future<bool> deleteLog(int id) async {
    _setLoading(true);
    final result = await _workoutRepository.deleteWorkoutLog(id);

    bool success = false;
    result.when(
      success: (_) {
        _logs.removeWhere((l) => l.id == id);
        _errorMessage = null;
        success = true;
      },
      failure: (message, _) {
        _errorMessage = message;
        success = false;
      },
    );

    _setLoading(false);
    return success;
  }

  /// Smart Defaults per SRS 5:
  /// Pre-fill sets, reps, and weight from the last logged entry of this exercise.
  WorkoutLog? getLastLogForExercise(int exerciseId) {
    for (final log in _logs) {
      if (log.exerciseId == exerciseId) {
        return log;
      }
    }
    return null;
  }

  /// Helper to lookup an exercise by ID.
  Exercise? getExerciseById(int id) {
    for (final e in _exercises) {
      if (e.id == id) return e;
    }
    return null;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
