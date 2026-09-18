import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/models/utility_usage.dart';
import 'package:project/widgets/utility_analytics_card.dart';

void main() {
  testWidgets('UtilityAnalyticsCard renders power & water tabs and insights', (tester) async {
    final mockData = UtilityAnalyticsData.mockDefault();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: UtilityAnalyticsCard(data: mockData),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Usage Analytics'), findsOneWidget);
    expect(find.text('Power'), findsOneWidget);
    expect(find.text('Water'), findsOneWidget);

    // Initial is power: current unit 215 kWh appears in header & bar
    expect(find.text('215'), findsWidgets);
    expect(find.text('kWh'), findsWidgets);

    // Switch to Water tab
    await tester.tap(find.text('Water'));
    await tester.pumpAndSettle();

    expect(find.text('7.8'), findsWidgets);
    expect(find.text('m³'), findsWidgets);
    expect(find.textContaining('การใช้น้ำ'), findsOneWidget);
  });
}
