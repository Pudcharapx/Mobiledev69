import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:project/models/maintenance_request.dart';
import 'package:project/viewmodels/maintenance_viewmodel.dart';
import 'package:project/views/maintenance/maintenance_screen.dart';
import '../fake_repositories/fake_maintenance_repository.dart';

void main() {
  testWidgets('MaintenanceScreen renders FAB with padding and AppBar action without overflow', (tester) async {
    final fakeRepo = FakeMaintenanceRepository(
      initialRequests: [
        const MaintenanceRequest(
          id: 1,
          title: 'AC leaking water',
          category: 'Air Conditioner',
          description: 'Water dripping onto desk',
          status: 'Pending',
          createdAt: '2026-09-18T10:00:00Z',
          updatedAt: '2026-09-18T10:00:00Z',
        ),
      ],
    );
    final vm = MaintenanceViewModel(fakeRepo);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<MaintenanceViewModel>.value(
          value: vm,
          child: const MaintenanceScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title and Filter Pills
    expect(find.text('Maintenance'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Pending'), findsNWidgets(2)); // filter pill + card status badge
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    // Verify Add Button in AppBar
    expect(find.byTooltip('Add Request'), findsOneWidget);

    // Verify FloatingActionButton exists with icon
    expect(find.byIcon(Icons.add_rounded), findsNWidgets(2)); // 1 in AppBar, 1 in FAB

    // Verify request item is displayed
    expect(find.text('AC leaking water'), findsOneWidget);

    // Verify no render flex overflow occurred
    expect(tester.takeException(), isNull);
  });
}
