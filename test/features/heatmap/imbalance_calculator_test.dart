import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/features/heatmap/domain/imbalance_calculator.dart';
import 'package:project/features/heatmap/domain/muscle_volume_calculator.dart';

void main() {
  group('SRS 6 Opposing Muscle Pairs', () {
    test('contains exactly the 3 opposing pairs specified in SRS 6', () {
      const pairs = ImbalanceCalculator.opposingPairs;
      expect(pairs.length, equals(3));

      // Pair 1: chest vs back
      expect(pairs[0].muscleA, equals('chest'));
      expect(pairs[0].muscleB, equals('back'));

      // Pair 2: legs (quads) vs hamstrings
      expect(pairs[1].muscleA, equals('legs'));
      expect(pairs[1].muscleB, equals('hamstrings'));
      expect(pairs[1].labelA, equals('legs (quads)'));

      // Pair 3: biceps vs triceps
      expect(pairs[2].muscleA, equals('biceps'));
      expect(pairs[2].muscleB, equals('triceps'));
    });
  });

  group('SRS 8.2 Imbalance Calculator Numeric Logic', () {
    test('identifies imbalance when volume difference strictly exceeds 40%', () {
      // 100 vs 50 => diff = (100 - 50) / 100 = 0.50 (50% > 40%) => Alert
      final volumes = <String, double>{
        'chest': 100.0,
        'back': 50.0,
      };

      final pair = ImbalanceCalculator.opposingPairs.first;
      final alert = ImbalanceCalculator.evaluatePair(
        pair: pair,
        volumes: volumes,
      );

      expect(alert.hasImbalance, isTrue);
      expect(alert.differencePercentage, equals(0.50));
      expect(alert.differencePercentageInt, equals(50));
      expect(alert.overtrainedMuscle, equals('chest'));
      expect(alert.undertrainedMuscle, equals('back'));
      expect(
        alert.message,
        equals(
          'Your back is undertrained compared to your chest \u2014 consider adding more back work',
        ),
      );
    });

    test('does NOT trigger alert when volume difference is exactly 40% or lower', () {
      // 100 vs 60 => diff = (100 - 60) / 100 = 0.40 (40% == 40%) => No alert
      final volumes = <String, double>{
        'chest': 100.0,
        'back': 60.0,
      };

      final alert = ImbalanceCalculator.evaluatePair(
        pair: ImbalanceCalculator.opposingPairs[0],
        volumes: volumes,
      );

      expect(alert.hasImbalance, isFalse);
      expect(alert.differencePercentage, closeTo(0.40, 0.001));
      expect(alert.differencePercentageInt, equals(40));
    });

    test('does NOT trigger alert when both volumes are equal or zero', () {
      // Both zero
      final alertZero = ImbalanceCalculator.evaluatePair(
        pair: ImbalanceCalculator.opposingPairs[0],
        volumes: {'chest': 0.0, 'back': 0.0},
      );
      expect(alertZero.hasImbalance, isFalse);
      expect(alertZero.differencePercentage, equals(0.0));

      // Both equal
      final alertEqual = ImbalanceCalculator.evaluatePair(
        pair: ImbalanceCalculator.opposingPairs[0],
        volumes: {'chest': 150.0, 'back': 150.0},
      );
      expect(alertEqual.hasImbalance, isFalse);
      expect(alertEqual.differencePercentage, equals(0.0));
    });

    test('triggers alert with 100% diff when one muscle has volume and other has 0', () {
      final volumes = <String, double>{
        'legs': 200.0,
        'hamstrings': 0.0,
      };

      final alert = ImbalanceCalculator.evaluatePair(
        pair: ImbalanceCalculator.opposingPairs[1],
        volumes: volumes,
      );

      expect(alert.hasImbalance, isTrue);
      expect(alert.differencePercentage, equals(1.0));
      expect(alert.overtrainedMuscle, equals('legs'));
      expect(alert.undertrainedMuscle, equals('hamstrings'));
      expect(alert.overtrainedLabel, equals('legs (quads)'));
      expect(
        alert.message,
        equals(
          'Your hamstrings is undertrained compared to your legs (quads) \u2014 consider adding more hamstrings work',
        ),
      );
    });

    test('handles inverted opposing volume (e.g. hamstrings > legs)', () {
      final volumes = <String, double>{
        'legs': 30.0,
        'hamstrings': 100.0,
      };

      final alert = ImbalanceCalculator.evaluatePair(
        pair: ImbalanceCalculator.opposingPairs[1],
        volumes: volumes,
      );

      expect(alert.hasImbalance, isTrue);
      expect(alert.differencePercentage, equals(0.70));
      expect(alert.overtrainedMuscle, equals('hamstrings'));
      expect(alert.undertrainedMuscle, equals('legs'));
      expect(
        alert.message,
        equals(
          'Your legs (quads) is undertrained compared to your hamstrings \u2014 consider adding more legs (quads) work',
        ),
      );
    });

    test('checkVolumeImbalances returns only active alerts exceeding 40%', () {
      final volumes = <String, double>{
        'chest': 100.0,
        'back': 40.0, // 60% diff -> ALERT
        'legs': 100.0,
        'hamstrings': 80.0, // 20% diff -> BALANCED
        'biceps': 50.0,
        'triceps': 100.0, // 50% diff -> ALERT
      };

      final active = ImbalanceCalculator.checkVolumeImbalances(volumes: volumes);
      expect(active.length, equals(2));
      expect(active[0].pair.muscleA, equals('chest'));
      expect(active[1].pair.muscleA, equals('biceps'));
    });

    test('checkImbalances with MuscleVolumeData map works seamlessly', () {
      final volumeData = <String, MuscleVolumeData>{
        'chest': const MuscleVolumeData(
          muscleGroup: 'chest',
          volume: 120.0,
          targetVolume: 100.0,
          percentage: 1.2,
          color: Colors.green,
          contributingLogs: [],
        ),
        'back': const MuscleVolumeData(
          muscleGroup: 'back',
          volume: 30.0,
          targetVolume: 100.0,
          percentage: 0.3,
          color: Colors.red,
          contributingLogs: [],
        ),
      };

      final active = ImbalanceCalculator.checkImbalances(volumeData: volumeData);
      expect(active.length, equals(1));
      expect(active.first.differencePercentage, equals(0.75));
      expect(active.first.undertrainedMuscle, equals('back'));
      expect(
        active.first.message,
        equals(
          'Your back is undertrained compared to your chest \u2014 consider adding more back work',
        ),
      );
    });
  });
}
