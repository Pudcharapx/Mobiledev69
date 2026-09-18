import 'package:flutter_test/flutter_test.dart';
import 'package:project/features/workout/domain/one_rep_max_calculator.dart';
import 'package:project/features/workout/domain/workout_log.dart';

void main() {
  group('OneRepMaxCalculator Formula Tests', () {
    test('calculate1RM correctly handles edge cases', () {
      expect(OneRepMaxCalculator.calculate1RM(0, 10), 0.0);
      expect(OneRepMaxCalculator.calculate1RM(-50, 10), 0.0);
      expect(OneRepMaxCalculator.calculate1RM(100, 0), 0.0);
      expect(OneRepMaxCalculator.calculate1RM(100, -2), 0.0);
    });

    test('calculate1RM returns exact weight for 1 rep', () {
      expect(OneRepMaxCalculator.calculate1RM(100.0, 1), 100.0);
      expect(OneRepMaxCalculator.calculate1RM(72.5, 1), 72.5);
    });

    test('calculate1RM uses Epley formula: weight * (1 + reps / 30)', () {
      // 100 kg x 10 reps -> 100 * (1 + 10/30) = 100 * 1.3333... = 133.3 kg
      final estimate = OneRepMaxCalculator.calculate1RM(100.0, 10);
      expect(estimate, 133.3);

      // 60 kg x 5 reps -> 60 * (1 + 5/30) = 60 * 1.1666... = 70.0 kg
      expect(OneRepMaxCalculator.calculate1RM(60.0, 5), 70.0);
    });

    test('calculateBrzycki uses Brzycki formula: weight * (36 / (37 - reps))', () {
      // 100 kg x 10 reps -> 100 * (36 / 27) = 133.3 kg
      final estimate = OneRepMaxCalculator.calculateBrzycki(100.0, 10);
      expect(estimate, 133.3);

      // 1 rep returns exact weight
      expect(OneRepMaxCalculator.calculateBrzycki(80.0, 1), 80.0);
    });

    test('getRepPercentages returns expected estimated loads', () {
      final percentages = OneRepMaxCalculator.getRepPercentages(100.0);

      expect(percentages[1], 100.0);
      expect(percentages[3], 93.0);
      expect(percentages[5], 87.0);
      expect(percentages[8], 80.0);
      expect(percentages[10], 75.0);
      expect(percentages[12], 70.0);
    });
  });

  group('PersonalRecordTracker Tests', () {
    final baseLog = WorkoutLog(
      id: 1,
      userId: 1,
      exerciseId: 1, // Bench Press
      date: DateTime.now().subtract(const Duration(days: 7)),
      sets: 3,
      reps: 8,
      weightKg: 70.0,
    );

    test('First time logging an exercise triggers initial benchmark PR', () {
      final newLog = WorkoutLog(
        id: 2,
        userId: 1,
        exerciseId: 1,
        date: DateTime.now(),
        sets: 3,
        reps: 10,
        weightKg: 60.0,
      );

      final result = OneRepMaxCalculator.checkPersonalRecord(
        newLog: newLog,
        existingLogs: [],
      );

      expect(result.isFirstLog, isTrue);
      expect(result.isAnyPR, isTrue);
      expect(result.isNewWeightPR, isTrue);
      expect(result.isNew1RMPR, isTrue);
      expect(result.newWeight, 60.0);
    });

    test('Detects new Weight PR when lifted weight exceeds historical max', () {
      final newLog = WorkoutLog(
        id: 2,
        userId: 1,
        exerciseId: 1,
        date: DateTime.now(),
        sets: 3,
        reps: 6,
        weightKg: 80.0, // Previous was 70.0
      );

      final result = OneRepMaxCalculator.checkPersonalRecord(
        newLog: newLog,
        existingLogs: [baseLog],
      );

      expect(result.isNewWeightPR, isTrue);
      expect(result.previousMaxWeight, 70.0);
      expect(result.newWeight, 80.0);
      expect(result.weightDiff, 10.0);
    });

    test('Detects 1RM PR even if weight is equal but reps are higher', () {
      // Base: 70kg x 8 reps -> 1RM ~88.7kg
      // New: 70kg x 12 reps -> 1RM ~98.0kg
      final newLog = WorkoutLog(
        id: 2,
        userId: 1,
        exerciseId: 1,
        date: DateTime.now(),
        sets: 3,
        reps: 12,
        weightKg: 70.0,
      );

      final result = OneRepMaxCalculator.checkPersonalRecord(
        newLog: newLog,
        existingLogs: [baseLog],
      );

      expect(result.isNewWeightPR, isFalse); // Same weight
      expect(result.isNew1RMPR, isTrue); // Higher 1RM!
      expect(result.isAnyPR, isTrue);
      expect(result.oneRmDiff, greaterThan(0));
    });

    test('Returns no PR when lift is below previous records', () {
      final newLog = WorkoutLog(
        id: 2,
        userId: 1,
        exerciseId: 1,
        date: DateTime.now(),
        sets: 3,
        reps: 5,
        weightKg: 60.0, // Below 70.0kg x 8 reps
      );

      final result = OneRepMaxCalculator.checkPersonalRecord(
        newLog: newLog,
        existingLogs: [baseLog],
      );

      expect(result.isAnyPR, isFalse);
      expect(result.isNewWeightPR, isFalse);
      expect(result.isNew1RMPR, isFalse);
    });
  });
}
