import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/widgets/glass_container.dart';

void main() {
  group('Glassmorphism Widget Tests', () {
    testWidgets('GlassContainer renders child with BackdropFilter and rounded border', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassContainer(
              borderRadius: 24,
              blur: 16,
              child: Text('Glass Content'),
            ),
          ),
        ),
      );

      expect(find.text('Glass Content'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('GlassCard renders child with frosted glass styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              child: Text('Glass Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Glass Card Content'), findsOneWidget);
      expect(find.byType(GlassContainer), findsOneWidget);
    });

    testWidgets('GlassButton responds to tap events', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassButton(
              onPressed: () => tapped = true,
              label: 'Tap Me',
              icon: const Icon(Icons.touch_app),
            ),
          ),
        ),
      );

      expect(find.text('Tap Me'), findsOneWidget);
      expect(find.byIcon(Icons.touch_app), findsOneWidget);

      await tester.tap(find.byType(GlassButton));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
