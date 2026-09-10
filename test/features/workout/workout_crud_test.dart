import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/api/api_client.dart';
import 'package:project/core/api/result.dart';
import 'package:project/features/heatmap/data/exercise_repository.dart';
import 'package:project/features/workout/data/workout_repository.dart';
import 'package:project/features/workout/domain/exercise.dart';
import 'package:project/features/workout/domain/workout_log.dart';
import 'package:project/features/workout/presentation/log_form.dart';
import 'package:project/features/workout/presentation/workout_view_model.dart';
import 'package:provider/provider.dart';

class FakeWorkoutRepository extends WorkoutRepository {
  final List<WorkoutLog> _mockLogs;
  bool shouldFail = false;

  FakeWorkoutRepository(this._mockLogs) : super(apiClient: ApiClient());

  @override
  Future<Result<List<WorkoutLog>>> getWorkoutLogs() async {
    if (shouldFail) return const Failure('Network error loading logs.');
    return Success(List.from(_mockLogs));
  }

  @override
  Future<Result<WorkoutLog>> createWorkoutLog({
    required int exerciseId,
    required DateTime date,
    required int sets,
    required int reps,
    double? weightKg,
    String? note,
  }) async {
    if (shouldFail) return const Failure('API error creating log.');
    final newLog = WorkoutLog(
      id: _mockLogs.length + 1,
      userId: 1,
      exerciseId: exerciseId,
      date: date,
      sets: sets,
      reps: reps,
      weightKg: weightKg,
      note: note,
    );
    _mockLogs.add(newLog);
    return Success(newLog);
  }

  @override
  Future<Result<WorkoutLog>> updateWorkoutLog({
    required int id,
    required int exerciseId,
    required DateTime date,
    required int sets,
    required int reps,
    double? weightKg,
    String? note,
  }) async {
    if (shouldFail) return const Failure('API error updating log.');
    final updated = WorkoutLog(
      id: id,
      userId: 1,
      exerciseId: exerciseId,
      date: date,
      sets: sets,
      reps: reps,
      weightKg: weightKg,
      note: note,
    );
    final idx = _mockLogs.indexWhere((l) => l.id == id);
    if (idx != -1) _mockLogs[idx] = updated;
    return Success(updated);
  }

  @override
  Future<Result<void>> deleteWorkoutLog(int id) async {
    if (shouldFail) return const Failure('API error deleting log.');
    _mockLogs.removeWhere((l) => l.id == id);
    return const Success(null);
  }
}

class FakeExerciseRepository extends ExerciseRepository {
  final List<Exercise> _mockExercises;

  FakeExerciseRepository(this._mockExercises) : super(apiClient: ApiClient());

  @override
  Future<Result<List<Exercise>>> getExercises({bool forceRefresh = false}) async {
    return Success(List.from(_mockExercises));
  }
}

