import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:project/repositories/parcel_repository.dart';
import 'package:project/viewmodels/parcel_viewmodel.dart';
import 'package:project/views/parcels/parcel_screen.dart';

void main() {
  testWidgets('ParcelScreen renders parcel cards and search filters', (tester) async {
    final repo = ParcelRepositoryImpl();
    final vm = ParcelViewModel(repo);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<ParcelViewModel>.value(
          value: vm,
          child: const ParcelScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Parcels'), findsOneWidget);
    expect(find.text('Flash Express'), findsOneWidget);
    expect(find.text('Ready for Pickup'), findsWidgets);

    // Filter chip test - tap 'Claimed'
    await tester.tap(find.text('Claimed'));
    await tester.pumpAndSettle();
    expect(find.text('Kerry Express'), findsOneWidget);

    // Tap All to restore
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();

    // Search test
    await tester.enterText(find.byType(TextField), 'SPX');
    await tester.pumpAndSettle();
    expect(find.text('Flash Express'), findsNothing);
    expect(find.text('SPX Express'), findsOneWidget);
  });

  testWidgets('ParcelScreen opens pickup sheet with QR code and PIN', (tester) async {
    final repo = ParcelRepositoryImpl();
    final vm = ParcelViewModel(repo);

    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<ParcelViewModel>.value(
          value: vm,
          child: const ParcelScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap 'Pickup QR' button
    final pickupBtn = find.text('Pickup QR').first;
    await tester.tap(pickupBtn);
    await tester.pumpAndSettle();

    expect(find.textContaining('Parcel Pickup Pass'), findsOneWidget);
    expect(find.textContaining('Show this QR code'), findsOneWidget);
    expect(find.textContaining('4921'), findsOneWidget);

    // Ensure confirm button is visible and tap it
    final confirmBtn = find.textContaining('Confirm Claimed');
    await tester.ensureVisible(confirmBtn);
    await tester.pumpAndSettle();
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    expect(find.textContaining('Parcel Pickup Pass'), findsNothing);
  });
}
