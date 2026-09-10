import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/features/heatmap/domain/imbalance_calculator.dart';
import 'package:project/features/heatmap/presentation/imbalance_alert_card.dart';

void main() {
  Widget createWidgetUnderTest({
    required List<ImbalanceAlert> activeAlerts,
    required List<ImbalanceAlert> allPairs,
    VoidCallback? onLogAction,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ImbalanceAlertCard(
            activeAlerts: activeAlerts,
            allEvaluatedPairs: allPairs,
            onLogAction: onLogAction,
          ),
        ),
      ),
    );
  }

  group('ImbalanceAlertCard Widget Tests (SRS 8.2 & 9.2)', () {
    testWidgets('displays Optimal status when no active alerts exist', (tester) async {
      final allPairs = ImbalanceCalculator.evaluateAllPairs(
        volumes: {'chest': 100.0, 'back': 90.0, 'legs': 100.0, 'hamstrings': 90.0},
      );

      await tester.pumpWidget(createWidgetUnderTest(
        activeAlerts: [],
        allPairs: allPairs,
      ));

      expect(find.text('Muscle Balance: Optimal'), findsOneWidget);
      expect(find.text('Balanced'), findsOneWidget);
      expect(find.text('Log Another Workout'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    });

    testWidgets('displays Imbalance Alert and exact message when imbalance detected', (tester) async {
      final volumes = {
        'chest': 100.0,
        'back': 40.0, // 60% diff -> Alert
        'legs': 100.0,
        'hamstrings': 80.0,
        'biceps': 50.0,
        'triceps': 50.0,
      };
      final activeAlerts = ImbalanceCalculator.checkVolumeImbalances(volumes: volumes);
      final allPairs = ImbalanceCalculator.evaluateAllPairs(volumes: volumes);

      await tester.pumpWidget(createWidgetUnderTest(
        activeAlerts: activeAlerts,
        allPairs: allPairs,
      ));

      expect(find.text('Muscle Imbalance Alert'), findsOneWidget);
      expect(find.text('1 Alert'), findsOneWidget);
      expect(
        find.text(
          'Your back is undertrained compared to your chest \u2014 consider adding more back work',
        ),
        findsOneWidget,
      );
      expect(find.text('+60% diff'), findsOneWidget);
      expect(find.text('Add Workout to Balance'), findsOneWidget);
    });

    testWidgets('tapping expandable toggle shows all 3 opposing pairs breakdown', (tester) async {
      final volumes = {
        'chest': 100.0,
        'back': 50.0,
        'legs': 80.0,
        'hamstrings': 80.0,
        'biceps': 60.0,
        'triceps': 60.0,
      };
      final allPairs = ImbalanceCalculator.evaluateAllPairs(volumes: volumes);
      final activeAlerts = ImbalanceCalculator.checkVolumeImbalances(volumes: volumes);

      await tester.pumpWidget(createWidgetUnderTest(
        activeAlerts: activeAlerts,
        allPairs: allPairs,
      ));

      expect(find.text('View All 3 Opposing Pairs'), findsOneWidget);
      expect(find.text('chest vs back'), findsNothing);

      // Tap to expand
      await tester.tap(find.text('View All 3 Opposing Pairs'));
      await tester.pumpAndSettle();

      expect(find.text('Hide Pair Breakdown'), findsOneWidget);
      expect(find.text('chest vs back'), findsOneWidget);
      expect(find.text('legs (quads) vs hamstrings'), findsOneWidget);
      expect(find.text('biceps vs triceps'), findsOneWidget);
    });

    testWidgets('tapping action button triggers callback', (tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(createWidgetUnderTest(
        activeAlerts: [],
        allPairs: [],
        onLogAction: () {
          actionTriggered = true;
        },
      ));

      await tester.tap(find.text('Log Another Workout'));
      await tester.pumpAndSettle();

      expect(actionTriggered, isTrue);
    });
  });
}
