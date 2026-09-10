/// WorkoutLog domain model per SRS 4.2.
class WorkoutLog {
  final int id;
  final int userId;
  final int exerciseId;
  final DateTime date;
  final int sets;
  final int reps;
  final double? weightKg;
  final String? note;

  const WorkoutLog({
    required this.id,
    required this.userId,
    required this.exerciseId,
    required this.date,
    required this.sets,
    required this.reps,
    this.weightKg,
    this.note,
  });

  factory WorkoutLog.fromJson(Map<String, dynamic> json) {
    return WorkoutLog(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      exerciseId: json['exercise_id'] as int,
      date: DateTime.parse(json['date'] as String),
      sets: json['sets'] as int,
      reps: json['reps'] as int,
      weightKg: json['weight_kg'] != null
          ? (json['weight_kg'] as num).toDouble()
          : null,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'exercise_id': exerciseId,
      'date': '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'sets': sets,
      'reps': reps,
      'weight_kg': weightKg,
      'note': note,
    };
  }

  WorkoutLog copyWith({
    int? id,
    int? userId,
    int? exerciseId,
    DateTime? date,
    int? sets,
    int? reps,
    double? weightKg,
    String? note,
  }) {
    return WorkoutLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      exerciseId: exerciseId ?? this.exerciseId,
      date: date ?? this.date,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutLog &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'WorkoutLog(id: $id, exerciseId: $exerciseId, date: $date, sets: $sets, reps: $reps, weightKg: $weightKg)';
}