void main() {
  final testExercises = [
    const Exercise(
      id: 1,
      name: 'Bench Press',
      primaryMuscle: 'chest',
      secondaryMuscles: ['shoulders', 'triceps'],
      contributionWeight: {'chest': 1.0, 'shoulders': 0.5, 'triceps': 0.5},
    ),
    const Exercise(
      id: 4,
      name: 'Pull-up',
      primaryMuscle: 'back',
      secondaryMuscles: ['biceps', 'shoulders'],
      contributionWeight: {'back': 1.0, 'biceps': 0.5, 'shoulders': 0.5},
    ),
  ];

  group('WorkoutLog Model Tests', () {
    test('WorkoutLog JSON serialization and deserialization', () {
      final log = WorkoutLog(
        id: 10,
        userId: 1,
        exerciseId: 1,
        date: DateTime(2026, 9, 10),
        sets: 3,
        reps: 10,
        weightKg: 65.5,
        note: 'Felt great',
      );

      final json = log.toJson();
      expect(json['id'], 10);
      expect(json['user_id'], 1);
      expect(json['exercise_id'], 1);
      expect(json['date'], '2026-09-10');
      expect(json['sets'], 3);
      expect(json['reps'], 10);
      expect(json['weight_kg'], 65.5);
      expect(json['note'], 'Felt great');

      final fromJson = WorkoutLog.fromJson(json);
      expect(fromJson.id, log.id);
      expect(fromJson.weightKg, log.weightKg);
      expect(fromJson.note, log.note);
    });

    test('WorkoutLog handles nullable weight and note', () {
      final log = WorkoutLog(
        id: 11,
        userId: 1,
        exerciseId: 4,
        date: DateTime(2026, 9, 10),
        sets: 4,
        reps: 8,
      );

      final json = log.toJson();
      expect(json['weight_kg'], isNull);
      expect(json['note'], isNull);

      final fromJson = WorkoutLog.fromJson(json);
      expect(fromJson.weightKg, isNull);
      expect(fromJson.note, isNull);
    });
  });

  group('WorkoutViewModel & Smart Defaults Tests', () {
    late FakeWorkoutRepository workoutRepo;
    late FakeExerciseRepository exerciseRepo;
    late WorkoutViewModel viewModel;

    setUp(() {
      workoutRepo = FakeWorkoutRepository([
        WorkoutLog(
          id: 1,
          userId: 1,
          exerciseId: 1,
          date: DateTime(2026, 9, 9),
          sets: 4,
          reps: 12,
          weightKg: 70.0,
        ),
      ]);
      exerciseRepo = FakeExerciseRepository(testExercises);
      viewModel = WorkoutViewModel(
        workoutRepository: workoutRepo,
        exerciseRepository: exerciseRepo,
      );
    });

    test('loadInitialData populates exercises and logs', () async {
      await viewModel.loadInitialData();
      expect(viewModel.exercises.length, 2);
      expect(viewModel.logs.length, 1);
      expect(viewModel.logs.first.exerciseId, 1);
    });

    test('Smart Defaults (SRS 5): pre-fills last logged values for exercise',
        () async {
      await viewModel.loadInitialData();
      final lastLog = viewModel.getLastLogForExercise(1);
      expect(lastLog, isNotNull);
      expect(lastLog!.sets, 4);
      expect(lastLog.reps, 12);
      expect(lastLog.weightKg, 70.0);

      // Exercise without prior logs returns null
      expect(viewModel.getLastLogForExercise(4), isNull);
    });

    test('createLog adds log to top of list', () async {
      await viewModel.loadInitialData();
      final success = await viewModel.createLog(
        exerciseId: 4,
        date: DateTime(2026, 9, 10),
        sets: 5,
        reps: 5,
        weightKg: null,
      );

      expect(success, isTrue);
      expect(viewModel.logs.length, 2);
      expect(viewModel.logs.first.exerciseId, 4);
    });

    test('updateLog modifies existing log', () async {
      await viewModel.loadInitialData();
      final success = await viewModel.updateLog(
        id: 1,
        exerciseId: 1,
        date: DateTime(2026, 9, 9),
        sets: 5,
        reps: 10,
        weightKg: 75.0,
      );

      expect(success, isTrue);
      final updated = viewModel.logs.firstWhere((l) => l.id == 1);
      expect(updated.sets, 5);
      expect(updated.weightKg, 75.0);
    });

    test('deleteLog removes log from list', () async {
      await viewModel.loadInitialData();
      final success = await viewModel.deleteLog(1);

      expect(success, isTrue);
      expect(viewModel.logs, isEmpty);
    });
  });

  group('LogForm Stepper & Input UX Tests (SRS 5)', () {
    late WorkoutViewModel viewModel;

    setUp(() {
      final workoutRepo = FakeWorkoutRepository([]);
      final exerciseRepo = FakeExerciseRepository(testExercises);
      viewModel = WorkoutViewModel(
        workoutRepository: workoutRepo,
        exerciseRepository: exerciseRepo,
      );
    });

    testWidgets('Stepper (+/-) increments and decrements sets and reps',
        (tester) async {
      await viewModel.loadInitialData();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<WorkoutViewModel>.value(
            value: viewModel,
            child: const LogForm(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Default sets is 3, reps is 10
      expect(find.text('3'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);

      // Tap + button on Sets (first add icon)
      final addButtons = find.byIcon(Icons.add_rounded);
      await tester.tap(addButtons.at(0));
      await tester.pumpAndSettle();
      expect(find.text('4'), findsOneWidget);

      // Tap - button on Sets (first remove icon)
      final removeButtons = find.byIcon(Icons.remove_rounded);
      await tester.tap(removeButtons.at(0));
      await tester.pumpAndSettle();
      expect(find.text('3'), findsOneWidget);
    });
  });
}
