import 'workout_log.dart';

/// Result analysis of a logged set compared against historical performance.
class PersonalRecordResult {
  final bool isNewWeightPR;
  final bool isNew1RMPR;
  final bool isFirstLog;
  final double newWeight;
  final double? previousMaxWeight;
  final double new1RM;
  final double? previous1RM;

  const PersonalRecordResult({
    required this.isNewWeightPR,
    required this.isNew1RMPR,
    this.isFirstLog = false,
    required this.newWeight,
    this.previousMaxWeight,
    required this.new1RM,
    this.previous1RM,
  });

  bool get isAnyPR => isNewWeightPR || isNew1RMPR;

  double get weightDiff =>
      previousMaxWeight != null ? (newWeight - previousMaxWeight!) : 0.0;

  double get oneRmDiff =>
      previous1RM != null ? (new1RM - previous1RM!) : 0.0;
}

/// OneRepMaxCalculator implements sports science formulas (Epley & Brzycki)
/// for estimating 1-Rep Max and tracking PR breakthroughs per SRS domain logic.
class OneRepMaxCalculator {
  const OneRepMaxCalculator._();

  /// Calculates estimated 1RM using the validated Epley formula:
  /// 1RM = Weight * (1 + Reps / 30)
  /// Rounded to 1 decimal place.
  static double calculate1RM(double weightKg, int reps) {
    if (weightKg <= 0 || reps <= 0) return 0.0;
    if (reps == 1) return (weightKg * 10).roundToDouble() / 10;

    final estimate = weightKg * (1.0 + (reps / 30.0));
    return (estimate * 10).roundToDouble() / 10;
  }

  /// Calculates estimated 1RM using the Brzycki formula:
  /// 1RM = Weight * (36 / (37 - Reps))
  static double calculateBrzycki(double weightKg, int reps) {
    if (weightKg <= 0 || reps <= 0) return 0.0;
    if (reps >= 37) return calculate1RM(weightKg, reps);
    if (reps == 1) return (weightKg * 10).roundToDouble() / 10;

    final estimate = weightKg * (36.0 / (37.0 - reps));
    return (estimate * 10).roundToDouble() / 10;
  }

  /// Returns an estimated percentage load breakdown based on 1RM.
  /// Keys are reps (1, 3, 5, 8, 10, 12), values are estimated weights in kg.
  static Map<int, double> getRepPercentages(double oneRm) {
    const percentages = {
      1: 1.0,
      3: 0.93,
      5: 0.87,
      8: 0.80,
      10: 0.75,
      12: 0.70,
    };

    return percentages.map((reps, pct) =>
        MapEntry(reps, ((oneRm * pct) * 10).roundToDouble() / 10));
  }

  /// Evaluates whether a given [newLog] breaks a Personal Record (PR)
  /// against previous logs for the same exercise.
  static PersonalRecordResult checkPersonalRecord({
    required WorkoutLog newLog,
    required List<WorkoutLog> existingLogs,
  }) {
    final newWeight = newLog.weightKg;
    if (newWeight == null || newWeight <= 0) {
      return const PersonalRecordResult(
        isNewWeightPR: false,
        isNew1RMPR: false,
        newWeight: 0,
        new1RM: 0,
      );
    }

    final new1RM = calculate1RM(newWeight, newLog.reps);

    // Filter relevant past logs for the same exercise
    final pastLogs = existingLogs.where((l) =>
        l.exerciseId == newLog.exerciseId &&
        l.id != newLog.id &&
        l.weightKg != null &&
        l.weightKg! > 0).toList();

    if (pastLogs.isEmpty) {
      // First time logging this exercise with weight: it's an initial benchmark PR!
      return PersonalRecordResult(
        isNewWeightPR: true,
        isNew1RMPR: true,
        isFirstLog: true,
        newWeight: newWeight,
        previousMaxWeight: null,
        new1RM: new1RM,
        previous1RM: null,
      );
    }

    double maxPastWeight = 0.0;
    double maxPast1RM = 0.0;

    for (final log in pastLogs) {
      final w = log.weightKg!;
      if (w > maxPastWeight) maxPastWeight = w;
      final e1RM = calculate1RM(w, log.reps);
      if (e1RM > maxPast1RM) maxPast1RM = e1RM;
    }

    final isNewWeightPR = newWeight > maxPastWeight;
    final isNew1RMPR = new1RM > maxPast1RM;

    return PersonalRecordResult(
      isNewWeightPR: isNewWeightPR,
      isNew1RMPR: isNew1RMPR,
      isFirstLog: false,
      newWeight: newWeight,
      previousMaxWeight: maxPastWeight,
      new1RM: new1RM,
      previous1RM: maxPast1RM,
    );
  }
}
