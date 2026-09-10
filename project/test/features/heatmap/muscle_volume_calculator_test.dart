import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/theme/app_colors.dart';
import 'package:project/features/heatmap/domain/muscle_volume_calculator.dart';
import 'package:project/features/workout/domain/exercise.dart';
import 'package:project/features/workout/domain/weekly_goal.dart';
import 'package:project/features/workout/domain/workout_log.dart';

void main() {
  final exercises = [
    // Bench Press: chest = 1.0, shoulders = 0.5, triceps = 0.5
    const Exercise(
      id: 1,
      name: 'Bench Press',
      primaryMuscle: 'chest',
      secondaryMuscles: ['shoulders', 'triceps'],
      contributionWeight: {'chest': 1.0, 'shoulders': 0.5, 'triceps': 0.5},
    ),
    // Barbell Squat: legs = 1.0, glutes = 0.5, core = 0.5
    const Exercise(
      id: 11,
      name: 'Barbell Squat',
      primaryMuscle: 'legs',
      secondaryMuscles: ['glutes', 'core'],
      contributionWeight: {'legs': 1.0, 'glutes': 0.5, 'core': 0.5},
    ),
    // Pull-up: back = 1.0, biceps = 0.5, shoulders = 0.5
    const Exercise(
      id: 4,
      name: 'Pull-up',
      primaryMuscle: 'back',
      secondaryMuscles: ['biceps', 'shoulders'],
      contributionWeight: {'back': 1.0, 'biceps': 0.5, 'shoulders': 0.5},
    ),
  ];

  group('MuscleVolumeCalculator Tests', () {
    test('Calculates volume using exact SRS 8.1 formula', () {
      final now = DateTime.now();
      final monday = MuscleVolumeCalculator.getStartOfWeek(now);

      final logs = [
        // 3 sets × 10 reps Bench Press = 30 volume for chest, 15 for shoulders and triceps
        WorkoutLog(
          id: 1,
          userId: 1,
          exerciseId: 1,
          date: monday,
          sets: 3,
          reps: 10,
        ),
        // 4 sets × 10 reps Barbell Squat = 40 volume for legs, 20 for glutes and core
        WorkoutLog(
          id: 2,
          userId: 1,
          exerciseId: 11,
          date: monday.add(const Duration(days: 1)),
          sets: 4,
          reps: 10,
        ),
      ];

      final results = MuscleVolumeCalculator.calculateWeeklyVolume(
        logs: logs,
        exercises: exercises,
        referenceDate: now,
      );

      // Verify chest volume: 3 * 10 * 1.0 = 30.0
      expect(results['chest']!.volume, 30.0);
      expect(results['chest']!.contributingLogs.length, 1);

      // Verify shoulders volume: 3 * 10 * 0.5 = 15.0
      expect(results['shoulders']!.volume, 15.0);

      // Verify triceps volume: 3 * 10 * 0.5 = 15.0
      expect(results['triceps']!.volume, 15.0);

      // Verify legs volume: 4 * 10 * 1.0 = 40.0
      expect(results['legs']!.volume, 40.0);

      // Verify glutes volume: 4 * 10 * 0.5 = 20.0
      expect(results['glutes']!.volume, 20.0);

      // Verify core volume: 4 * 10 * 0.5 = 20.0
      expect(results['core']!.volume, 20.0);

      // Untrained muscle groups have 0.0 volume
      expect(results['back']!.volume, 0.0);
      expect(results['biceps']!.volume, 0.0);
      expect(results['hamstrings']!.volume, 0.0);
    });

    test('Excludes logs outside of the current week', () {
      final now = DateTime.now();
      final startOfWeek = MuscleVolumeCalculator.getStartOfWeek(now);

      final logs = [
        // Log from 2 weeks ago
        WorkoutLog(
          id: 1,
          userId: 1,
          exerciseId: 1,
          date: startOfWeek.subtract(const Duration(days: 14)),
          sets: 5,
          reps: 10,
        ),
        // Log from today (this week)
        WorkoutLog(
          id: 2,
          userId: 1,
          exerciseId: 1,
          date: startOfWeek,
          sets: 2,
          reps: 10,
        ),
      ];

      final results = MuscleVolumeCalculator.calculateWeeklyVolume(
        logs: logs,
        exercises: exercises,
        referenceDate: now,
      );

      // Only today's 2 sets should count: 2 * 10 * 1.0 = 20.0
      expect(results['chest']!.volume, 20.0);
      expect(results['chest']!.contributingLogs.length, 1);
      expect(results['chest']!.contributingLogs.first.id, 2);
    });

    test('Normalizes against WeeklyGoal and assigns correct heatmap colors', () {
      final now = DateTime.now();
      final monday = MuscleVolumeCalculator.getStartOfWeek(now);

      // Custom weekly goals
      final goals = [
        const WeeklyGoal(
          id: 1,
          userId: 1,
          muscleGroup: 'chest',
          targetSetsPerWeek: 5, // 5 sets * 10 reps = 50 target volume
        ),
        const WeeklyGoal(
          id: 2,
          userId: 1,
          muscleGroup: 'back',
          targetSetsPerWeek: 10, // 10 sets * 10 reps = 100 target volume
        ),
      ];

      final logs = [
        // Chest: 5 sets * 10 reps * 1.0 = 50 volume -> 100% of goal (Green)
        WorkoutLog(
          id: 1,
          userId: 1,
          exerciseId: 1,
          date: monday,
          sets: 5,
          reps: 10,
        ),
        // Back: 3 sets * 10 reps * 1.0 = 30 volume -> 30% of goal (Red: under-trained)
        WorkoutLog(
          id: 2,
          userId: 1,
          exerciseId: 4,
          date: monday,
          sets: 3,
          reps: 10,
        ),
      ];

      final results = MuscleVolumeCalculator.calculateWeeklyVolume(
        logs: logs,
        exercises: exercises,
        goals: goals,
        referenceDate: now,
      );

      // Chest is 100% -> optimal green
      expect(results['chest']!.percentage, 1.0);
      expect(results['chest']!.color, AppColors.heatmapOptimal);

      // Back is 30% -> under-trained red (< 50%)
      expect(results['back']!.percentage, 0.3);
      expect(results['back']!.color, AppColors.heatmapUnderTrained);

      // Untrained muscle group -> default neutral
      expect(results['hamstrings']!.volume, 0.0);
      expect(results['hamstrings']!.color, AppColors.heatmapDefault);
    });
  });
}
