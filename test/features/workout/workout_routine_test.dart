import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/api/api_client.dart';
import 'package:project/core/api/result.dart';
import 'package:project/features/heatmap/data/exercise_repository.dart';
import 'package:project/features/workout/data/workout_repository.dart';
import 'package:project/features/workout/domain/exercise.dart';
import 'package:project/features/workout/domain/workout_log.dart';
import 'package:project/features/workout/domain/workout_routine.dart';
import 'package:project/features/workout/presentation/workout_view_model.dart';

class MockWorkoutRepo extends WorkoutRepository {
  final List<WorkoutLog> logs = [];

  MockWorkoutRepo() : super(apiClient: ApiClient());

  @override
  Future<Result<List<WorkoutLog>>> getWorkoutLogs() async => Success(List.from(logs));

  @override
  Future<Result<WorkoutLog>> createWorkoutLog({
    required int exerciseId,
    required DateTime date,
    required int sets,
    required int reps,
    double? weightKg,
    String? note,
  }) async {
    final log = WorkoutLog(
      id: logs.length + 1,
      userId: 1,
      exerciseId: exerciseId,
      date: date,
      sets: sets,
      reps: reps,
      weightKg: weightKg,
      note: note,
    );
    logs.add(log);
    return Success(log);
  }
}

class MockExerciseRepo extends ExerciseRepository {
  MockExerciseRepo() : super(apiClient: ApiClient());

  @override
  Future<Result<List<Exercise>>> getExercises({bool forceRefresh = false}) async {
    return const Success([
      Exercise(
        id: 1,
        name: 'Bench Press',
        primaryMuscle: 'chest',
        secondaryMuscles: ['shoulders', 'triceps'],
        contributionWeight: {'chest': 1.0},
      ),
      Exercise(
        id: 2,
        name: 'Incline Dumbbell Press',
        primaryMuscle: 'chest',
        secondaryMuscles: [],
        contributionWeight: {'chest': 1.0},
      ),
      Exercise(
        id: 8,
        name: 'Overhead Press',
        primaryMuscle: 'shoulders',
        secondaryMuscles: [],
        contributionWeight: {'shoulders': 1.0},
      ),
    ]);
  }
}

void main() {
  group('WorkoutRoutine Presets Tests', () {
    test('standardPresets contains Push, Pull, Legs, Upper routines', () {
      const presets = WorkoutRoutine.standardPresets;
      expect(presets.length, greaterThanOrEqualTo(4));

      final names = presets.map((r) => r.name).toList();
      expect(names, contains('Push Day'));
      expect(names, contains('Pull Day'));
      expect(names, contains('Leg Day'));
      expect(names, contains('Upper Body Blast'));
    });

    test('Push Day has planned exercises and total sets', () {
      final pushRoutine = WorkoutRoutine.standardPresets.firstWhere((r) => r.name == 'Push Day');
      expect(pushRoutine.exercises.isNotEmpty, isTrue);
      expect(pushRoutine.totalSets, greaterThan(0));

      final firstEx = pushRoutine.exercises.first;
      expect(firstEx.exerciseName, 'Bench Press');
      expect(firstEx.targetSets, 4);
      expect(firstEx.targetReps, 8);
      expect(firstEx.suggestedWeightKg, 60.0);
    });
  });

  group('WorkoutViewModel logRoutine Tests', () {
    late WorkoutViewModel viewModel;
    late MockWorkoutRepo mockWorkoutRepo;
    late MockExerciseRepo mockExerciseRepo;

    setUp(() {
      mockWorkoutRepo = MockWorkoutRepo();
      mockExerciseRepo = MockExerciseRepo();
      viewModel = WorkoutViewModel(
        workoutRepository: mockWorkoutRepo,
        exerciseRepository: mockExerciseRepo,
      );
    });

    test('logRoutine batch logs all exercises into repository and updates state', () async {
      const routine = WorkoutRoutine(
        id: 'test_routine',
        name: 'Test Push',
        category: 'Hypertrophy',
        description: 'Testing batch routine log',
        emoji: '🔥',
        accentColorValue: 0xFFFF5722,
        exercises: [
          RoutineExercise(
            exerciseId: 1,
            exerciseName: 'Bench Press',
            targetSets: 3,
            targetReps: 10,
            suggestedWeightKg: 60.0,
            primaryMuscle: 'chest',
          ),
          RoutineExercise(
            exerciseId: 8,
            exerciseName: 'Overhead Press',
            targetSets: 3,
            targetReps: 10,
            suggestedWeightKg: 40.0,
            primaryMuscle: 'shoulders',
          ),
        ],
      );

      final loggedCount = await viewModel.logRoutine(routine);

      expect(loggedCount, 2);
      expect(viewModel.logs.length, 2);
      expect(mockWorkoutRepo.logs.length, 2);
      expect(viewModel.logs.any((l) => l.exerciseId == 1), isTrue);
      expect(viewModel.logs.any((l) => l.exerciseId == 8), isTrue);
    });
  });
}
