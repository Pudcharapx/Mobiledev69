import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/widgets/pill_tab_bar.dart';

void main() {
  group('PillTabBar Widget Tests (SRS 9.2)', () {
    testWidgets('renders all 3 required tabs: Heatmap, Log List, Settings', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PillTabBar(currentRoute: '/'),
          ),
        ),
      );

      expect(find.text('Heatmap'), findsOneWidget);
      expect(find.text('Log List'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byIcon(Icons.whatshot_rounded), findsOneWidget);
      expect(find.byIcon(Icons.list_alt_rounded), findsOneWidget);
      expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
    });
  });
}
