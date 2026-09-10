/// WeeklyGoal domain model per SRS 4.3.
class WeeklyGoal {
  final int id;
  final int userId;
  final String muscleGroup;
  final int targetSetsPerWeek;

  const WeeklyGoal({
    required this.id,
    required this.userId,
    required this.muscleGroup,
    required this.targetSetsPerWeek,
  });

  factory WeeklyGoal.fromJson(Map<String, dynamic> json) {
    return WeeklyGoal(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      muscleGroup: json['muscle_group'] as String,
      targetSetsPerWeek: json['target_sets_per_week'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'muscle_group': muscleGroup,
      'target_sets_per_week': targetSetsPerWeek,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyGoal &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'WeeklyGoal(muscleGroup: $muscleGroup, targetSetsPerWeek: $targetSetsPerWeek)';
}
