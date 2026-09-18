import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:project/models/maintenance_request.dart';
import 'package:project/viewmodels/maintenance_viewmodel.dart';
import 'package:project/views/maintenance/maintenance_detail_screen.dart';
import '../fake_repositories/fake_maintenance_repository.dart';

void main() {
  testWidgets('MaintenanceDetailScreen renders details, urgency badge, and status timeline', (tester) async {
    final fakeRepo = FakeMaintenanceRepository(
      initialRequests: [
        const MaintenanceRequest(
          id: 101,
          title: 'Water pipe leaking under sink',
          category: 'Water',
          description: 'Constant dripping water under bathroom sink.',
          status: 'Pending',
          urgency: 'High',
          preferredTimeSlot: 'Morning (09:00 - 12:00)',
          createdAt: '2026-09-18T08:30:00Z',
          updatedAt: '2026-09-18T08:30:00Z',
        ),
      ],
    );
    final vm = MaintenanceViewModel(fakeRepo);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<MaintenanceViewModel>.value(
          value: vm,
          child: const MaintenanceDetailScreen(requestId: 101),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title and Category
    expect(find.text('Request Details'), findsOneWidget);
    expect(find.text('Water pipe leaking under sink'), findsOneWidget);
    expect(find.text('Water'), findsOneWidget);

    // Verify Urgency and Time Slot
    expect(find.text('High'), findsOneWidget);
    expect(find.text('Morning (09:00 - 12:00)'), findsOneWidget);

    // Verify Description
    expect(find.text('Constant dripping water under bathroom sink.'), findsOneWidget);

    // Verify Status Timeline Steps
    expect(find.text('STATUS TIMELINE'), findsOneWidget);
    expect(find.text('Request Submitted'), findsOneWidget);
    expect(find.text('Technician Assigned'), findsOneWidget);
    expect(find.text('Repair In Progress'), findsOneWidget);
    expect(find.text('Completed & Verified'), findsOneWidget);

    // Verify Cancel button for Pending status
    expect(find.text('Cancel Request'), findsOneWidget);

    // No overflow exception
    expect(tester.takeException(), isNull);
  });
}
