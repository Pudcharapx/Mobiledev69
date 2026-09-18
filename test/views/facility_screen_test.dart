import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:project/repositories/facility_repository.dart';
import 'package:project/viewmodels/facility_viewmodel.dart';
import 'package:project/views/facility/facility_screen.dart';

void main() {
  testWidgets('FacilityScreen displays laundry machines and filters', (tester) async {
    final repo = FacilityRepositoryImpl();
    final vm = FacilityViewModel(repo);

    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<FacilityViewModel>.value(
          value: vm,
          child: const FacilityScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Facilities'), findsOneWidget);
    expect(find.text('Smart Laundry'), findsOneWidget);
    expect(find.text('Book Spaces'), findsOneWidget);

    // Check machine name
    expect(find.text('Front-Load Washer 12kg #1'), findsOneWidget);
    expect(find.text('Active'), findsWidgets);

    // Test filter chip 'Dryers'
    final dryersFinder = find.textContaining('Dryers');
    await tester.ensureVisible(dryersFinder);
    await tester.pumpAndSettle();
    await tester.tap(dryersFinder);
    await tester.pumpAndSettle();

    expect(find.text('Heavy-Duty Dryer 15kg #1'), findsOneWidget);
    expect(find.text('Front-Load Washer 12kg #1'), findsNothing);
  });

  testWidgets('FacilityScreen switches to Study & Rooms and opens booking sheet', (tester) async {
    final repo = FacilityRepositoryImpl();
    final vm = FacilityViewModel(repo);

    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<FacilityViewModel>.value(
          value: vm,
          child: const FacilityScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Switch to Book Spaces tab
    await tester.tap(find.text('Book Spaces'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Silent Study Room'), findsWidgets);
    expect(find.textContaining('Group Meeting Pod'), findsOneWidget);

    // Tap Book a Slot
    final bookBtn = find.textContaining('Book a Slot').first;
    await tester.tap(bookBtn);
    await tester.pumpAndSettle();

    expect(find.textContaining('Select Date'), findsOneWidget);
    expect(find.textContaining('Available Time Slots'), findsOneWidget);

    // Confirm booking
    final confirmBtn = find.textContaining('Confirm Booking');
    await tester.ensureVisible(confirmBtn);
    await tester.pumpAndSettle();
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    // Modal closes
    expect(find.textContaining('Available Time Slots'), findsNothing);
  });
}
