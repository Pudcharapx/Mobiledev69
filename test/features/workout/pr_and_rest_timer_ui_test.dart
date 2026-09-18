import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/api/api_client.dart';
import 'package:project/core/services/rest_timer_service.dart';
import 'package:project/features/heatmap/data/exercise_repository.dart';
import 'package:project/features/workout/data/workout_repository.dart';
import 'package:project/features/workout/domain/one_rep_max_calculator.dart';
import 'package:project/features/workout/presentation/pr_celebration_dialog.dart';
import 'package:project/core/widgets/floating_glass_rest_timer.dart';
import 'package:project/features/workout/presentation/routine_templates_sheet.dart';
import 'package:project/features/workout/presentation/workout_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PR and Rest Timer UI Widget Tests', () {
    testWidgets('PrCelebrationDialog renders celebratory metrics and buttons',
        (tester) async {
      const prResult = PersonalRecordResult(
        isNewWeightPR: true,
        isNew1RMPR: true,
        newWeight: 80.0,
        previousMaxWeight: 75.0,
        new1RM: 96.0,
        previous1RM: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => PrCelebrationDialog.show(
                  context,
                  exerciseName: 'Bench Press',
                  prResult: prResult,
                ),
                child: const Text('Show PR Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show PR Dialog'));
      await tester.pumpAndSettle();

      // Check Dialog UI elements
      expect(find.text('NEW PERSONAL RECORD!'), findsOneWidget);
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('80.0 kg'), findsOneWidget);
      expect(find.text('96.0 kg'), findsOneWidget);
      expect(find.text('+5.0 kg'), findsOneWidget);
      expect(find.text('Keep Crushing It 💪'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Keep Crushing It 💪'));
      await tester.pumpAndSettle();
      expect(find.text('NEW PERSONAL RECORD!'), findsNothing);
    });

    testWidgets('FloatingGlassRestTimer renders and displays countdown',
        (tester) async {
      final timerService = RestTimerService();

      await tester.pumpWidget(
        ChangeNotifierProvider<RestTimerService>.value(
          value: timerService,
          child: const MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  Center(child: Text('Main Screen Content')),
                  FloatingGlassRestTimer(),
                ],
              ),
            ),
          ),
        ),
      );

      // Initially invisible
      expect(find.text('Rest Interval'), findsNothing);

      // Start timer
      timerService.startTimer(90, exerciseName: 'Overhead Press');
      await tester.pumpAndSettle();

      // Should now be visible with exercise name and countdown
      expect(find.text('Rest: Overhead Press'), findsOneWidget);
      expect(find.text('01:30'), findsOneWidget);
      expect(find.text('+15s'), findsOneWidget);
      expect(find.text('+30s'), findsOneWidget);

      timerService.dispose();
    });

    testWidgets('RoutineTemplatesSheet renders presets and choice chips',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final workoutRepo = WorkoutRepository(apiClient: ApiClient());
      final exerciseRepo = ExerciseRepository(apiClient: ApiClient());
      final viewModel = WorkoutViewModel(
        workoutRepository: workoutRepo,
        exerciseRepository: exerciseRepo,
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<WorkoutViewModel>.value(
          value: viewModel,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => RoutineTemplatesSheet.show(context),
                  child: const Text('Open Routines'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Routines'));
      await tester.pumpAndSettle();

      // Check header and routine chips
      expect(find.text('Workout Routines'), findsOneWidget);
      expect(find.text('Push Day'), findsWidgets);
      expect(find.text('Pull Day'), findsOneWidget);
      expect(find.text('Leg Day'), findsOneWidget);
      expect(find.text('Upper Body Blast'), findsOneWidget);
      expect(find.text('1-Tap Log All Push Day Exercises'), findsOneWidget);
    });
  });
}
