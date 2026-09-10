import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/widgets/app_top_nav_bar.dart';

void main() {
  group('AppTopNavBar Widget Tests (SRS 9.2)', () {
    testWidgets('renders circular back button, title, calendar icon, and round profile photo', (tester) async {
      bool backPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppTopNavBar(
              title: 'Muscle Heatmap',
              showBackButton: true,
              onBackPressed: () {
                backPressed = true;
              },
            ),
          ),
        ),
      );

      // Title
      expect(find.text('Muscle Heatmap'), findsOneWidget);

      // Circular back button
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      expect(backPressed, isTrue);

      // Calendar icon
      expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);

      // Round profile avatar text
      expect(find.text('U'), findsOneWidget);
    });

    testWidgets('calendar icon displays SnackBar on tap', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: AppTopNavBar(
              title: 'Muscle Heatmap',
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.calendar_month_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Today is'), findsOneWidget);
    });
  });
}
