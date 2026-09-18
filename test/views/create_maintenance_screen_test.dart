import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:project/viewmodels/maintenance_viewmodel.dart';
import 'package:project/views/maintenance/create_maintenance_screen.dart';
import '../fake_repositories/fake_maintenance_repository.dart';

void main() {
  testWidgets('CreateMaintenanceScreen renders form and submit buttons without overflow', (tester) async {
    final fakeRepo = FakeMaintenanceRepository();
    final vm = MaintenanceViewModel(fakeRepo);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<MaintenanceViewModel>.value(
          value: vm,
          child: const CreateMaintenanceScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('New Request'), findsOneWidget);
    expect(find.text('PROBLEM TITLE'), findsOneWidget);
    expect(find.text('CATEGORY'), findsOneWidget);
    expect(find.text('URGENCY LEVEL'), findsOneWidget);
    expect(find.text('PREFERRED TIME SLOT'), findsOneWidget);
    expect(find.text('Normal'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
    expect(find.text('Emergency'), findsOneWidget);
    expect(find.text('DESCRIPTION'), findsOneWidget);
    expect(find.text('Submit Request'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Verify no render flex overflow occurred
    expect(tester.takeException(), isNull);
  });

  testWidgets('CreateMaintenanceScreen submits with selected urgency and time slot', (tester) async {
    final fakeRepo = FakeMaintenanceRepository();
    final vm = MaintenanceViewModel(fakeRepo);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<MaintenanceViewModel>.value(
          value: vm,
          child: const CreateMaintenanceScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Fill title
    await tester.enterText(find.byType(TextFormField).first, 'Main circuit breaker tripped');
    // Select Emergency
    await tester.tap(find.text('Emergency'));
    await tester.pumpAndSettle();

    // Fill description
    await tester.enterText(find.byType(TextFormField).at(1), 'Electricity shut off completely in room 204');
    await tester.pumpAndSettle();

    // Scroll and tap Submit Request
    await tester.ensureVisible(find.text('Submit Request'));
    await tester.tap(find.text('Submit Request'));
    await tester.pumpAndSettle();

    expect(fakeRepo.requests.length, equals(1));
    expect(fakeRepo.requests.first.title, equals('Main circuit breaker tripped'));
    expect(fakeRepo.requests.first.urgency, equals('Emergency'));
    expect(fakeRepo.requests.first.preferredTimeSlot, equals('Anytime'));
  });
}
