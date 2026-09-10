import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/api/api_client.dart';
import 'package:project/core/theme/app_colors.dart';
import 'package:project/features/heatmap/data/exercise_repository.dart';
import 'package:project/features/heatmap/domain/muscle_volume_calculator.dart';
import 'package:project/features/heatmap/presentation/body_svg_widget.dart';
import 'package:project/features/heatmap/presentation/muscle_zone_detail_popup.dart';
import 'package:project/features/workout/data/workout_repository.dart';
import 'package:project/features/workout/domain/workout_log.dart';
import 'package:project/features/workout/presentation/workout_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  final testLog = WorkoutLog(
    id: 1,
    userId: 1,
    exerciseId: 1,
    date: DateTime.now(),
    sets: 3,
    reps: 10,
    weightKg: 60.0,
  );

  final sampleVolumeData = {
    'chest': MuscleVolumeData(
      muscleGroup: 'chest',
      volume: 30.0,
      targetVolume: 100.0,
      percentage: 0.3,
      color: AppColors.heatmapUnderTrained,
      contributingLogs: [testLog],
    ),
  };

  testWidgets('BodySvgWidget renders FRONT and BACK views and muscle badges',
      (tester) async {
    String? tappedGroup;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BodySvgWidget(
            volumeData: sampleVolumeData,
            onZoneTapped: (group) => tappedGroup = group,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify headers and legend
    expect(find.text('FRONT'), findsOneWidget);
    expect(find.text('BACK'), findsOneWidget);
    expect(find.text('<50% Under'), findsOneWidget);

    // Tap chest muscle chip
    final chestChip = find.text('CHEST (30%)');
    expect(chestChip, findsOneWidget);
    await tester.tap(chestChip);
    expect(tappedGroup, 'chest');
  });

  testWidgets('MuscleZoneDetailPopup displays volume and contributing logs',
      (tester) async {
    final vm = WorkoutViewModel(
      workoutRepository: WorkoutRepository(apiClient: ApiClient()),
      exerciseRepository: ExerciseRepository(apiClient: ApiClient()),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<WorkoutViewModel>.value(
          value: vm,
          child: Scaffold(
            body: MuscleZoneDetailPopup(data: sampleVolumeData['chest']!),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CHEST'), findsOneWidget);
    expect(find.text('30% Target'), findsOneWidget);
    expect(find.text('+30'), findsOneWidget);
    expect(find.text('3 sets × 10 reps @ 60.0kg'), findsOneWidget);
  });
}
