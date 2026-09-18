/// An exercise step configured inside a workout routine template.
class RoutineExercise {
  final int exerciseId;
  final String exerciseName;
  final int targetSets;
  final int targetReps;
  final double? suggestedWeightKg;
  final String primaryMuscle;

  const RoutineExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.targetSets,
    required this.targetReps,
    this.suggestedWeightKg,
    required this.primaryMuscle,
  });

  Map<String, dynamic> toJson() => {
        'exercise_id': exerciseId,
        'exercise_name': exerciseName,
        'target_sets': targetSets,
        'target_reps': targetReps,
        'suggested_weight_kg': suggestedWeightKg,
        'primary_muscle': primaryMuscle,
      };

  factory RoutineExercise.fromJson(Map<String, dynamic> json) =>
      RoutineExercise(
        exerciseId: json['exercise_id'] as int,
        exerciseName: json['exercise_name'] as String,
        targetSets: json['target_sets'] as int,
        targetReps: json['target_reps'] as int,
        suggestedWeightKg: json['suggested_weight_kg'] != null
            ? (json['suggested_weight_kg'] as num).toDouble()
            : null,
        primaryMuscle: json['primary_muscle'] as String,
      );
}

/// A structured workout routine template (e.g. Push Day, Pull Day, Leg Day).
class WorkoutRoutine {
  final String id;
  final String name;
  final String category;
  final String description;
  final String emoji;
  final int accentColorValue;
  final List<RoutineExercise> exercises;

  const WorkoutRoutine({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.emoji,
    required this.accentColorValue,
    required this.exercises,
  });

  int get totalSets =>
      exercises.fold<int>(0, (sum, item) => sum + item.targetSets);

  /// Standard pre-configured gym routine presets matching seed exercises.
  static const List<WorkoutRoutine> standardPresets = [
    WorkoutRoutine(
      id: 'routine_push',
      name: 'Push Day',
      category: 'Hypertrophy',
      description: 'Focuses on chest, shoulders, and triceps pressing movements.',
      emoji: '🔥',
      accentColorValue: 0xFFFF5722, // Orange/Flame
      exercises: [
        RoutineExercise(
          exerciseId: 1,
          exerciseName: 'Bench Press',
          targetSets: 4,
          targetReps: 8,
          suggestedWeightKg: 60.0,
          primaryMuscle: 'chest',
        ),
        RoutineExercise(
          exerciseId: 2,
          exerciseName: 'Incline Dumbbell Press',
          targetSets: 3,
          targetReps: 10,
          suggestedWeightKg: 22.0,
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
        RoutineExercise(
          exerciseId: 16,
          exerciseName: 'Triceps Pushdown',
          targetSets: 3,
          targetReps: 12,
          suggestedWeightKg: 25.0,
          primaryMuscle: 'triceps',
        ),
        RoutineExercise(
          exerciseId: 3,
          exerciseName: 'Push-up',
          targetSets: 3,
          targetReps: 15,
          suggestedWeightKg: null,
          primaryMuscle: 'chest',
        ),
      ],
    ),
    WorkoutRoutine(
      id: 'routine_pull',
      name: 'Pull Day',
      category: 'Strength & Back',
      description: 'Strengthens lats, upper back, rhomboids, and biceps.',
      emoji: '⚡',
      accentColorValue: 0xFF2196F3, // Blue
      exercises: [
        RoutineExercise(
          exerciseId: 7,
          exerciseName: 'Deadlift',
          targetSets: 3,
          targetReps: 5,
          suggestedWeightKg: 100.0,
          primaryMuscle: 'back',
        ),
        RoutineExercise(
          exerciseId: 4,
          exerciseName: 'Pull-up',
          targetSets: 4,
          targetReps: 8,
          suggestedWeightKg: null,
          primaryMuscle: 'back',
        ),
        RoutineExercise(
          exerciseId: 6,
          exerciseName: 'Barbell Row',
          targetSets: 3,
          targetReps: 10,
          suggestedWeightKg: 50.0,
          primaryMuscle: 'back',
        ),
        RoutineExercise(
          exerciseId: 5,
          exerciseName: 'Lat Pulldown',
          targetSets: 3,
          targetReps: 12,
          suggestedWeightKg: 55.0,
          primaryMuscle: 'back',
        ),
        RoutineExercise(
          exerciseId: 15,
          exerciseName: 'Bicep Curl',
          targetSets: 3,
          targetReps: 12,
          suggestedWeightKg: 14.0,
          primaryMuscle: 'biceps',
        ),
      ],
    ),
    WorkoutRoutine(
      id: 'routine_legs',
      name: 'Leg Day',
      category: 'Lower Body',
      description: 'Comprehensive quad, hamstring, and glute development.',
      emoji: '🦵',
      accentColorValue: 0xFF4CAF50, // Green
      exercises: [
        RoutineExercise(
          exerciseId: 11,
          exerciseName: 'Barbell Squat',
          targetSets: 4,
          targetReps: 8,
          suggestedWeightKg: 80.0,
          primaryMuscle: 'legs',
        ),
        RoutineExercise(
          exerciseId: 13,
          exerciseName: 'Romanian Deadlift',
          targetSets: 3,
          targetReps: 10,
          suggestedWeightKg: 60.0,
          primaryMuscle: 'hamstrings',
        ),
        RoutineExercise(
          exerciseId: 12,
          exerciseName: 'Leg Press',
          targetSets: 3,
          targetReps: 12,
          suggestedWeightKg: 120.0,
          primaryMuscle: 'legs',
        ),
        RoutineExercise(
          exerciseId: 14,
          exerciseName: 'Lunge',
          targetSets: 3,
          targetReps: 12,
          suggestedWeightKg: 16.0,
          primaryMuscle: 'legs',
        ),
      ],
    ),
    WorkoutRoutine(
      id: 'routine_upper',
      name: 'Upper Body Blast',
      category: 'Compound Power',
      description: 'Balanced upper body compound workout for overall strength.',
      emoji: '💥',
      accentColorValue: 0xFF9C27B0, // Purple
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
          exerciseId: 6,
          exerciseName: 'Barbell Row',
          targetSets: 3,
          targetReps: 10,
          suggestedWeightKg: 50.0,
          primaryMuscle: 'back',
        ),
        RoutineExercise(
          exerciseId: 8,
          exerciseName: 'Overhead Press',
          targetSets: 3,
          targetReps: 10,
          suggestedWeightKg: 40.0,
          primaryMuscle: 'shoulders',
        ),
        RoutineExercise(
          exerciseId: 5,
          exerciseName: 'Lat Pulldown',
          targetSets: 3,
          targetReps: 12,
          suggestedWeightKg: 55.0,
          primaryMuscle: 'back',
        ),
      ],
    ),
  ];
}
