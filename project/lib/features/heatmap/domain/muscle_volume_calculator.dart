import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../workout/domain/exercise.dart';
import '../../workout/domain/weekly_goal.dart';
import '../../workout/domain/workout_log.dart';

/// Result data structure for a single muscle group's training volume.
class MuscleVolumeData {
  final String muscleGroup;
  final double volume;
  final double targetVolume;
  final double percentage; // 0.0 to 1.0+
  final Color color;
  final List<WorkoutLog> contributingLogs;

  const MuscleVolumeData({
    required this.muscleGroup,
    required this.volume,
    required this.targetVolume,
    required this.percentage,
    required this.color,
    required this.contributingLogs,
  });

  int get percentageInt => (percentage * 100).round();
}

/// Calculator for muscle volumes and weekly completion percentages per SRS 8.1.
class MuscleVolumeCalculator {
  MuscleVolumeCalculator._();

  /// The 9 standard muscle groups defined in SRS.md section 6.
  static const List<String> muscleGroups = [
    'chest',
    'back',
    'shoulders',
    'biceps',
    'triceps',
    'legs',
    'hamstrings',
    'glutes',
    'core',
  ];

  /// Default baseline target volume if no WeeklyGoal is explicitly specified.
  /// 10 sets/week × 10 reps/set = 100.0 baseline volume.
  static const double defaultTargetVolume = 100.0;

  /// Calculate start of the current week (Monday at 00:00:00).
  static DateTime getStartOfWeek([DateTime? referenceDate]) {
    final now = referenceDate ?? DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  /// Calculate end of the current week (Sunday at 23:59:59).
  static DateTime getEndOfWeek([DateTime? referenceDate]) {
    final start = getStartOfWeek(referenceDate);
    return DateTime(start.year, start.month, start.day + 6, 23, 59, 59);
  }

  /// Filter logs that belong to the current week (Monday to Sunday).
  static List<WorkoutLog> filterThisWeeksLogs(
    List<WorkoutLog> allLogs, [
    DateTime? referenceDate,
  ]) {
    final start = getStartOfWeek(referenceDate);
    final end = getEndOfWeek(referenceDate);

    return allLogs.where((log) {
      final logDate = DateTime(log.date.year, log.date.month, log.date.day);
      return !logDate.isBefore(start) && !logDate.isAfter(end);
    }).toList();
  }

  /// Calculate weekly volume per muscle group according to the exact formula in SRS 8.1:
  /// volume(muscle group X) = Σ (sets × reps × contribution_weight[X])
  /// for every log that affects muscle group X this week.
  static Map<String, MuscleVolumeData> calculateWeeklyVolume({
    required List<WorkoutLog> logs,
    required List<Exercise> exercises,
    List<WeeklyGoal> goals = const [],
    DateTime? referenceDate,
  }) {
    // 1. Filter logs for this week
    final thisWeeksLogs = filterThisWeeksLogs(logs, referenceDate);

    // 2. Build exercise lookup map
    final exerciseMap = {for (final e in exercises) e.id: e};

    // 3. Build goal lookup map by muscle group
    final goalMap = {for (final g in goals) g.muscleGroup: g};

    // 4. Initialize accumulators
    final volumeMap = <String, double>{for (final m in muscleGroups) m: 0.0};
    final contributingMap = <String, List<WorkoutLog>>{
      for (final m in muscleGroups) m: []
    };

    // 5. Aggregate volume per muscle group
    for (final log in thisWeeksLogs) {
      final exercise = exerciseMap[log.exerciseId];
      if (exercise == null) continue;

      for (final entry in exercise.contributionWeight.entries) {
        final muscle = entry.key;
        final weight = entry.value;

        if (volumeMap.containsKey(muscle)) {
          final logVolume = log.sets * log.reps * weight;
          volumeMap[muscle] = (volumeMap[muscle] ?? 0.0) + logVolume;
          contributingMap[muscle]?.add(log);
        }
      }
    }

    // 6. Normalize against WeeklyGoal and map to red -> yellow -> green color
    final results = <String, MuscleVolumeData>{};
    for (final muscle in muscleGroups) {
      final volume = volumeMap[muscle] ?? 0.0;
      final goal = goalMap[muscle];

      // If goal specified, target = target_sets_per_week × 10 reps
      final targetVolume = goal != null
          ? (goal.targetSetsPerWeek * 10.0)
          : defaultTargetVolume;

      final percentage = targetVolume > 0 ? (volume / targetVolume) : 0.0;
      final color = AppColors.colorForCompletion(percentage);

      results[muscle] = MuscleVolumeData(
        muscleGroup: muscle,
        volume: volume,
        targetVolume: targetVolume,
        percentage: percentage,
        color: color,
        contributingLogs: contributingMap[muscle] ?? [],
      );
    }

    return results;
  }
}
