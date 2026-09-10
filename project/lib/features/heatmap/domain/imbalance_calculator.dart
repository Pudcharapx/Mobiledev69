import 'muscle_volume_calculator.dart';

/// Opposing muscle pair definition per SRS.md section 6.
class MusclePair {
  /// The primary muscle group key (matching MuscleVolumeCalculator and Exercise models).
  final String muscleA;

  /// The opposing muscle group key.
  final String muscleB;

  /// Human-readable label for muscle A (e.g. 'legs (quads)').
  final String labelA;

  /// Human-readable label for muscle B (e.g. 'hamstrings').
  final String labelB;

  const MusclePair({
    required this.muscleA,
    required this.muscleB,
    String? labelA,
    String? labelB,
  })  : labelA = labelA ?? muscleA,
        labelB = labelB ?? muscleB;

  @override
  String toString() => '$labelA vs $labelB';
}

/// Evaluation result for an opposing muscle pair per SRS.md section 8.2.
class ImbalanceAlert {
  final MusclePair pair;
  final String muscleA;
  final String muscleB;
  final String labelA;
  final String labelB;
  final double volumeA;
  final double volumeB;
  final String overtrainedMuscle;
  final String undertrainedMuscle;
  final String overtrainedLabel;
  final String undertrainedLabel;
  final double overtrainedVolume;
  final double undertrainedVolume;
  final double differencePercentage; // e.g. 0.50 for 50%
  final double threshold;
  final bool hasImbalance;
  final String message;

  const ImbalanceAlert({
    required this.pair,
    required this.muscleA,
    required this.muscleB,
    required this.labelA,
    required this.labelB,
    required this.volumeA,
    required this.volumeB,
    required this.overtrainedMuscle,
    required this.undertrainedMuscle,
    required this.overtrainedLabel,
    required this.undertrainedLabel,
    required this.overtrainedVolume,
    required this.undertrainedVolume,
    required this.differencePercentage,
    required this.threshold,
    required this.hasImbalance,
    required this.message,
  });

  /// Percentage difference rounded to an integer (e.g. 45 for 45%).
  int get differencePercentageInt => (differencePercentage * 100).round();
}

/// Imbalance alert calculation engine per SRS.md section 8.2.
/// Uses simple numeric comparison (no AI/ML).
class ImbalanceCalculator {
  ImbalanceCalculator._();

  /// Default threshold for imbalance detection per SRS 8.2 (40%).
  static const double defaultThreshold = 0.40;

  /// Exactly the 3 opposing muscle pairs specified in SRS.md section 6:
  /// 1. chest vs back
  /// 2. legs (quads) vs hamstrings
  /// 3. biceps vs triceps
  static const List<MusclePair> opposingPairs = [
    MusclePair(
      muscleA: 'chest',
      muscleB: 'back',
      labelA: 'chest',
      labelB: 'back',
    ),
    MusclePair(
      muscleA: 'legs',
      muscleB: 'hamstrings',
      labelA: 'legs (quads)',
      labelB: 'hamstrings',
    ),
    MusclePair(
      muscleA: 'biceps',
      muscleB: 'triceps',
      labelA: 'biceps',
      labelB: 'triceps',
    ),
  ];

  /// Format an alert message exactly in the style described in SRS.md section 8.2:
  /// "Your {undertrained} is undertrained compared to your {overtrained} — consider adding more {undertrained} work"
  static String buildAlertMessage(String undertrained, String overtrained) {
    return 'Your $undertrained is undertrained compared to your $overtrained \u2014 consider adding more $undertrained work';
  }

  /// Evaluate a single muscle pair against a map of volumes.
  static ImbalanceAlert evaluatePair({
    required MusclePair pair,
    required Map<String, double> volumes,
    double threshold = defaultThreshold,
  }) {
    final volA = volumes[pair.muscleA] ?? 0.0;
    final volB = volumes[pair.muscleB] ?? 0.0;

    final String overtrained;
    final String undertrained;
    final String overLabel;
    final String underLabel;
    final double overVol;
    final double underVol;

    if (volA >= volB) {
      overtrained = pair.muscleA;
      undertrained = pair.muscleB;
      overLabel = pair.labelA;
      underLabel = pair.labelB;
      overVol = volA;
      underVol = volB;
    } else {
      overtrained = pair.muscleB;
      undertrained = pair.muscleA;
      overLabel = pair.labelB;
      underLabel = pair.labelA;
      overVol = volB;
      underVol = volA;
    }

    // Simple numeric comparison:
    // If both are 0, difference is 0.0.
    // Otherwise difference = (max - min) / max.
    final double diff;
    if (overVol <= 0.0) {
      diff = 0.0;
    } else {
      diff = (overVol - underVol) / overVol;
    }

    final bool hasImbalance = diff > threshold;
    final String message = buildAlertMessage(underLabel, overLabel);

    return ImbalanceAlert(
      pair: pair,
      muscleA: pair.muscleA,
      muscleB: pair.muscleB,
      labelA: pair.labelA,
      labelB: pair.labelB,
      volumeA: volA,
      volumeB: volB,
      overtrainedMuscle: overtrained,
      undertrainedMuscle: undertrained,
      overtrainedLabel: overLabel,
      undertrainedLabel: underLabel,
      overtrainedVolume: overVol,
      undertrainedVolume: underVol,
      differencePercentage: diff,
      threshold: threshold,
      hasImbalance: hasImbalance,
      message: message,
    );
  }

  /// Check active imbalances using MuscleVolumeData map.
  /// Returns only the pairs that exceed the threshold (> 40%).
  static List<ImbalanceAlert> checkImbalances({
    required Map<String, MuscleVolumeData> volumeData,
    double threshold = defaultThreshold,
  }) {
    final volumes = volumeData.map((key, value) => MapEntry(key, value.volume));
    return checkVolumeImbalances(volumes: volumes, threshold: threshold);
  }

  /// Check active imbalances using a raw volume map.
  /// Returns only the pairs that exceed the threshold (> 40%).
  static List<ImbalanceAlert> checkVolumeImbalances({
    required Map<String, double> volumes,
    double threshold = defaultThreshold,
  }) {
    return evaluateAllPairs(volumes: volumes, threshold: threshold)
        .where((alert) => alert.hasImbalance)
        .toList();
  }

  /// Evaluate all opposing pairs and return their balance status.
  static List<ImbalanceAlert> evaluateAllPairs({
    required Map<String, double> volumes,
    double threshold = defaultThreshold,
  }) {
    return opposingPairs
        .map((pair) => evaluatePair(
              pair: pair,
              volumes: volumes,
              threshold: threshold,
            ))
        .toList();
  }
}
