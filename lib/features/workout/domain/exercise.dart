/// Exercise domain model per SRS 4.1.
class Exercise {
  final int id;
  final String name;
  final String primaryMuscle;
  final List<String> secondaryMuscles;
  final Map<String, double> contributionWeight;

  const Exercise({
    required this.id,
    required this.name,
    required this.primaryMuscle,
    required this.secondaryMuscles,
    required this.contributionWeight,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final rawSecondary = json['secondary_muscles'];
    final secondary = rawSecondary is List
        ? rawSecondary.map((e) => e.toString()).toList()
        : <String>[];

    final rawWeights = json['contribution_weight'];
    final weights = <String, double>{};
    if (rawWeights is Map) {
      rawWeights.forEach((key, value) {
        if (value is num) {
          weights[key.toString()] = value.toDouble();
        }
      });
    }

    return Exercise(
      id: json['id'] as int,
      name: json['name'] as String,
      primaryMuscle: json['primary_muscle'] as String,
      secondaryMuscles: secondary,
      contributionWeight: weights,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'primary_muscle': primaryMuscle,
      'secondary_muscles': secondaryMuscles,
      'contribution_weight': contributionWeight,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Exercise &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Exercise(id: $id, name: $name)';
}
